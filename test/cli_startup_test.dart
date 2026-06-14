import 'dart:io';

import 'package:dpk/utils/globals/global_args.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('Given the dpk CLI startup path', () {
    late String dpkExecutable;

    setUp(() {
      dpkExecutable = path.join(Directory.current.path, 'bin', 'dpk.dart');
    });

    group('When help is requested', () {
      late ProcessResult result;

      setUp(() async {
        result = await Process.run('dart', [dpkExecutable, '--help']);
      });

      test('Then it exits successfully', () {
        expect(result.exitCode, equals(0));
      });

      test('Then it prints usage', () {
        expect(result.stdout.toString(), contains('Usage: dpk'));
      });
    });

    group('When version is requested', () {
      late ProcessResult result;

      setUp(() async {
        result = await Process.run('dart', [dpkExecutable, '--version']);
      });

      test('Then it exits successfully', () {
        expect(result.exitCode, equals(0));
      });

      test('Then it prints detailed version information', () {
        final output = result.stdout.toString();
        expect(output, contains('dpk'));
        expect(output, contains('Version:    0.8.0'));
        expect(output, contains('Dart SDK:'));
        expect(output, contains('Repository: https://github.com/zoeh-ai/dpk'));
      });
    });

    group('When parsing fails', () {
      late ProcessResult result;

      setUp(() async {
        result = await Process.run('dart', [
          dpkExecutable,
          'add',
          '--not-a-real-option',
        ]);
      });

      test('Then it exits with a usage error', () {
        expect(result.exitCode, equals(64));
      });

      test('Then it does not print a Dart stack trace', () {
        expect(result.stderr.toString(), contains('--not-a-real-option'));
        expect(
          result.stderr.toString(),
          isNot(contains('Unhandled exception')),
        );
      });
    });
  });

  group('Given global CLI arguments', () {
    test('When --directory uses a separate value then it is extracted', () {
      expect(
        extractDirectoryArg(['--directory', 'example', 'run', 'build']),
        equals('example'),
      );
    });

    test('When -C uses an inline value then it is extracted', () {
      expect(extractDirectoryArg(['-Cexample', 'run', 'build']), 'example');
    });

    test('When arguments after -- contain --directory then it is ignored', () {
      expect(
        extractDirectoryArg(['run', 'script', '--', '--directory', 'ignored']),
        isNull,
      );
    });
  });
}
