import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:dpk/core/constants.dart';
import 'package:dpk/core/mixins/config_mixin.dart';
import 'package:dpk/core/mixins/pub_env_mixin.dart';
import 'package:dpk/utils/command_checker.dart';
import 'package:dpk/utils/globals/global_patch_args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart';

part 'init_command.freezed.dart';

final class PatchInitCommand extends Command<int>
    with ConfigMixin, PubEnvMixin {
  @override
  String name = 'init';

  @override
  String get description => 'Initialize patch';

  PatchInitCommand() {
    addGlobalPatchArgs(argParser);

    argParser.addFlag(
      'force',
      help: 'Force reinitialize patch',
      negatable: false,
    );
  }

  @override
  Future<int> run() async {
    if (!isProjectMode) {
      stderr.writeln('Project cache is not supported for global mode');
      return 1;
    }

    final options = PatchOptions.fromArgResults(argResults!);
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

    // dart format off
    final dotGitDir = Directory(
      resolvedCacheDir,
    ).listSync().firstWhereOrNull((entity) => basename(entity.path) == '.git')
        as Directory?;
    // dart format on
    final dotGitExists = dotGitDir != null;

    if (dotGitExists && !options.force) {
      stderr.writeln(
        'Patch is already initialized. Run with --force to initialize from scratch',
      );
      return 1;
    }

    if (dotGitExists && options.force) {
      await Process.run('git', [
        'checkout',
        '.',
      ], workingDirectory: resolvedCacheDir);

      await dotGitDir.delete(recursive: true);
    }

    await Process.run('git', ['init'], workingDirectory: resolvedCacheDir);
    await Process.run('git', ['add', '.'], workingDirectory: resolvedCacheDir);
    await Process.run('git', [
      'commit',
      '-m',
      '"Patch initialized"',
    ], workingDirectory: resolvedCacheDir);

    stdout.writeln('Patch initialized');

    return 0;
  }
}

@freezed
abstract class PatchOptions with _$PatchOptions {
  const factory PatchOptions({
    required GlobalPatchOptions globalPatchOptions,
    required bool force,
  }) = _PatchOptions;

  factory PatchOptions.fromArgResults(ArgResults results) {
    return PatchOptions(
      globalPatchOptions: GlobalPatchOptions.fromArgResults(results),
      force: results.flag('force'),
    );
  }
}
