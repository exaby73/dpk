import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpm/core/mixins/cache_mixin.dart';
import 'package:dpm/core/mixins/config_mixin.dart';
import 'package:dpm/utils/globals/global_pub_args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
part 'upgrade_command.freezed.dart';

final class PubUpgradeCommand extends Command with ConfigMixin, CacheMixin {
  @override
  String name = 'upgrade';

  @override
  List<String> aliases = ['update'];

  @override
  String get description => 'Upgrade dependencies';

  final logger = Logger('pub.upgrade');

  PubUpgradeCommand() {
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
    argParser.addFlag(
      'tighten',
      help:
          'Updates lower bounds in pubspec.yaml to match the resolved version',
      negatable: false,
    );
    argParser.addFlag(
      'unlock-transitive',
      help:
          'Also upgrades the transitive dependencies of the listed dependencies',
      negatable: false,
    );
    argParser.addFlag(
      'major-versions',
      help:
          'Upgrades packages to their latest resolvable versions, and updates pubspec.yaml',
      negatable: false,
    );
  }

  @override
  Future<void> run() async {
    final options = PubUpgradeOptions.fromArgResults(argResults!);
    final arguments = [
      'pub',
      ...buildGlobalArgs(options.globalPubOptions),
      'upgrade',
      if (options.offline) '--offline',
      if (options.dryRun) '--dry-run',
      if (options.precompile) '--precompile',
      if (options.tighten) '--tighten',
      if (options.unlockTransitive) '--unlock-transitive',
      if (options.majorVersions) '--major-versions',
      ...argResults!.rest,
    ];

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

    exit(exitCode);
  }
}

@freezed
abstract class PubUpgradeOptions with _$PubUpgradeOptions {
  const factory PubUpgradeOptions({
    required GlobalPubOptions globalPubOptions,
    required bool offline,
    required bool dryRun,
    required bool precompile,
    required bool tighten,
    required bool unlockTransitive,
    required bool majorVersions,
  }) = _PubUpgradeOptions;

  factory PubUpgradeOptions.fromArgResults(ArgResults results) {
    return PubUpgradeOptions(
      globalPubOptions: GlobalPubOptions.fromArgResults(results),
      offline: results.flag('offline'),
      dryRun: results.flag('dry-run'),
      precompile: results.flag('precompile'),
      tighten: results.flag('tighten'),
      unlockTransitive: results.flag('unlock-transitive'),
      majorVersions: results.flag('major-versions'),
    );
  }
}
