import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpm/utils/command_checker.dart';
import 'package:dpm/utils/constants.dart';
import 'package:dpm/utils/global_args.dart';
import 'package:dpm/utils/string_extensions.dart';
import 'package:path/path.dart';

final class PatchApplyCommand extends Command {
  @override
  String name = 'apply';

  @override
  String get description => 'Apply patches';

  PatchApplyCommand() {
    addGlobalArgs(argParser);

    argParser.addFlag('force', help: 'Force apply patches', negatable: false);
  }

  @override
  Future<void> run() async {
    final options = _ApplyOptions.fromArgResults(argResults!);
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

    final patchDir = Directory(options.patchDir);
    if (!patchDir.existsSync()) {
      stderr.writeln('Patch directory does not exist');
      exit(1);
    }

    final hostedPatchesDir = Directory(join(patchDir.path, 'hosted'));
    final gitPatchesDir = Directory(join(patchDir.path, 'git'));

    final hostedPatches = hostedPatchesDir.listSync().whereType<File>();
    final gitPatches = gitPatchesDir.listSync().whereType<File>();

    if (hostedPatches.isEmpty && gitPatches.isEmpty) {
      stderr.writeln('No patches to apply');
      exit(0);
    }

    final checkoutResult = await Process.run('git', [
      'checkout',
      '.',
    ], workingDirectory: options.cacheDir);

    if (checkoutResult.exitCode != 0) {
      stderr.writeln(
        'Failed to apply. Did you run `$executableName patch init`?',
      );
      exit(1);
    }

    for (final patch in hostedPatches) {
      final result = await Process.run('git', [
        'apply',
        patch.path,
      ], workingDirectory: options.cacheDir);

      if (result.exitCode != 0) {
        stderr.writeln(
          'Failed to apply patch ${patch.path}:\n${result.stderr}',
        );
        exit(1);
      }
    }

    for (final patch in gitPatches) {
      final workingDir = join(
        options.cacheDir,
        'git',
        basenameWithoutExtension(patch.path),
      );

      final checkoutResult = await Process.run('git', [
        'checkout',
        '.',
      ], workingDirectory: workingDir);

      if (checkoutResult.exitCode != 0) {
        stderr.writeln(
          'Failed to apply patch ${patch.path}:\n${checkoutResult.stderr}',
        );
        exit(1);
      }

      final result = await Process.run('git', [
        'apply',
        patch.path,
      ], workingDirectory: workingDir);

      if (result.exitCode != 0) {
        stderr.writeln(
          'Failed to apply patch ${patch.path}:\n${result.stderr}',
        );
        exit(1);
      }
    }

    exit(0);
  }
}

final class _ApplyOptions extends GlobalOptions {
  final bool force;

  _ApplyOptions({
    required super.debug,
    required super.directory,
    required super.cacheDir,
    required super.patchDir,

    required this.force,
  });

  factory _ApplyOptions.fromArgResults(ArgResults results) {
    return _ApplyOptions(
      debug: results.flag('debug'),
      directory: results.option('directory'),
      cacheDir: results.option('cache-dir')!,
      patchDir: results.option('patch-dir')!,
      force: results.flag('force'),
    );
  }

  @override
  String toString() {
    return '''
    _ApplyOptions(
      debug: $debug,
      directory: $directory,
      cacheDir: $cacheDir,
      patchDir: $patchDir,
      force: $force,
    )
    '''.trimIndents();
  }
}
