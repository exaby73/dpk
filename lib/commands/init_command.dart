import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpk/constants/pubspec.dart';
import 'package:dpk/core/constants.dart';
import 'package:dpk/utils/globals/global_args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' as path;

part 'init_command.freezed.dart';

final class InitCommand extends Command<int> {
  @override
  String name = 'init';

  @override
  String get description => 'Initialize dpk.yaml';

  InitCommand() {
    addGlobalArgs(argParser);
    argParser.addOption(
      'mode',
      allowed: ['global', 'project'],
      defaultsTo: 'global',
      help: 'Package cache mode to write to dpk.yaml',
    );
    argParser.addOption(
      'version-constraint',
      defaultsTo: defaultVersionConstraint,
      help: 'dpk version constraint to write to dpk.yaml',
    );
    argParser.addFlag(
      'force',
      abbr: 'f',
      negatable: false,
      help: 'Overwrite an existing dpk.yaml',
    );
  }

  static String get defaultVersionConstraint =>
      '^${dpkVersion.major}.${dpkVersion.minor}.0';

  @override
  Future<int> run() async {
    final options = InitOptions.fromArgResults(
      argResults!,
      globalResults: globalResults,
    );
    final targetDirectory = Directory(
      options.globalOptions.directory ?? Directory.current.path,
    ).absolute;

    final pubspecFile = File(path.join(targetDirectory.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      stderr.writeln('pubspec.yaml not found in ${targetDirectory.path}');
      return 1;
    }

    final configFile = File(path.join(targetDirectory.path, kConfigFileName));
    if (configFile.existsSync() && !options.force) {
      stderr.writeln(
        '$kConfigFileName already exists in ${targetDirectory.path}. '
        'Re-run with --force to overwrite it.',
      );
      return 1;
    }

    await configFile.writeAsString(_renderConfig(options));
    stdout.writeln('Created ${configFile.path}');
    return 0;
  }

  String _renderConfig(InitOptions options) {
    final buffer = StringBuffer()
      ..writeln('version: ${options.versionConstraint}');

    if (options.mode == 'project') {
      buffer.writeln('mode: project');
    }

    return buffer.toString();
  }
}

@freezed
abstract class InitOptions with _$InitOptions {
  const factory InitOptions({
    required GlobalOptions globalOptions,
    required String mode,
    required String versionConstraint,
    required bool force,
  }) = _InitOptions;

  factory InitOptions.fromArgResults(
    ArgResults results, {
    ArgResults? globalResults,
  }) {
    final localGlobalOptions = GlobalOptions.fromArgResults(results);
    final topLevelGlobalOptions = globalResults != null
        ? GlobalOptions.fromArgResults(globalResults)
        : null;

    return InitOptions(
      globalOptions: GlobalOptions(
        directory:
            localGlobalOptions.directory ?? topLevelGlobalOptions?.directory,
        verbose:
            localGlobalOptions.verbose ||
            (topLevelGlobalOptions?.verbose ?? false),
        debug:
            localGlobalOptions.debug || (topLevelGlobalOptions?.debug ?? false),
      ),
      mode: results.option('mode')!,
      versionConstraint: results.option('version-constraint')!,
      force: results.flag('force'),
    );
  }
}
