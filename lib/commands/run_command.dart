import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpk/commands/dpk_command.dart';
import 'package:dpk/config/dpk_config.dart';
import 'package:dpk/core/context.dart';
import 'package:dpk/utils/terminal_title.dart';

/// Adds the options that choose and schedule workspace packages.
void addPackageSelectionOptions(ArgParser parser) {
  parser
    ..addMultiOption(
      'filter',
      valueHelp: 'package',
      help:
          'Only run in workspace packages with this name or a path matching '
          'this glob. Repeat to select more.',
    )
    ..addOption(
      'concurrency',
      abbr: 'j',
      valueHelp: 'count',
      help: 'Run in at most this many packages at once. Default: all at once.',
    )
    ..addFlag(
      'fail-fast',
      negatable: false,
      help: 'Stop the remaining packages when one fails.',
    )
    ..addFlag(
      'dependency-order',
      negatable: false,
      help:
          'Start a package only after the workspace packages it depends on '
          'have finished.',
    );
}

/// Reads the package selection options from [results]. Throws a
/// [UsageException] when `--concurrency` is not a whole number of at least 1.
({
  List<String> filters,
  int? concurrency,
  bool? failFast,
  bool? dependencyOrder,
})
packageSelection(ArgResults results) {
  final rawConcurrency = results.option('concurrency');
  final concurrency = rawConcurrency == null
      ? null
      : int.tryParse(rawConcurrency);
  if (rawConcurrency != null && (concurrency == null || concurrency < 1)) {
    throw UsageException(
      '--concurrency needs a whole number of at least 1, got '
          '"$rawConcurrency".',
      '',
    );
  }
  return (
    filters: results.multiOption('filter'),
    concurrency: concurrency,
    failFast: results.flag('fail-fast') ? true : null,
    dependencyOrder: results.flag('dependency-order') ? true : null,
  );
}

final class RunCommand extends DpkCommand {
  RunCommand(super.context) {
    addPackageSelectionOptions(argParser);
    for (final script in context.project?.scripts.values ?? <Script>[]) {
      addSubcommand(ScriptCommand(context, script));
    }
  }

  @override
  String get name => 'run';

  @override
  String get description => 'Run a script from dpk.yaml.';

  @override
  String get category => CommandCategory.workspace;

  @override
  String get invocation => 'dpk run [options] <script> [arguments]';

  @override
  String get usageFooter =>
      '\nEvery argument after the script name is passed to the script.';

  @override
  void printUsage() => console.info(listing());

  /// The scripts and hooks in the project, followed by the run options.
  String listing() {
    final scripts = context.project?.scripts.values.toList() ?? const [];
    final runnable = scripts.where((script) => !script.isHook).toList();
    final hooks = scripts.where((script) => script.isHook).toList();
    final width = scripts.fold(
      0,
      (w, s) => s.name.length > w ? s.name.length : w,
    );

    String line(Script script) {
      final summary = script.description ?? console.dim(script.command);
      final scope = script.runInPackages == null
          ? ''
          : console.dim(' (in ${script.runInPackages!.join(', ')})');
      final needs = script.dependsOn.isEmpty
          ? ''
          : console.dim(' (depends on ${script.dependsOn.join(', ')})');
      return '  ${console.bold(script.name.padRight(width))}  '
          '$summary$scope$needs';
    }

    String hookLine(Script hook) {
      final targets = hook.all
          ? 'every command and script'
          : (hook.hookTargets?.join(', ') ?? 'nothing');
      final summary = isSharedHookName(hook.name)
          ? 'runs ${hook.name} $targets'
          : (hook.description ?? hook.command);
      return '  ${console.bold(hook.name.padRight(width))}  ${console.dim(summary)}';
    }

    return [
      'Usage: $invocation',
      '',
      if (runnable.isEmpty)
        'No scripts are defined in dpk.yaml.'
      else ...[
        'Scripts:',
        for (final script in runnable) line(script),
      ],
      if (hooks.isNotEmpty) ...[
        '',
        'Hooks:',
        for (final hook in hooks) hookLine(hook),
      ],
      '',
      argParser.usage,
      usageFooter.trimLeft(),
    ].join('\n');
  }
}

/// Runs one script. Its parser accepts anything, so every argument after the
/// script name reaches the script unchanged.
final class ScriptCommand extends Command<int> {
  ScriptCommand(this.context, this.script);

  final DpkContext context;
  final Script script;

  @override
  final ArgParser argParser = ArgParser.allowAnything();

  @override
  String get name => script.name;

  @override
  String get description => script.description ?? script.command;

  @override
  bool get hidden => script.isHook;

  @override
  bool get takesArguments => true;

  @override
  Future<int> run() {
    final selection = packageSelection(parent!.argResults!);
    var arguments = argResults!.rest;
    if (arguments.firstOrNull == '--') {
      arguments = arguments.sublist(1);
    }

    return withTerminalTitle(
      context.console,
      'dpk run ${script.name}',
      () => context.runScriptTarget(
        script,
        arguments: arguments,
        filters: selection.filters,
        concurrency: selection.concurrency,
        failFast: selection.failFast,
        dependencyOrder: selection.dependencyOrder,
      ),
    );
  }
}
