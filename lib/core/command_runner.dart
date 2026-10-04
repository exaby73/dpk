import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:dpk/commands/catalog_command.dart';
import 'package:dpk/commands/clean_command.dart';
import 'package:dpk/commands/doctor_command.dart';
import 'package:dpk/commands/exec_command.dart';
import 'package:dpk/commands/get_command.dart';
import 'package:dpk/commands/init_command.dart';
import 'package:dpk/commands/list_command.dart';
import 'package:dpk/commands/patch_command.dart';
import 'package:dpk/commands/pub_passthrough_command.dart';
import 'package:dpk/commands/release_command.dart';
import 'package:dpk/commands/run_command.dart';
import 'package:dpk/commands/skills_command.dart';
import 'package:dpk/config/config_reader.dart';
import 'package:dpk/config/project.dart';
import 'package:dpk/core/console.dart';
import 'package:dpk/core/context.dart';
import 'package:dpk/core/errors.dart';
import 'package:dpk/core/invocation.dart';
import 'package:dpk/core/process_runner.dart';
import 'package:dpk/scripts/run_plan.dart';
import 'package:dpk/utils/version_output.dart';
import 'package:path/path.dart' as p;

/// Runs dpk with [arguments] and returns the exit code.
///
/// [dpkCommand] is the command line that starts this dpk. When given, `dpk`
/// in scripts runs that same dpk. Tests pass a buffered [console], a fake
/// [processRunner], and a [workingDirectory] to run dpk in-process.
Future<int> runDpk(
  List<String> arguments, {
  Console? console,
  ProcessRunner? processRunner,
  String? workingDirectory,
  Map<String, String>? environment,
  List<String>? dpkCommand,
}) async {
  final Invocation invocation;
  try {
    invocation = Invocation.parse(arguments);
  } on UsageException catch (e) {
    (console ?? Console.stdio()).err.writeln(e);
    return 64;
  }

  final output = console ?? Console.stdio(color: invocation.color);
  output
    ..verbose = invocation.verbose
    ..quiet = invocation.quiet;

  if (invocation.version && invocation.command == null) {
    output.info(renderVersionOutput());
    return 0;
  }

  final cwd = workingDirectory ?? Directory.current.path;
  try {
    final start = invocation.directory == null
        ? cwd
        : _resolve(cwd, invocation.directory!);
    final project = invocation.needsProject
        ? Project.load(start, cacheDirectoryOverride: invocation.cacheDirectory)
        : _tryLoad(start, invocation);
    for (final warning in project?.warnings ?? const []) {
      output.warning(warning.toString());
    }

    final context = DpkContext(
      invocation: invocation,
      console: output,
      processRunner: processRunner ?? SystemProcessRunner(output),
      workingDirectory: cwd,
      environment: environment ?? Platform.environment,
      project: project,
      dpkCommand: dpkCommand,
    );
    return await DpkCommandRunner(context).run(invocation.runnerArguments) ?? 0;
  } on UsageException catch (e) {
    output.err.writeln(e);
    return 64;
  } on DpkException catch (e) {
    output.error(e.message);
    return e.exitCode;
  } on ProjectException catch (e) {
    output.error(e.message);
    return 1;
  } on ConfigException catch (e) {
    output.error(e.toString());
    return 1;
  } on RunPlanException catch (e) {
    output.error(e.message);
    return 1;
  }
}

String _resolve(String cwd, String path) => p.normalize(p.join(cwd, path));

/// Loads the project for commands that work without one, such as help and
/// shell completion, so they can list scripts. Problems are ignored.
Project? _tryLoad(String start, Invocation invocation) {
  final listsScripts =
      invocation.command == null ||
      invocation.help ||
      const {'help', 'completion'}.contains(invocation.command);
  if (!listsScripts) {
    return null;
  }
  try {
    return Project.load(
      start,
      cacheDirectoryOverride: invocation.cacheDirectory,
    );
  } on Exception {
    return null;
  }
}

final class DpkCommandRunner extends CompletionCommandRunner<int> {
  DpkCommandRunner(this.context)
    : super(
        'dpk',
        'A package manager for Dart that adds scripts, hooks, workspace '
            'catalogs, and dependency patches to dart pub.',
      ) {
    argParser
      ..addOption(
        'directory',
        abbr: 'C',
        valueHelp: 'dir',
        help: 'Run as if dpk was started in <dir>.',
      )
      ..addOption(
        'cache-dir',
        valueHelp: 'dir',
        help:
            'Use <dir> as the project cache in project mode. Default: '
            'pub_packages, or cache_dir in dpk.yaml.',
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        negatable: false,
        help: 'Print what dpk runs, and pass --verbose to pub.',
      )
      ..addFlag(
        'quiet',
        abbr: 'q',
        negatable: false,
        help: 'Do not print the scripts and hooks dpk runs.',
      )
      ..addFlag(
        'color',
        help: 'Use colors. Default: on in a terminal unless NO_COLOR is set.',
      )
      ..addFlag(
        'version',
        negatable: false,
        help: 'Print the dpk and Dart versions.',
      );

    addCommand(GetCommand(context));
    addCommand(RunCommand(context));
    addCommand(ExecCommand(context));
    addCommand(ListCommand(context));
    addCommand(CleanCommand(context));
    addCommand(CatalogCommand(context));
    addCommand(PatchCommand(context));
    addCommand(ReleaseCommand(context));
    addCommand(InitCommand(context));
    addCommand(DoctorCommand(context));
    addCommand(SkillsCommand(context));
    for (final definition in pubPassthroughCommandDefinitions) {
      addCommand(PubPassthroughCommand(context, definition));
    }
  }

  final DpkContext context;

  @override
  bool get enableAutoInstall => false;

  @override
  String get usageFooter =>
      '\ndpk options go before the command. Everything after the command '
      'belongs to it.\n'
      'Shell completion: run "dpk install-completion-files".\n'
      'Docs: https://github.com/exaby73/dpk';

  @override
  void printUsage() => context.console.info(usage);

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    final command = topLevelResults.command;
    final runCommand = commands['run'];
    if (command?.name == 'run' &&
        command!.command == null &&
        command.rest.isEmpty &&
        runCommand is RunCommand) {
      runCommand.printUsage();
      return 0;
    }
    return super.runCommand(topLevelResults);
  }
}
