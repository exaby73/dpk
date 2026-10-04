import 'dart:io';

import 'package:dpk/core/errors.dart';
import 'package:dpk/core/process_runner.dart';

/// Runs git for the project cache.
///
/// Commits use dpk's own identity with signing and hooks turned off, so a
/// machine without `user.name`, with `commit.gpgsign`, or with a global
/// pre-commit hook still records the baseline. Line endings are never
/// converted.
final class Git {
  Git(this.processRunner);

  final ProcessRunner processRunner;

  static const _settings = [
    '-c',
    'core.autocrlf=false',
    '-c',
    'core.safecrlf=false',
    '-c',
    'core.quotepath=false',
    '-c',
    'commit.gpgsign=false',
    '-c',
    'diff.noprefix=false',
    '-c',
    'diff.mnemonicPrefix=false',
    '-c',
    'user.name=dpk',
    '-c',
    'user.email=dpk@localhost',
  ];

  /// Runs `git <arguments>` in [directory]. Throws a [DpkException] when git
  /// fails, unless [check] is false.
  Future<ProcessResult> call(
    List<String> arguments, {
    required String directory,
    bool check = true,
  }) async {
    final ProcessResult result;
    try {
      result = await processRunner.run('git', [
        ..._settings,
        ...arguments,
      ], workingDirectory: directory);
    } on ProcessException {
      throw DpkException(
        'git is not installed or not on PATH. Patching needs git.',
      );
    }
    if (check && result.exitCode != 0) {
      throw DpkException(
        'git ${arguments.join(' ')} failed in $directory:\n'
        '${(result.stderr as String).trim()}',
      );
    }
    return result;
  }

  /// Runs git and returns its standard output.
  Future<String> output(
    List<String> arguments, {
    required String directory,
  }) async => (await call(arguments, directory: directory)).stdout as String;

  /// Whether `git <arguments>` exits with 0.
  Future<bool> succeeds(
    List<String> arguments, {
    required String directory,
  }) async =>
      (await call(arguments, directory: directory, check: false)).exitCode == 0;

  /// Commits everything staged, even when nothing is.
  Future<void> commit(String message, {required String directory}) => call([
    'commit',
    '--quiet',
    '--no-verify',
    '--allow-empty',
    '-m',
    message,
  ], directory: directory);
}
