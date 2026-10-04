import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  group('Given a descriptor-scaffolded project with a dirty patch cache', () {
    late String dpkExecutable;
    late String projectPath;
    late String cachePath;

    setUp(() async {
      dpkExecutable = path.join(Directory.current.path, 'bin', 'dpk.dart');
      await d.dir('project', [
        d.file('pubspec.yaml', '''
name: sample
environment:
  sdk: ^3.11.0
'''),
        d.file('dpk.yaml', '''
version: ^0.8.0
mode: project
'''),
        d.dir('patches', [
          d.dir('hosted', [d.file('sample.patch', '')]),
        ]),
        d.dir('pub_packages', [d.file('package.txt', 'original')]),
      ]).create();

      projectPath = d.path('project');
      cachePath = path.join(projectPath, 'pub_packages');
      await runGit(['init'], cachePath);
      await runGit(['add', '.'], cachePath);
      await runGit([
        '-c',
        'user.name=dpk tests',
        '-c',
        'user.email=dpk@example.com',
        'commit',
        '-m',
        'initial cache',
      ], cachePath);
      File(path.join(cachePath, 'package.txt')).writeAsStringSync('dirty');
    });

    group('When applying patches without --force', () {
      late ProcessResult result;

      setUp(() async {
        result = await Process.run('dart', [
          dpkExecutable,
          '-C',
          projectPath,
          'patch',
          'apply',
        ]);
      });

      test('Then it refuses to discard cache changes', () {
        expect(result.exitCode, equals(1));
        expect(result.stderr.toString(), contains('Re-run with --force'));
      });

      test('Then the dirty cache file is preserved', () {
        final file = File(path.join(cachePath, 'package.txt'));
        expect(file.readAsStringSync(), equals('dirty'));
      });
    });
  });
}

Future<void> runGit(List<String> arguments, String workingDirectory) async {
  final result = await Process.run(
    'git',
    arguments,
    workingDirectory: workingDirectory,
  );

  if (result.exitCode != 0) {
    throw StateError('git ${arguments.join(' ')} failed: ${result.stderr}');
  }
}
