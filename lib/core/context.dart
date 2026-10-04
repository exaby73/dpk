import 'dart:convert';
import 'dart:io';

import 'package:dpk/config/config_reader.dart';
import 'package:dpk/config/dpk_config.dart';
import 'package:dpk/config/project.dart';
import 'package:dpk/core/console.dart';
import 'package:dpk/core/errors.dart';
import 'package:dpk/core/invocation.dart';
import 'package:dpk/core/process_runner.dart';
import 'package:dpk/core/self_command.dart';
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
    this.dpkCommand,
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

  /// The command line that starts this dpk. When set, scripts get a `dpk`
  /// launcher for it first on `PATH`, so `dpk` in a script is this dpk.
  final List<String>? dpkCommand;

  /// The environment for a script's processes: [variables] with `PATH`
  /// starting at the `dpk` launcher when [dpkCommand] is set.
  Map<String, String> scriptEnvironment(Map<String, String> variables) {
    final command = dpkCommand;
    if (command == null) {
      return variables;
    }
    final path =
        variables['PATH'] ??
        environment['PATH'] ??
        Platform.environment['PATH'];
    return {
      ...variables,
      'PATH': prependToPath(writeDpkLauncher(command), path),
    };
  }

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

  /// Hooks and `depends_on` dependencies that already ran in this tree of
  /// dpk processes. Nested dpk processes inherit it.
  HookStack get hookStack {
    final inherited = HookStack.fromEnvironment(environment);
    final project = this.project;
    if (project == null || _startedDependencies.isEmpty) {
      return inherited;
    }
    return inherited.adding(
      project.rootPath,
      _startedDependencies.map(_dependencyKey),
    );
  }

  /// `depends_on` entries started by this process, such as `build` or
  /// `^build`.
  final Set<String> _startedDependencies = {};

  static String _dependencyKey(String dependency) => 'dep:$dependency';

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

  /// Runs [script] like `dpk run` does: its `depends_on` scripts first, then
  /// the script between its hooks.
  Future<int> runScriptTarget(
    Script script, {
    List<String> arguments = const [],
    List<String> filters = const [],
    int? concurrency,
    bool? failFast,
    bool? dependencyOrder,
  }) async {
    final plan = planFor(
      script,
      filters: filters,
      concurrency: concurrency,
      failFast: failFast,
      dependencyOrder: dependencyOrder,
    );
    return _runWithDependencies(script, plan, arguments: arguments);
  }

  Future<int> _runWithDependencies(
    Script script,
    RunPlan plan, {
    List<String> arguments = const [],
  }) async {
    for (final dependency in script.dependsOn) {
      final exitCode = await _runDependency(dependency, plan);
      if (exitCode != 0) {
        return exitCode;
      }
    }
    return withHooks(
      script.name,
      hooksFrom: script.runHooksFrom,
      (stack) =>
          runScript(script, stack: stack, arguments: arguments, plan: plan),
    );
  }

  /// Runs one `depends_on` entry of a script planned as [dependentPlan], once
  /// per tree of dpk processes.
  Future<int> _runDependency(String dependency, RunPlan dependentPlan) async {
    final project = requireProject;
    if (hookStack.contains(project.rootPath, _dependencyKey(dependency))) {
      console.detail('Skipping dependency "$dependency": it already ran.');
      return 0;
    }
    _startedDependencies.add(dependency);

    final upstream = dependency.startsWith('^');
    final script =
        project.scripts[upstream ? dependency.substring(1) : dependency]!;
    if (!upstream) {
      return _runWithDependencies(script, planFor(script));
    }

    final packages = workspaceDependenciesOf(
      project.workspace,
      dependentPlan.packages,
    );
    if (packages.isEmpty) {
      console.detail(
        'Skipping dependency "$dependency": no workspace package depends on '
        'another.',
      );
      return 0;
    }
    final RunPlan plan;
    try {
      plan = planPackages(
        packages,
        concurrency: script.concurrency,
        failFast: script.failFast ?? false,
        dependencyOrder: true,
      );
    } on RunPlanException catch (e) {
      throw DpkException('Dependency "$dependency": ${e.message}');
    }
    return _runWithDependencies(script, plan);
  }

  /// The packages [script] runs in, from its config and the run options.
  RunPlan planFor(
    Script script, {
    List<String> filters = const [],
    int? concurrency,
    bool? failFast,
    bool? dependencyOrder,
  }) {
    try {
      return planRun(
        workspace: requireProject.workspace,
        runInPackages: script.runInPackages,
        filters: filters,
        concurrency: concurrency ?? script.concurrency,
        failFast: failFast ?? script.failFast ?? false,
        dependencyOrder: dependencyOrder ?? script.dependencyOrder ?? false,
      );
    } on RunPlanException catch (e) {
      throw DpkException('Script "${script.name}": ${e.message}');
    }
  }

  /// Runs [script] without its hooks or dependencies, in the packages of
  /// [plan], or of its own config when [plan] is null.
  Future<int> runScript(
    Script script, {
    required HookStack stack,
    List<String> arguments = const [],
    RunPlan? plan,
  }) {
    final project = requireProject;
    plan ??= planFor(script);

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
      environment: scriptEnvironment({
        ...project.pubEnvironment,
        ..._envFile(script, project),
        ...script.env,
        ...stack.toEnvironment(),
      }),
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
