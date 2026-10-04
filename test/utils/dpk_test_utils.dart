import 'dart:io';

import 'package:dpk/commands/init_command.dart';
import 'package:dpk/core/command_runner.dart';
import 'package:dpk/core/console.dart';
import 'package:dpk/core/process_runner.dart';

/// A `version` constraint that the dpk under test satisfies.
final versionConstraint = InitCommand.defaultVersionConstraint;

/// The output and exit code of one in-process dpk run.
final class DpkResult {
  const DpkResult(this.exitCode, this.stdout, this.stderr);

  final int exitCode;
  final String stdout;
  final String stderr;

  @override
  String toString() =>
      'exit code $exitCode\n--- stdout\n$stdout\n--- stderr\n$stderr';
}

/// Runs dpk in-process in [directory] and captures its output. Child
/// processes run for real unless [processRunner] is given.
Future<DpkResult> dpk(
  List<String> arguments, {
  required String directory,
  ProcessRunner? processRunner,
  Map<String, String> environment = const {},
}) async {
  final console = Console.buffered();
  final exitCode = await runDpk(
    arguments,
    console: console,
    processRunner: processRunner,
    workingDirectory: directory,
    environment: environment,
  );
  return DpkResult(exitCode, console.outText, console.errText);
}

/// One process start recorded by [RecordingProcessRunner].
final class RecordedProcess {
  const RecordedProcess(
    this.executable,
    this.arguments,
    this.workingDirectory,
    this.environment,
  );

  final String executable;
  final List<String> arguments;
  final String? workingDirectory;
  final Map<String, String>? environment;

  /// The command line, for readable assertions.
  String get commandLine => [executable, ...arguments].join(' ');

  /// For shell scripts, the command string passed to the shell.
  String get script => arguments.last;

  @override
  String toString() => '$commandLine (in $workingDirectory)';
}

/// A [ProcessRunner] that records every process instead of starting it, and
/// reports [exitCodes] for matching command lines (0 otherwise).
final class RecordingProcessRunner implements ProcessRunner {
  RecordingProcessRunner({this.exitCodes = const {}, this.outputs = const {}});

  final Map<Pattern, int> exitCodes;

  /// Standard output returned by [run] for matching command lines.
  final Map<Pattern, String> outputs;
  final List<RecordedProcess> processes = [];

  int _exitCodeFor(RecordedProcess process) {
    for (final MapEntry(key: pattern, value: code) in exitCodes.entries) {
      if (process.commandLine.contains(pattern)) {
        return code;
      }
    }
    return 0;
  }

  @override
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
  }) async {
    final process = RecordedProcess(
      executable,
      arguments,
      workingDirectory,
      environment,
    );
    processes.add(process);
    final output = outputs.entries
        .where((entry) => process.commandLine.contains(entry.key))
        .map((entry) => entry.value)
        .firstOrNull;
    return ProcessResult(0, _exitCodeFor(process), output ?? '', '');
  }

  @override
  Future<int> runInteractive(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
  }) async {
    final process = RecordedProcess(
      executable,
      arguments,
      workingDirectory,
      environment,
    );
    processes.add(process);
    return _exitCodeFor(process);
  }

  @override
  Future<Process> start(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
  }) => throw UnimplementedError('RecordingProcessRunner.start');

  /// The `dart` invocations, as command lines without `dart`.
  List<String> get dartCommands => [
    for (final process in processes)
      if (process.executable == 'dart') process.arguments.join(' '),
  ];

  /// The shell command strings of scripts and hooks, in order.
  List<String> get scripts => [
    for (final process in processes)
      if (process.executable != 'dart' && process.executable != 'git')
        process.script,
  ];
}

/// A minimal pubspec for a package named [name].
String pubspec(String name, {String extra = ''}) =>
    'name: $name\nenvironment:\n  sdk: ^3.11.0\n$extra';
