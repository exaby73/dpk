import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  group('Given a descriptor-scaffolded directory without dpk.yaml', () {
    late String dpkExecutable;
    late String directoryPath;

    setUp(() async {
      dpkExecutable = path.join(Directory.current.path, 'bin', 'dpk.dart');
      await d.dir('empty').create();
      directoryPath = d.path('empty');
    });

    group('When running dpk skills', () {
      late ProcessResult result;

      setUp(() async {
        result = await runDpk(dpkExecutable, [
          'skills',
        ], workingDirectory: directoryPath);
      });

      test('Then it exits successfully', () {
        expect(result.exitCode, equals(0));
      });

      test('Then it prints detailed usage guidance', () {
        final output = result.stdout.toString();
        expect(output, contains('# dpk Skill'));
        expect(output, contains('dpk skills'));
        expect(output, contains('dpk run <script>'));
        expect(output, contains('dpk patch apply --force'));
        expect(output, contains('before'));
        expect(output, contains('after'));
        expect(output, contains('dpk run clean'));
      });
    });
  });

  group('Given the dpk CLI help output', () {
    late String dpkExecutable;
    late ProcessResult result;

    setUp(() async {
      dpkExecutable = path.join(Directory.current.path, 'bin', 'dpk.dart');
      result = await runDpk(dpkExecutable, ['--help']);
    });

    test('When help is requested then it lists the skills command', () {
      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), contains('skills'));
    });
  });
}

Future<ProcessResult> runDpk(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) {
  return Process.run('dart', [
    executable,
    ...arguments,
  ], workingDirectory: workingDirectory);
}
