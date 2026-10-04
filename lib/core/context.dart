import 'dart:convert';
import 'dart:io';

import 'package:dpk/config/config_reader.dart';
import 'package:dpk/config/dpk_config.dart';
import 'package:dpk/config/project.dart';
import 'package:dpk/core/console.dart';
import 'package:dpk/core/errors.dart';
import 'package:dpk/core/invocation.dart';
import 'package:dpk/core/process_runner.dart';
import 'package:dpk/core/shell.dart';
import 'package:dpk/scripts/hook_lifecycle.dart';
import 'package:dpk/scripts/run_plan.dart';
import 'package:dpk/scripts/script_executor.dart';
import 'package:path/path.dart' as p;

/// Everything a command needs: the parsed invocation, the loaded project,
/// output, and process running.
final class DpkContext {
  DpkContext({
    required this.invocation,
    required this.console,
    required this.processRunner,
    required this.workingDirectory,
    required this.environment,
    this.project,
  });

  final Invocation invocation;
  final Console console;
  final ProcessRunner processRunner;

  /// The directory dpk was started in.
  final String workingDirectory;

  /// The environment dpk was started with.
  final Map<String, String> environment;

  /// The project, or `null` for commands that work without one.
  final Project? project;

  /// The project. Only call this from commands that need one; dpk loads the
  /// project before running them.
  Project get requireProject =>
      project ??
      (throw ProjectException(
        'This command needs a dpk project. Run "dpk init" to create one.',
      ));

  /// The directory a command acts on: the current package in a project,
  /// otherwise the `-C` directory or the working directory.
  String get targetDirectory =>
      project?.workspace.current.path ??
      p.normalize(
        p.absolute(p.join(workingDirectory, invocation.directory ?? '.')),
      );

  HookStack get hookStack => HookStack.fromEnvironment(environment);

  /// Runs `dart` with [arguments] in [workingDirectory], with output going to
  /// the user. In project mode, pub uses the project cache unless
  /// [useProjectCache] is false.
  Future<int> runDart(
    List<String> arguments, {
    String? workingDirectory,
    bool useProjectCache = true,
    Map<String, String> environment = const {},
  }) {
    console.detail('Running: dart ${arguments.join(' ')}');
    return processRunner.runInteractive(
      'dart',
      arguments,
      workingDirectory: workingDirectory ?? targetDirectory,
      environment: {
        if (useProjectCache) ...?project?.pubEnvironment,
        ...environment,
      },
    );
  }

  /// Global `dart pub` flags that follow from dpk's own options.
  List<String> get pubFlags => [
    if (invocation.verbose) '--verbose',
    if (invocation.color == true) '--color',
    if (invocation.color == false) '--no-color',
  ];

  /// Runs [action] for [target] between its hooks. Outside a project, runs
  /// [action] without hooks.
  Future<int> withHooks(
    String target,
    Future<int> Function(HookStack stack) action, {
    String? hooksFrom,
    HookOrder order = HookOrder.standard,
  }) {
    final project = this.project;
    if (project == null) {
      return action(hookStack);
    }
    final lifecycle = HookLifecycle(
      scripts: project.scripts,
      rootPath: project.rootPath,
      stack: hookStack,
      console: console,
      runHook: (hook, stack) => runScript(hook, stack: stack),
    );
    return lifecycle.run(target, action, hooksFrom: hooksFrom, order: order);
  }

  /// Runs [script] in the packages it selects, without its hooks.
  Future<int> runScript(
    Script script, {
    required HookStack stack,
    List<String> arguments = const [],
    List<String> filters = const [],
    int? concurrency,
    bool? failFast,
    bool? dependencyOrder,
  }) {
    final project = requireProject;
    final RunPlan plan;
    try {
      plan = planRun(
        workspace: project.workspace,
        runInPackages: script.runInPackages,
        filters: filters,
        concurrency: concurrency ?? script.concurrency,
        failFast: failFast ?? script.failFast ?? false,
        dependencyOrder: dependencyOrder ?? script.dependencyOrder ?? false,
      );
    } on RunPlanException catch (e) {
      throw DpkException('Script "${script.name}": ${e.message}');
    }

    final command = withArguments(script.command.trim(), arguments);
    final where = plan.isSingle ? '' : ' in ${plan.packages.length} packages';
    console.step('> ${script.name}$where: $command');

    return ScriptExecutor(
      processRunner: processRunner,
      console: console,
      workspace: project.workspace,
    ).execute(
      plan,
      command,
      environment: {
        ...project.pubEnvironment,
        ..._envFile(script, project),
        ...script.env,
        ...stack.toEnvironment(),
      },
    );
  }

  /// Reads [script]'s `env_file`, resolved from [Project.rootPath]. Throws a
  /// [DpkException] when the file is missing.
  Map<String, String> _envFile(Script script, Project project) {
    final name = script.envFile;
    if (name == null) {
      return const {};
    }
    final file = File(p.join(project.rootPath, name));
    if (!file.existsSync()) {
      throw DpkException(
        'Script "${script.name}": env_file ${displayPath(file.path)} does not '
        'exist.',
      );
    }
    return parseDotenv(file.readAsStringSync());
  }
}

/// Parses `KEY=value` lines. Blank lines, `#` comment lines, and a ` #`
/// comment after an unquoted value are skipped. An `export ` prefix is
/// allowed, and values may be wrapped in single or double quotes.
Map<String, String> parseDotenv(String content) {
  final result = <String, String>{};
  for (final rawLine in const LineSplitter().convert(content)) {
    var line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) {
      continue;
    }
    if (line.startsWith('export ')) {
      line = line.substring('export '.length).trimLeft();
    }
    final equals = line.indexOf('=');
    if (equals <= 0) {
      continue;
    }
    final key = line.substring(0, equals).trim();
    var value = line.substring(equals + 1).trim();
    final quoted =
        value.length >= 2 &&
        ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'")));
    if (quoted) {
      value = value.substring(1, value.length - 1);
    } else {
      final comment = value.indexOf(' #');
      if (comment != -1) {
        value = value.substring(0, comment).trimRight();
      }
    }
    result[key] = value;
  }
  return result;
}
