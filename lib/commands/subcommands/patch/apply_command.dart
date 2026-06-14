import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpk/core/constants.dart';
import 'package:dpk/core/mixins/config_mixin.dart';
import 'package:dpk/core/mixins/pub_env_mixin.dart';
import 'package:dpk/utils/command_checker.dart';
import 'package:dpk/utils/globals/global_patch_args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart';

part 'apply_command.freezed.dart';

final class PatchApplyCommand extends Command<int>
    with ConfigMixin, PubEnvMixin {
  @override
  String name = 'apply';

  @override
  String get description => 'Apply patches';

  PatchApplyCommand() {
    addGlobalPatchArgs(argParser);

    argParser.addFlag('force', help: 'Force apply patches', negatable: false);
  }

  @override
  Future<int> run() async {
    if (!isProjectMode) {
      stderr.writeln('Project cache is not supported for global mode');
      return 1;
    }

    final options = ApplyOptions.fromArgResults(argResults!);
    final resolvedCacheDir = resolveCacheDir(
      options.globalPatchOptions.cacheDir,
    );
    final cacheDir = Directory(resolvedCacheDir);

    if (!cacheDir.existsSync()) {
      stderr.writeln(
        '$resolvedCacheDir does not exist. Did you run `$kExecutableName pub get`?',
      );
      return 1;
    }

    if (!(await gitExists())) {
      stderr.writeln('Git is not installed');
      return 1;
    }

    final patchDir = Directory(
      resolveProjectPath(options.globalPatchOptions.patchDir),
    );
    if (!patchDir.existsSync()) {
      stderr.writeln(
        'Patch directory does not exist. Did you run `$kExecutableName patch generate`?',
      );
      return 1;
    }

    final hostedPatchesDir = Directory(join(patchDir.path, 'hosted'));
    final gitPatchesDir = Directory(join(patchDir.path, 'git'));

    final hostedPatches = hostedPatchesDir.existsSync()
        ? hostedPatchesDir.listSync().whereType<File>()
        : <File>[];
    final gitPatches = gitPatchesDir.existsSync()
        ? gitPatchesDir.listSync().whereType<File>()
        : <File>[] as Iterable<File>;

    if (hostedPatches.isEmpty && gitPatches.isEmpty) {
      stderr.writeln('No patches to apply');
      return 0;
    }

    final resetCacheExitCode = await _resetGitWorktree(
      workingDirectory: resolvedCacheDir,
      label: basename(resolvedCacheDir),
      force: options.force,
    );
    if (resetCacheExitCode != 0) {
      return resetCacheExitCode;
    }

    for (final patch in hostedPatches) {
      final result = await Process.run('git', [
        'apply',
        patch.path,
      ], workingDirectory: resolvedCacheDir);

      if (result.exitCode != 0) {
        stderr.writeln(
          'Failed to apply patch ${patch.path}:\n${result.stderr}',
        );
        return 1;
      }
    }

    for (final patch in gitPatches) {
      final workingDir = join(
        resolvedCacheDir,
        'git',
        basenameWithoutExtension(patch.path),
      );

      final resetExitCode = await _resetGitWorktree(
        workingDirectory: workingDir,
        label: basenameWithoutExtension(patch.path),
        force: options.force,
      );
      if (resetExitCode != 0) {
        return resetExitCode;
      }

      final result = await Process.run('git', [
        'apply',
        patch.path,
      ], workingDirectory: workingDir);

      if (result.exitCode != 0) {
        stderr.writeln(
          'Failed to apply patch ${patch.path}:\n${result.stderr}',
        );
        return 1;
      }
    }

    return 0;
  }

  Future<int> _resetGitWorktree({
    required String workingDirectory,
    required String label,
    required bool force,
  }) async {
    final statusResult = await Process.run('git', [
      'status',
      '--short',
    ], workingDirectory: workingDirectory);

    if (statusResult.exitCode != 0) {
      stderr.writeln(
        'Failed to inspect patch cache $label:\n${statusResult.stderr}',
      );
      return 1;
    }

    if ((statusResult.stdout as String).trim().isNotEmpty && !force) {
      stderr.writeln(
        'Patch cache $label has local changes. Re-run with --force to '
        'discard cache changes before applying patches.',
      );
      return 1;
    }

    final checkoutResult = await Process.run('git', [
      'checkout',
      '.',
    ], workingDirectory: workingDirectory);

    if (checkoutResult.exitCode != 0) {
      stderr.writeln(
        'Failed to reset patch cache $label:\n${checkoutResult.stderr}',
      );
      return 1;
    }

    return 0;
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
