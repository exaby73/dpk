import 'package:args/args.dart';
import 'package:dpk/commands/dpk_command.dart';
import 'package:dpk/commands/run_command.dart';
import 'package:dpk/core/errors.dart';
import 'package:dpk/core/shell.dart';
import 'package:dpk/scripts/run_plan.dart';
import 'package:dpk/scripts/script_executor.dart';
import 'package:dpk/utils/terminal_title.dart';

final class ExecCommand extends DpkCommand {
  ExecCommand(super.context) {
    addPackageSelectionOptions(argParser);
  }

  @override
  final ArgParser argParser = ArgParser(allowTrailingOptions: false);

  @override
  String get name => 'exec';

  @override
  String get description =>
      'Run a shell command in every workspace package, or in those --filter '
      'selects.';

  @override
  String get category => CommandCategory.workspace;

  @override
  String get invocation => 'dpk exec [options] [--] <command> [arguments]';

  @override
  String get usageFooter =>
      '\nA single argument runs as a shell command line, so '
      '"dpk exec \'dart test && dart analyze\'" works. Several arguments run '
      'as one command with each argument quoted.';

  @override
  bool get takesArguments => true;

  @override
  Future<int> run() async {
    final words = argResults!.rest;
    if (words.isEmpty) {
      usageException('Give the command to run.');
    }
    final command = words.length == 1
        ? words.single
        : withArguments(words.first, words.sublist(1));
    final selection = packageSelection(argResults!);
    final project = context.requireProject;

    final RunPlan plan;
    try {
      plan = planRun(
        workspace: project.workspace,
        filters: selection.filters,
        allPackagesByDefault: true,
        concurrency: selection.concurrency,
        failFast: selection.failFast ?? false,
        dependencyOrder: selection.dependencyOrder ?? false,
      );
    } on RunPlanException catch (e) {
      throw DpkException(e.message);
    }

    return withTerminalTitle(
      console,
      'dpk exec',
      () => context.withHooks('exec', (stack) {
        console.step(
          '> exec in ${plan.packages.length} '
          'package${plan.packages.length == 1 ? '' : 's'}: $command',
        );
        return ScriptExecutor(
          processRunner: context.processRunner,
          console: console,
          workspace: project.workspace,
        ).execute(
          plan,
          command,
          environment: context.scriptEnvironment({
            ...project.pubEnvironment,
            ...stack.toEnvironment(),
          }),
        );
      }),
    );
  }
}
