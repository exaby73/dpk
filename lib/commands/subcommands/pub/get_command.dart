import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpm/commands/run_command.dart';
import 'package:dpm/config/data/scripts.dart';
import 'package:dpm/core/config_mixin.dart';
import 'package:dpm/utils/globals/global_pub_args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';

part 'get_command.freezed.dart';

final class PubGetCommand extends Command with ConfigMixin {
  @override
  String name = 'get';

  @override
  String get description => 'Get dependencies';

  final logger = Logger('pub.get');

  PubGetCommand() {
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
  Future<void> run() async {
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

    final preHookRunner = DpmScriptRunner(
      config: config,
      arguments: [],
      options: RunOptions(
        globalOptions: options.globalPubOptions.globalOptions,
        script: HookType.preget.name,
      ),
    );

    final preHookExitCode = await preHookRunner.run(skipIfMissing: true);
    if (preHookExitCode != 0) {
      exit(preHookExitCode);
    }

    if (options.globalPubOptions.globalOptions.isVerbose) {
      logger.info('Running: dart ${arguments.join(' ')}');
    }

    final pubProcess = await Process.start(
      'dart',
      arguments,
      environment: {'PUB_CACHE': options.globalPubOptions.cacheDir},
    );

    stdout.addStream(pubProcess.stdout);
    stderr.addStream(pubProcess.stderr);

    final exitCode = await pubProcess.exitCode;

    if (exitCode != 0) {
      exit(exitCode);
    }

    final postHookRunner = DpmScriptRunner(
      config: config,
      arguments: [],
      options: RunOptions(
        globalOptions: options.globalPubOptions.globalOptions,
        script: HookType.postget.name,
      ),
    );

    final postHookExitCode = await postHookRunner.run(skipIfMissing: true);
    exit(postHookExitCode);
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
