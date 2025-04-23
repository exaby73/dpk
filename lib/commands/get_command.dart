import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpk/commands/run_command.dart';
import 'package:dpk/config/data/scripts.dart';
import 'package:dpk/core/mixins/config_mixin.dart';
import 'package:dpk/core/mixins/process_handler_mixin.dart';
import 'package:dpk/core/mixins/pub_env_mixin.dart';
import 'package:dpk/utils/globals/global_pub_args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';

part 'get_command.freezed.dart';

final class GetCommand extends Command<int>
    with ConfigMixin, PubEnvMixin, ProcessHandlerMixin {
  @override
  String name = 'get';

  @override
  String get description => 'Get dependencies';

  final logger = Logger('pub.get');

  GetCommand() {
    addGlobalPubArgs(argParser);
    argParser.addFlag(
      'offline',
      help: 'Use cached packages instead of accessing the network',
    );
    argParser.addFlag(
      'dry-run',
      abbr: 'n',
      help: "Report what dependencies would change but don't change any",
    );
    argParser.addFlag(
      'enforce-lockfile',
      help:
          'Enforce pubspec.lock. Fail `pub get` if the current `pubspec.lock` '
          'does not exactly specify a valid resolution of `pubspec.yaml` '
          'or if any content hash of a hosted package has changed. '
          'Useful for CI or deploying to production',
      negatable: false,
    );
    argParser.addFlag(
      'precompile',
      help: 'Build executables in immediate dependencies',
    );
  }

  @override
  Future<int> run() async {
    final options = PubGetOptions.fromArgResults(argResults!);
    final arguments = [
      'pub',
      ...buildGlobalArgs(options.globalPubOptions),
      'get',
      if (options.offline) '--offline',
      if (options.dryRun) '--dry-run',
      if (options.enforceLockfile) '--enforce-lockfile',
      if (options.precompile) '--precompile',
      ...argResults!.rest,
    ];

    final preHookRunner = DpkScriptRunner(
      config: config,
      arguments: [],
      options: RunOptions(
        globalOptions: options.globalPubOptions.globalOptions,
        script: HookType.preget.name,
      ),
    );

    final preHookExitCode = await preHookRunner.run(skipIfMissing: true);
    if (preHookExitCode != 0) {
      return preHookExitCode;
    }

    if (options.globalPubOptions.globalOptions.isVerbose) {
      logger.info('Running: dart ${arguments.join(' ')}');
    }

    final exitCode = await runDartProcess(
      arguments: arguments,
      workingDirectory: options.globalPubOptions.globalOptions.directory,
      environment: getCacheEnv(options.globalPubOptions.cacheDir),
    );

    if (exitCode != 0) {
      return exitCode;
    }

    final postHookRunner = DpkScriptRunner(
      config: config,
      arguments: [],
      options: RunOptions(
        globalOptions: options.globalPubOptions.globalOptions,
        script: HookType.postget.name,
      ),
    );

    final postHookExitCode = await postHookRunner.run(skipIfMissing: true);
    return postHookExitCode;
  }
}

@freezed
abstract class PubGetOptions with _$PubGetOptions {
  const factory PubGetOptions({
    required GlobalPubOptions globalPubOptions,
    required bool offline,
    required bool dryRun,
    required bool enforceLockfile,
    required bool precompile,
  }) = _PubGetOptions;

  factory PubGetOptions.fromArgResults(ArgResults results) {
    return PubGetOptions(
      globalPubOptions: GlobalPubOptions.fromArgResults(results),
      offline: results.flag('offline'),
      dryRun: results.flag('dry-run'),
      enforceLockfile: results.flag('enforce-lockfile'),
      precompile: results.flag('precompile'),
    );
  }
}
