import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpm/core/constants.dart';
import 'package:dpm/core/mixins/cache_mixin.dart';
import 'package:dpm/core/mixins/config_mixin.dart';
import 'package:dpm/utils/command_checker.dart';
import 'package:dpm/utils/globals/global_patch_args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart';

part 'apply_command.freezed.dart';

final class PatchApplyCommand extends Command with ConfigMixin, CacheMixin {
  @override
  String name = 'apply';

  @override
  String get description => 'Apply patches';

  PatchApplyCommand() {
    addGlobalPatchArgs(argParser);

    argParser.addFlag('force', help: 'Force apply patches', negatable: false);
  }

  @override
  Future<void> run() async {
    if (!isProjectCache) {
      stderr.writeln('Project cache is not supported for global mode');
      exit(1);
    }

    final options = ApplyOptions.fromArgResults(argResults!);
    final cacheDir = Directory(options.globalPatchOptions.cacheDir);

    if (!cacheDir.existsSync()) {
      stderr.writeln(
        '${options.globalPatchOptions.cacheDir} does not exist. Did you run `$kExecutableName pub get`?',
      );
      exit(1);
    }

    if (!(await gitExists())) {
      stderr.writeln('Git is not installed');
      exit(1);
    }

    final patchDir = Directory(options.globalPatchOptions.patchDir);
    if (!patchDir.existsSync()) {
      stderr.writeln(
        'Patch directory does not exist. Did you run `$kExecutableName patch generate`?',
      );
      exit(1);
    }

    final checkoutResult = await Process.run('git', [
      'checkout',
      '.',
    ], workingDirectory: options.globalPatchOptions.cacheDir);

    if (checkoutResult.exitCode != 0) {
      stderr.writeln(
        'Failed to apply. Did you run `$kExecutableName patch init`?',
      );
      exit(1);
    }

    for (final gitDep
        in Directory(
          join(options.globalPatchOptions.cacheDir, 'git'),
        ).listSync()) {
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
      ], workingDirectory: options.globalPatchOptions.cacheDir);

      if (result.exitCode != 0) {
        stderr.writeln(
          'Failed to apply patch ${patch.path}:\n${result.stderr}',
        );
        exit(1);
      }
    }

    for (final patch in gitPatches) {
      final workingDir = join(
        options.globalPatchOptions.cacheDir,
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

@freezed
abstract class ApplyOptions with _$ApplyOptions {
  const factory ApplyOptions({
    required GlobalPatchOptions globalPatchOptions,
    required bool force,
  }) = _ApplyOptions;

  factory ApplyOptions.fromArgResults(ArgResults results) {
    return ApplyOptions(
      globalPatchOptions: GlobalPatchOptions.fromArgResults(results),
      force: results.flag('force'),
    );
  }
}
