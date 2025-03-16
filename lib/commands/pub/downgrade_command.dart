import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpm/utils/global_pub_args.dart';
import 'package:dpm/utils/string_extensions.dart';

final class PubDowngradeCommand extends Command {
  @override
  String name = 'downgrade';

  @override
  String get description =>
      'Downgrade the current package\'s dependencies to oldest versions';

  PubDowngradeCommand() {
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
      'tighten',
      help:
          'Updates lower bounds in pubspec.yaml to match the resolved version',
      negatable: false,
    );
  }

  @override
  Future<void> run() async {
    final options = _PubGetOptions.fromArgResults(argResults!);
    final arguments = [
      'pub',
      ...buildGlobalArgs(options),
      'downgrade',
      if (options.offline) '--offline',
      if (options.dryRun) '--dry-run',
      if (options.tighten) '--tighten',
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

final class _PubGetOptions extends PubOptions {
  final bool offline;
  final bool dryRun;
  final bool tighten;

  _PubGetOptions({
    required super.debug,
    required super.directory,
    required super.cacheDir,
    required super.verbose,
    required super.color,

    required this.offline,
    required this.dryRun,
    required this.tighten,
  });

  factory _PubGetOptions.fromArgResults(ArgResults results) {
    return _PubGetOptions(
      debug: results.flag('debug'),
      directory: results.option('directory'),
      cacheDir: results.option('cache-dir')!,
      verbose: results.flag('verbose'),
      color: results['color'] as bool?,
      offline: results.flag('offline'),
      dryRun: results.flag('dry-run'),
      tighten: results.flag('tighten'),
    );
  }

  @override
  String toString() {
    return '''
    PubGetOptions(
      debug: $debug,
      directory: $directory,
      cacheDir: $cacheDir,
      verbose: $verbose,
      color: $color,
      offline: $offline,
      dryRun: $dryRun,
      tighten: $tighten,
    )
    '''.trimIndents();
  }
}
