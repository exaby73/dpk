import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpk/core/mixins/config_mixin.dart';
import 'package:dpk/core/mixins/hook_runner_mixin.dart';
import 'package:dpk/core/mixins/process_handler_mixin.dart';
import 'package:dpk/core/mixins/pub_env_mixin.dart';
import 'package:dpk/utils/globals/global_pub_args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';

part 'remove_command.freezed.dart';

final class RemoveCommand extends Command<int>
    with ConfigMixin, PubEnvMixin, ProcessHandlerMixin, HookRunnerMixin {
  @override
  String name = 'remove';

  @override
  String get description => 'Remove dependencies from `pubspec.yaml`';

  final logger = Logger('pub.remove');

  RemoveCommand() {
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
      'precompile',
      help: 'Build executables in immediate dependencies',
    );
  }

  @override
  Future<int> run() async {
    final options = PubRemoveOptions.fromArgResults(argResults!);
    final arguments = [
      'pub',
      ...buildGlobalArgs(options.globalPubOptions),
      'remove',
      if (options.offline) '--offline',
      if (options.dryRun) '--dry-run',
      if (options.precompile) '--precompile',
      ...argResults!.rest,
    ];

    final preHookExitCode = await runPreHook(
      commandName: 'remove',
      globalOptions: options.globalPubOptions.globalOptions,
    );
    if (preHookExitCode != 0) {
      return preHookExitCode;
    }

    if (options.globalPubOptions.globalOptions.verbose) {
      logger.info('Running: dart ${arguments.join(' ')}');
    }

    final pubProcess = await Process.start(
      'dart',
      arguments,
      environment: getCacheEnv(options.globalPubOptions.cacheDir),
    );

    stdout.addStream(pubProcess.stdout);
    stderr.addStream(pubProcess.stderr);

    final exitCode = await pubProcess.exitCode;

    if (exitCode != 0) {
      return exitCode;
    }

    final postHookExitCode = await runPostHook(
      commandName: 'remove',
      globalOptions: options.globalPubOptions.globalOptions,
    );
    return postHookExitCode;
  }
}

@freezed
abstract class PubRemoveOptions with _$PubRemoveOptions {
  const factory PubRemoveOptions({
    required GlobalPubOptions globalPubOptions,
    required bool offline,
    required bool dryRun,
    required bool precompile,
  }) = _PubRemoveOptions;

  factory PubRemoveOptions.fromArgResults(ArgResults results) {
    return PubRemoveOptions(
      globalPubOptions: GlobalPubOptions.fromArgResults(results),
      offline: results.flag('offline'),
      dryRun: results.flag('dry-run'),
      precompile: results.flag('precompile'),
    );
  }
}
