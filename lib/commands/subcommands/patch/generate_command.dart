import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpk/core/constants.dart';
import 'package:dpk/core/mixins/cache_mixin.dart';
import 'package:dpk/core/mixins/config_mixin.dart';
import 'package:dpk/utils/command_checker.dart';
import 'package:dpk/utils/globals/global_patch_args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart';
import 'package:prompts/prompts.dart' as prompts;

part 'generate_command.freezed.dart';

final class PatchGenerateCommand extends Command<int>
    with ConfigMixin, CacheMixin {
  @override
  String name = 'generate';

  @override
  String get description => 'Generate patch files';

  PatchGenerateCommand() {
    addGlobalPatchArgs(argParser);

    argParser.addFlag(
      'force',
      help: 'Force generate patch files',
      negatable: false,
    );
  }

  @override
  Future<int> run() async {
    if (!isProjectCache) {
      stderr.writeln('Project cache is not supported for global mode');
      return 1;
    }

    final options = GenerateOptions.fromArgResults(argResults!);
    final cacheDir = Directory(options.globalPatchOptions.cacheDir);
    final patchDir = Directory(options.globalPatchOptions.patchDir);

    if (!cacheDir.existsSync()) {
      stderr.writeln(
        '${options.globalPatchOptions.cacheDir} does not exist. Did you run `$kExecutableName pub get`?',
      );
      return 1;
    }

    if (!patchDir.existsSync()) {
      await patchDir.create(recursive: true);
    }

    if (!(await gitExists())) {
      stderr.writeln('Git is not installed');
      return 1;
    }

    // dart format off
    final shouldContinue = options.force || prompts.getBool(
      'Generating patch files will delete all existing patch files. Do you want to continue?',
      defaultsTo: true,
    );
    // dart format on

    if (!shouldContinue) {
      return 0;
    }

    patchDir.deleteSync(recursive: true);
    patchDir.createSync(recursive: true);

    final ProcessResult(
      stdout: statusStdout as String,
      stderr: statusStderr as String,
      exitCode: statusExitCode,
    ) = await Process.run('git', [
      'status',
      '-s',
    ], workingDirectory: options.globalPatchOptions.cacheDir);

    if (statusExitCode != 0) {
      stderr.writeln('Failed to generate patch files:\n$statusStderr');
      return 1;
    }

    if (statusStdout.isEmpty) {
      stderr.writeln('No changes to generate patch files');
      return 0;
    }

    final statusLines = statusStdout
        .split('\n')
        .where((line) => line.trim().isNotEmpty);
    final patches = <({String packageName, bool isGit}), List<String>>{};
    final untrackedFiles = <String>[];

    for (final line in statusLines) {
      final [status, path] = line.trim().split(RegExp(r'\s+'));

      if (status == '??') {
        untrackedFiles.add(path);
        continue;
      }

      late final String packageName;
      late final bool isGit;
      if (path.startsWith('hosted')) {
        final [_, _, p, ..._] = path.split('/');
        packageName = p;
        isGit = false;
      } else if (path.startsWith('git')) {
        final [_, p, ..._] = path.split('/');
        packageName = p;
        isGit = true;
      } else {
        stderr.writeln('Unsupported path: $path');
        return 1;
      }

      final key = (packageName: packageName, isGit: isGit);
      patches[key] ??= [];

      if (!isGit) {
        patches[key]!.add(path);
        continue;
      }

      final gitDir = join(
        options.globalPatchOptions.cacheDir,
        'git',
        packageName,
      );
      final ProcessResult(
        stdout: statusStdout as String,
        stderr: statusStderr as String,
        exitCode: statusExitCode,
      ) = await Process.run('git', ['status', '-s'], workingDirectory: gitDir);

      if (statusExitCode != 0) {
        stderr.writeln('Failed to generate patch files:\n$statusStderr');
        return 1;
      }

      if (statusStdout.isEmpty) {
        stderr.writeln('No changes to generate patch files');
        return 0;
      }

      final statusLines = statusStdout
          .split('\n')
          .where((line) => line.trim().isNotEmpty);
      for (final line in statusLines) {
        final [status, path] = line.trim().split(RegExp(r'\s+'));
        if (status == '??') {
          untrackedFiles.add(path);
          continue;
        }

        patches[key]!.add(path);
      }
    }

    // dart format off
    for (final MapEntry(:key , value: filePaths) in patches.entries) {
    // dart format on
      final (:packageName, :isGit) = key;
      late final String workingDir;
      if (isGit) {
        workingDir = join(
          options.globalPatchOptions.cacheDir,
          'git',
          packageName,
        );
      } else {
        workingDir = options.globalPatchOptions.cacheDir;
      }

      final ProcessResult(
        stdout: diffStdout as String,
        stderr: diffStderr as String,
        exitCode: diffExitCode,
      ) = await Process.run('git', [
        'diff',
        '--no-ext-diff',
        '--no-color',
        ...filePaths,
      ], workingDirectory: workingDir);

      if (diffExitCode != 0) {
        stderr.writeln('Failed to generate patch files:\n$diffStderr');
        return 1;
      }

      final patchFile = File(
        join(
          patchDir.absolute.path,
          isGit ? 'git' : 'hosted',
          '$packageName.patch',
        ),
      );

      if (!patchFile.existsSync()) {
        await patchFile.create(recursive: true);
      }

      await patchFile.writeAsString(diffStdout);
    }

    if (untrackedFiles.isNotEmpty) {
      stderr.writeln('Untracked files are currently not supported:');
      for (final file in untrackedFiles) {
        stderr.writeln('  $file');
      }

      stderr.writeln(
        '\nIf this is expected, try running `$kExecutableName init --force` to add them to the cache.',
      );
    }

    return 0;
  }
}

@freezed
abstract class GenerateOptions with _$GenerateOptions {
  const factory GenerateOptions({
    required GlobalPatchOptions globalPatchOptions,
    required bool force,
  }) = _GenerateOptions;

  factory GenerateOptions.fromArgResults(ArgResults results) {
    return GenerateOptions(
      globalPatchOptions: GlobalPatchOptions.fromArgResults(results),
      force: results.flag('force'),
    );
  }
}
