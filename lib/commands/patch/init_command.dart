import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:dpm/utils/command_checker.dart';
import 'package:dpm/utils/constants.dart';
import 'package:dpm/utils/global_args.dart';
import 'package:dpm/utils/string_extensions.dart';
import 'package:path/path.dart';

final class PatchInitCommand extends Command {
  @override
  String name = 'init';

  @override
  String get description => 'Initialize patch';

  PatchInitCommand() {
    addGlobalArgs(argParser);

    argParser.addFlag(
      'force',
      help: 'Force reinitialize patch',
      negatable: false,
    );
  }

  @override
  Future<void> run() async {
    final options = _PatchOptions.fromArgResults(argResults!);
    final cacheDir = Directory(options.cacheDir);

    if (!cacheDir.existsSync()) {
      stderr.writeln(
        '${options.cacheDir} does not exist. Did you run `$executableName pub get`?',
      );
      exit(1);
    }

    if (!(await gitExists())) {
      stderr.writeln('Git is not installed');
      exit(1);
    }

    // dart format off
    final dotGitDir = Directory(options.cacheDir)
      .listSync()
      .firstWhereOrNull((entity) => basename(entity.path) == '.git')
      as Directory?;
    // dart format on
    final dotGitExists = dotGitDir != null;

    if (dotGitExists && !options.force) {
      stderr.writeln(
        'Patch is already initialized. Run with --force to initialize from scratch',
      );
      exit(1);
    }

    if (dotGitExists && options.force) {
      await dotGitDir.delete(recursive: true);
    }

    await Process.run('git', ['init'], workingDirectory: options.cacheDir);
    stdout.writeln('Patch initialized');

    exit(0);
  }
}

final class _PatchOptions extends GlobalOptions {
  final bool force;

  _PatchOptions({
    required super.debug,
    required super.directory,
    required super.cacheDir,

    required this.force,
  });

  factory _PatchOptions.fromArgResults(ArgResults results) {
    return _PatchOptions(
      debug: results.flag('debug'),
      directory: results.option('directory'),
      cacheDir: results.option('cache-dir')!,
      force: results.flag('force'),
    );
  }

  @override
  String toString() {
    return '''
    _PatchOptions(
      debug: $debug,
      directory: $directory,
      cacheDir: $cacheDir,
      force: $force,
    )
    '''.trimIndents();
  }
}
