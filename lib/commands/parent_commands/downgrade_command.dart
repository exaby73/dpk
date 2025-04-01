import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpk/core/mixins/cache_mixin.dart';
import 'package:dpk/core/mixins/config_mixin.dart';
import 'package:dpk/utils/globals/global_pub_args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';

part 'downgrade_command.freezed.dart';

final class DowngradeCommand extends Command with ConfigMixin, CacheMixin {
  @override
  String name = 'downgrade';

  @override
  String get description =>
      "Downgrade the current package's dependencies to oldest versions";

  final logger = Logger('pub.downgrade');

  DowngradeCommand() {
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
      'tighten',
      help:
          'Updates lower bounds in pubspec.yaml to match the resolved version',
      negatable: false,
    );
  }

  @override
  Future<void> run() async {
    final options = PubDowngradeOptions.fromArgResults(argResults!);
    final arguments = [
      'pub',
      ...buildGlobalArgs(options.globalPubOptions),
      'downgrade',
      if (options.offline) '--offline',
      if (options.dryRun) '--dry-run',
      if (options.tighten) '--tighten',
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
abstract class PubDowngradeOptions with _$PubDowngradeOptions {
  const factory PubDowngradeOptions({
    required GlobalPubOptions globalPubOptions,
    required bool offline,
    required bool dryRun,
    required bool tighten,
  }) = _PubDowngradeOptions;

  factory PubDowngradeOptions.fromArgResults(ArgResults results) {
    return PubDowngradeOptions(
      globalPubOptions: GlobalPubOptions.fromArgResults(results),
      offline: results.flag('offline'),
      dryRun: results.flag('dry-run'),
      tighten: results.flag('tighten'),
    );
  }
}
