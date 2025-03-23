import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:dpm/utils/command_checker.dart';
import 'package:dpm/core/constants.dart';
import 'package:dpm/utils/global_args.dart';
import 'package:path/path.dart';

part 'apply_command.mapper.dart';

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
    final options = ApplyOptions.fromArgResults(argResults!);
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
      stderr.writeln(
        'Patch directory does not exist. Did you run `$executableName patch generate`?',
      );
      exit(1);
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

    for (final gitDep in Directory(join(options.cacheDir, 'git')).listSync()) {
      if (basename(gitDep.path) == 'cache') {
        continue;
      }

      final result = await Process.run('git', [
        'checkout',
        '.',
      ], workingDirectory: gitDep.path);

      if (result.exitCode != 0) {
        stderr.writeln(
          'Failed to apply git dependency ${basename(gitDep.path)}:\n${result.stderr}',
        );
        exit(1);
      }
    }

    final hostedPatchesDir = Directory(join(patchDir.path, 'hosted'));
    final gitPatchesDir = Directory(join(patchDir.path, 'git'));

    final hostedPatches =
        hostedPatchesDir.existsSync()
            ? hostedPatchesDir.listSync().whereType<File>()
            : <File>[];
    final gitPatches =
        gitPatchesDir.existsSync()
            ? gitPatchesDir.listSync().whereType<File>()
            : <File>[] as Iterable<File>;

    if (hostedPatches.isEmpty && gitPatches.isEmpty) {
      stderr.writeln('No patches to apply');
      exit(0);
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

@MappableClass()
final class ApplyOptions extends GlobalOptions with ApplyOptionsMappable {
  final bool force;

  ApplyOptions({
    required super.debug,
    required super.directory,
    required super.cacheDir,
    required super.patchDir,

    required this.force,
  });

  factory ApplyOptions.fromArgResults(ArgResults results) {
    return ApplyOptions(
      debug: results.flag('debug'),
      directory: results.option('directory'),
      cacheDir: results.option('cache-dir')!,
      patchDir: results.option('patch-dir')!,
      force: results.flag('force'),
    );
  }
}
