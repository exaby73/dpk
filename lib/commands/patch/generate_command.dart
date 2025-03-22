import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpm/utils/command_checker.dart';
import 'package:dpm/utils/constants.dart';
import 'package:dpm/utils/global_args.dart';
import 'package:dpm/utils/string_extensions.dart';
import 'package:path/path.dart';
import 'package:prompts/prompts.dart' as prompts;

final class PatchGenerateCommand extends Command {
  @override
  String name = 'generate';

  @override
  String get description => 'Generate patch files';

  PatchGenerateCommand() {
    addGlobalArgs(argParser);

    argParser.addFlag(
      'force',
      help: 'Force generate patch files',
      negatable: false,
    );
  }

  @override
  Future<void> run() async {
    final options = _GenerateOptions.fromArgResults(argResults!);
    final cacheDir = Directory(options.cacheDir);
    final patchDir = Directory(options.patchDir);

    if (!cacheDir.existsSync()) {
      stderr.writeln(
        '${options.cacheDir} does not exist. Did you run `$executableName pub get`?',
      );
      exit(1);
    }

    if (!patchDir.existsSync()) {
      await patchDir.create(recursive: true);
    }

    if (!(await gitExists())) {
      stderr.writeln('Git is not installed');
      exit(1);
    }

    // dart format off
    final shouldContinue = options.force || prompts.getBool(
      'Generating patch files will delete all existing patch files. Do you want to continue?',
      defaultsTo: true,
    );
    // dart format on

    if (!shouldContinue) {
      exit(0);
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
    ], workingDirectory: options.cacheDir);

    if (statusExitCode != 0) {
      stderr.writeln('Failed to generate patch files:\n$statusStderr');
      exit(1);
    }

    if (statusStdout.isEmpty) {
      stderr.writeln('No changes to generate patch files');
      exit(0);
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
        exit(1);
      }

      final key = (packageName: packageName, isGit: isGit);
      patches[key] ??= [];

      if (!isGit) {
        patches[key]!.add(path);
        continue;
      }

      final gitDir = join(options.cacheDir, 'git', packageName);
      final ProcessResult(
        stdout: statusStdout as String,
        stderr: statusStderr as String,
        exitCode: statusExitCode,
      ) = await Process.run('git', ['status', '-s'], workingDirectory: gitDir);

      if (statusExitCode != 0) {
        stderr.writeln('Failed to generate patch files:\n$statusStderr');
        exit(1);
      }

      if (statusStdout.isEmpty) {
        stderr.writeln('No changes to generate patch files');
        exit(0);
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
        workingDir = join(options.cacheDir, 'git', packageName);
      } else {
        workingDir = options.cacheDir;
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
        exit(1);
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
        '\nIf this is expected, try running `$executableName init --force` to add them to the cache.',
      );
    }

    exit(0);
  }
}

final class _GenerateOptions extends GlobalOptions {
  final bool force;

  _GenerateOptions({
    required super.debug,
    required super.directory,
    required super.cacheDir,
    required super.patchDir,

    required this.force,
  });

  factory _GenerateOptions.fromArgResults(ArgResults results) {
    return _GenerateOptions(
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
    _PatchOptions(
      debug: $debug,
      directory: $directory,
      cacheDir: $cacheDir,
      patchDir: $patchDir,
      force: $force,
    )
    '''.trimIndents();
  }
}
