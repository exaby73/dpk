import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dpk/core/console.dart';
import 'package:dpk/core/process_runner.dart';
import 'package:dpk/core/shell.dart';
import 'package:dpk/scripts/run_plan.dart';
import 'package:dpk/workspace/workspace.dart';

/// Runs a shell command according to a [RunPlan].
final class ScriptExecutor {
  ScriptExecutor({
    required this.processRunner,
    required this.console,
    required this.workspace,
  });

  final ProcessRunner processRunner;
  final Console console;
  final Workspace workspace;

  /// Runs [command] in every package of [plan] and returns the exit code:
  /// 0, or the exit code of the first failed package in plan order.
  ///
  /// Every run gets [environment] plus `DPK_ROOT`, `DPK_PACKAGE_NAME`, and
  /// `DPK_PACKAGE_PATH`.
  Future<int> execute(
    RunPlan plan,
    String command, {
    Map<String, String> environment = const {},
  }) {
    if (plan.isSingle) {
      final package = plan.packages.single;
      final shell = shellCommand(command);
      return processRunner.runInteractive(
        shell.executable,
        shell.arguments,
        workingDirectory: package.path,
        environment: _environment(package, environment),
      );
    }
    return _runMany(plan, command, environment);
  }

  Map<String, String> _environment(
    WorkspacePackage package,
    Map<String, String> environment,
  ) => {
    ...environment,
    'DPK_ROOT': workspace.root.path,
    'DPK_PACKAGE_NAME': package.name,
    'DPK_PACKAGE_PATH': package.path,
  };

  Future<int> _runMany(
    RunPlan plan,
    String command,
    Map<String, String> environment,
  ) async {
    final outcomes = <String, _Outcome>{};
    final waiting = [...plan.packages];
    final running = <String, Process>{};
    final active = <Future<void>>{};
    final limit = plan.concurrency ?? waiting.length;
    final labelWidth = plan.packages
        .map((package) => package.name.length)
        .reduce((a, b) => a > b ? a : b);
    final colorIndex = {
      for (final (index, package) in plan.packages.indexed) package.name: index,
    };
    var stopping = false;

    bool finished(String name) => outcomes[name]?.exitCode == 0;
    bool blocked(String name) => (plan.dependencies[name] ?? const {}).any(
      (dependency) => outcomes.containsKey(dependency) && !finished(dependency),
    );
    bool ready(WorkspacePackage package) =>
        (plan.dependencies[package.name] ?? const {}).every(finished);

    Future<void> runOne(WorkspacePackage package) async {
      final label = package.name.padRight(labelWidth);
      final prefix = console.useColor
          ? '${console.packageColor(label, colorIndex[package.name]!)} '
                '${console.dim('│')} '
          : '$label | ';
      final shell = shellCommand(command);
      final process = await processRunner.start(
        shell.executable,
        shell.arguments,
        workingDirectory: package.path,
        environment: _environment(package, environment),
      );
      running[package.name] = process;
      unawaited(process.stdin.close());

      Future<void> pipe(Stream<List<int>> stream, StringSink sink) => stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .forEach((line) => sink.writeln('$prefix$line'));

      await Future.wait([
        pipe(process.stdout, console.out),
        pipe(process.stderr, console.err),
      ]);
      final exitCode = normalizeExitCode(await process.exitCode);
      running.remove(package.name);
      outcomes[package.name] ??= _Outcome(exitCode);

      if (exitCode != 0 && plan.failFast && !stopping) {
        stopping = true;
        for (final MapEntry(key: name, value: other) in running.entries) {
          outcomes[name] = const _Outcome.cancelled();
          other.kill();
        }
      }
    }

    while (waiting.isNotEmpty || active.isNotEmpty) {
      for (final package in [...waiting]) {
        if (stopping) {
          outcomes[package.name] = const _Outcome.skipped(
            'stopped by --fail-fast',
          );
          waiting.remove(package);
        } else if (blocked(package.name)) {
          outcomes[package.name] = const _Outcome.skipped(
            'a dependency failed',
          );
          waiting.remove(package);
        }
      }

      while (active.length < limit) {
        final next = waiting.where(ready).firstOrNull;
        if (next == null) {
          break;
        }
        waiting.remove(next);
        late final Future<void> future;
        future = runOne(next).whenComplete(() => active.remove(future));
        active.add(future);
      }

      if (active.isEmpty) {
        for (final package in waiting) {
          outcomes[package.name] = const _Outcome.skipped(
            'its dependencies never finished',
          );
        }
        break;
      }
      await Future.any(active);
    }

    console.err.writeln();
    var exitCode = 0;
    for (final package in plan.packages) {
      final outcome = outcomes[package.name]!;
      console.err.writeln(outcome.describe(package.name, console));
      if (exitCode == 0 && outcome.exitCode != null && outcome.exitCode != 0) {
        exitCode = outcome.exitCode!;
      }
    }
    if (exitCode == 0 && outcomes.values.any((o) => o.exitCode != 0)) {
      exitCode = 1;
    }
    return exitCode;
  }
}

final class _Outcome {
  const _Outcome(int this.exitCode) : reason = null;
  const _Outcome.skipped(String this.reason) : exitCode = null;
  const _Outcome.cancelled() : exitCode = null, reason = 'cancelled';

  /// `null` when the package did not run to completion.
  final int? exitCode;
  final String? reason;

  String describe(String name, Console console) {
    if (exitCode == 0) {
      return '${console.green('✓')} $name';
    }
    if (exitCode != null) {
      return '${console.red('✗')} $name (exit code $exitCode)';
    }
    return '${console.yellow('-')} $name ($reason)';
  }
}
