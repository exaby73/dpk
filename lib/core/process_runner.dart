import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dpk/core/console.dart';

/// Starts the processes dpk depends on: `dart`, `git`, and script shells.
///
/// The interface is the seam between dpk's logic and the operating system.
/// [SystemProcessRunner] is the production adapter; tests can pass a fake
/// that records calls.
abstract interface class ProcessRunner {
  /// Runs a process to completion and captures its output.
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
  });

  /// Runs a process with its output going to the user, and returns its exit
  /// code. When the console is the real stdio, the process inherits stdin,
  /// stdout, and stderr.
  Future<int> runInteractive(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
  });

  /// Starts a process with piped streams, for callers that format its output.
  Future<Process> start(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
  });
}

/// Converts an exit code from a process killed by a signal (reported by Dart
/// as `-signal`) to the shell convention of `128 + signal`.
int normalizeExitCode(int exitCode) =>
    exitCode < 0 ? 128 + exitCode.abs() : exitCode;

/// The production [ProcessRunner].
///
/// While child processes run, it watches SIGINT and SIGTERM so dpk never
/// exits before its children. SIGTERM is forwarded to every child. SIGINT
/// already reaches children in the terminal's process group. Once the
/// children exit, dpk exits with `128 + signal`.
final class SystemProcessRunner implements ProcessRunner {
  SystemProcessRunner(this.console);

  final Console console;
  final Set<Process> _children = {};
  final List<StreamSubscription<ProcessSignal>> _signalSubscriptions = [];
  ProcessSignal? _receivedSignal;

  @override
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
  }) {
    return Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
  }

  @override
  Future<int> runInteractive(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
  }) async {
    if (console.isStdio) {
      final process = await Process.start(
        executable,
        arguments,
        workingDirectory: workingDirectory,
        environment: environment,
        mode: ProcessStartMode.inheritStdio,
      );
      return _track(process, process.exitCode);
    }

    final process = await start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
    );
    unawaited(process.stdin.close());
    await Future.wait([
      process.stdout.transform(utf8.decoder).forEach(console.out.write),
      process.stderr.transform(utf8.decoder).forEach(console.err.write),
    ]);
    return normalizeExitCode(await process.exitCode);
  }

  @override
  Future<Process> start(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
  }) async {
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
    );
    unawaited(_track(process, process.exitCode));
    return process;
  }

  Future<int> _track(Process process, Future<int> exitCode) async {
    _children.add(process);
    _watchSignals();
    try {
      return normalizeExitCode(await exitCode);
    } finally {
      _children.remove(process);
      if (_children.isEmpty) {
        await _unwatchSignals();
        final signal = _receivedSignal;
        if (signal != null) {
          exit(128 + _signalNumber(signal));
        }
      }
    }
  }

  void _watchSignals() {
    if (Platform.isWindows || _signalSubscriptions.isNotEmpty) {
      return;
    }

    _signalSubscriptions
      ..add(ProcessSignal.sigint.watch().listen(_onSignal))
      ..add(ProcessSignal.sigterm.watch().listen(_onSignal));
  }

  Future<void> _unwatchSignals() async {
    for (final subscription in _signalSubscriptions) {
      await subscription.cancel();
    }
    _signalSubscriptions.clear();
  }

  void _onSignal(ProcessSignal signal) {
    _receivedSignal ??= signal;
    if (signal == ProcessSignal.sigterm) {
      for (final child in _children) {
        child.kill();
      }
    }
  }

  static int _signalNumber(ProcessSignal signal) =>
      signal == ProcessSignal.sigint ? 2 : 15;
}
