import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpm/utils/global_args.dart';
import 'package:dpm/utils/string_extensions.dart';

final class PubDowngradeCommand extends Command {
  @override
  String name = 'downgrade';

  @override
  String get description =>
      'Downgrade the current package\'s dependencies to oldest versions';

  PubDowngradeCommand() {
    addGlobalArgs(argParser);
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
    required super.verbose,
    required super.directory,
    required super.color,
    required super.cacheDir,

    required this.offline,
    required this.dryRun,
    required this.tighten,
  });

  factory _PubGetOptions.fromArgResults(ArgResults results) {
    return _PubGetOptions(
      debug: results.flag('debug'),
      verbose: results.flag('verbose'),
      directory: results.option('directory'),
      color: results['color'] as bool?,
      cacheDir: results.option('cache-dir')!,
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
      verbose: $verbose,
      directory: $directory,
      color: $color,
      cacheDir: $cacheDir,
      offline: $offline,
      dryRun: $dryRun,
      tighten: $tighten,
    )
    '''.trimIndents();
  }
}
