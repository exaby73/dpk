import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpm/utils/global_pub_args.dart';
import 'package:dpm/utils/string_extensions.dart';

final class PubUpgradeCommand extends Command {
  @override
  String name = 'upgrade';

  @override
  List<String> aliases = ['update'];

  @override
  String get description => 'Upgrade dependencies';

  PubUpgradeCommand() {
    addGlobalPubArgs(argParser);
    argParser.addFlag(
      'offline',
      help: 'Use cached packages instead of accessing the network',
    );
    argParser.addFlag(
      'dry-run',
      abbr: 'n',
      help: 'Report what dependencies would change but don\'t change any',
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
    final options = _PubUpgradeOptions.fromArgResults(argResults!);
    final arguments = [
      'pub',
      ...buildGlobalArgs(options),
      'upgrade',
      if (options.offline) '--offline',
      if (options.dryRun) '--dry-run',
      if (options.precompile) '--precompile',
      if (options.tighten) '--tighten',
      if (options.unlockTransitive) '--unlock-transitive',
      if (options.majorVersions) '--major-versions',
      ...argResults!.rest,
    ];

    if (options.isVerbose) {
      print('Running: dart ${arguments.join(' ')}');
    }

    final pubProcess = await Process.start(
      'dart',
      arguments,
      environment: {'PUB_CACHE': options.cacheDir},
    );

    pubProcess.stdout.transform(utf8.decoder).listen((data) {
      stdout.write(data);
    });

    pubProcess.stderr.transform(utf8.decoder).listen((data) {
      stderr.write(data);
    });

    final exitCode = await pubProcess.exitCode;

    exit(exitCode);
  }
}

final class _PubUpgradeOptions extends PubOptions {
  final bool offline;
  final bool dryRun;
  final bool precompile;
  final bool tighten;
  final bool unlockTransitive;
  final bool majorVersions;

  _PubUpgradeOptions({
    required super.debug,
    required super.directory,
    required super.cacheDir,
    required super.patchDir,
    required super.verbose,
    required super.color,

    required this.offline,
    required this.dryRun,
    required this.precompile,
    required this.tighten,
    required this.unlockTransitive,
    required this.majorVersions,
  });

  factory _PubUpgradeOptions.fromArgResults(ArgResults results) {
    return _PubUpgradeOptions(
      debug: results.flag('debug'),
      directory: results.option('directory'),
      cacheDir: results.option('cache-dir')!,
      patchDir: results.option('patch-dir')!,
      verbose: results.flag('verbose'),
      color: results['color'] as bool?,

      offline: results.flag('offline'),
      dryRun: results.flag('dry-run'),
      precompile: results.flag('precompile'),
      tighten: results.flag('tighten'),
      unlockTransitive: results.flag('unlock-transitive'),
      majorVersions: results.flag('major-versions'),
    );
  }

  @override
  String toString() {
    return '''
    PubUpgradeOptions(
      debug: $debug,
      directory: $directory,
      cacheDir: $cacheDir,
      patchDir: $patchDir,
      verbose: $verbose,
      color: $color,
      offline: $offline,
      dryRun: $dryRun,
      precompile: $precompile,
      tighten: $tighten,
      unlockTransitive: $unlockTransitive,
      majorVersions: $majorVersions,
    )
    '''.trimIndents();
  }
}
