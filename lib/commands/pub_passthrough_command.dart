import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpk/core/mixins/config_mixin.dart';
import 'package:dpk/core/mixins/hook_runner_mixin.dart';
import 'package:dpk/core/mixins/process_handler_mixin.dart';
import 'package:dpk/core/mixins/pub_env_mixin.dart';
import 'package:dpk/utils/globals/global_args.dart';
import 'package:dpk/utils/globals/global_pub_args.dart';
import 'package:logging/logging.dart';

final class PubPassthroughCommand extends Command<int>
    with ConfigMixin, PubEnvMixin, ProcessHandlerMixin, HookRunnerMixin {
  final String commandName;
  final String commandDescription;

  @override
  final ArgParser argParser = ArgParser.allowAnything();

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  final logger = Logger('pub.passthrough');

  PubPassthroughCommand({
    required this.commandName,
    required this.commandDescription,
  });

  @override
  Future<int> run() async {
    final options = GlobalPubOptions(
      globalOptions: GlobalOptions.fromArgResults(globalResults!),
      cacheDir: globalResults!.option('cache-dir')!,
      color: null,
    );
    final targetDirectory =
        options.globalOptions.directory ?? config.workingDirectory;
    final arguments = [
      'pub',
      ...buildGlobalArgs(options),
      commandName,
      ...argResults!.rest,
    ];

    final preHookExitCode = await runPreHook(
      commandName: commandName,
      globalOptions: options.globalOptions,
    );
    if (preHookExitCode != 0) {
      return preHookExitCode;
    }

    if (options.globalOptions.isVerbose) {
      logger.info('Running: dart ${arguments.join(' ')}');
    }

    final exitCode = await runDartProcess(
      arguments: arguments,
      workingDirectory: targetDirectory,
      environment: getCacheEnv(options.cacheDir),
    );
    if (exitCode != 0) {
      return exitCode;
    }

    final postHookExitCode = await runPostHook(
      commandName: commandName,
      globalOptions: options.globalOptions,
    );
    return postHookExitCode;
  }
}
