import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  group('Given a descriptor-scaffolded Dart package without dpk.yaml', () {
    late String dpkExecutable;
    late String packagePath;

    setUp(() async {
      dpkExecutable = path.join(Directory.current.path, 'bin', 'dpk.dart');
      await d.dir('package', [
        d.file('pubspec.yaml', '''
name: sample
environment:
  sdk: ^3.11.0
'''),
      ]).create();
      packagePath = d.path('package');
    });

    group('When running dpk init from the package directory', () {
      late ProcessResult result;
      late File configFile;

      setUp(() async {
        result = await runDpk(dpkExecutable, [
          'init',
        ], workingDirectory: packagePath);
        configFile = File(path.join(packagePath, 'dpk.yaml'));
      });

      test('Then it creates dpk.yaml with the default version constraint', () {
        expect(result.exitCode, equals(0));
        expect(configFile.readAsStringSync(), equals('version: ^0.8.0\n'));
      });

      test('Then it prints the created file path', () {
        expect(result.stdout.toString(), contains(configFile.path));
      });
    });

    group('When running dpk init with project mode', () {
      late ProcessResult result;
      late File configFile;

      setUp(() async {
        result = await runDpk(dpkExecutable, [
          'init',
          '--mode',
          'project',
        ], workingDirectory: packagePath);
        configFile = File(path.join(packagePath, 'dpk.yaml'));
      });

      test('Then it writes project cache mode', () {
        expect(result.exitCode, equals(0));
        expect(
          configFile.readAsStringSync(),
          equals('version: ^0.8.0\nmode: project\n'),
        );
      });
    });

    group('When running dpk init through -C from another directory', () {
      late ProcessResult result;
      late File configFile;

      setUp(() async {
        result = await runDpk(dpkExecutable, ['-C', packagePath, 'init']);
        configFile = File(path.join(packagePath, 'dpk.yaml'));
      });

      test('Then it creates dpk.yaml in the target package', () {
        expect(result.exitCode, equals(0));
        expect(configFile.existsSync(), isTrue);
      });
    });
  });

  group('Given a descriptor-scaffolded Dart package with dpk.yaml', () {
    late String dpkExecutable;
    late String packagePath;
    late File configFile;

    setUp(() async {
      dpkExecutable = path.join(Directory.current.path, 'bin', 'dpk.dart');
      await d.dir('package', [
        d.file('pubspec.yaml', '''
name: sample
environment:
  sdk: ^3.11.0
'''),
        d.file('dpk.yaml', 'version: ^0.5.0\n'),
      ]).create();
      packagePath = d.path('package');
      configFile = File(path.join(packagePath, 'dpk.yaml'));
    });

    group('When running dpk init without --force', () {
      late ProcessResult result;

      setUp(() async {
        result = await runDpk(dpkExecutable, [
          'init',
        ], workingDirectory: packagePath);
      });

      test('Then it refuses to overwrite the existing config', () {
        expect(result.exitCode, equals(1));
        expect(result.stderr.toString(), contains('--force'));
      });

      test('Then the existing config is preserved', () {
        expect(configFile.readAsStringSync(), equals('version: ^0.5.0\n'));
      });
    });

    group('When running dpk init with --force', () {
      late ProcessResult result;

      setUp(() async {
        result = await runDpk(dpkExecutable, [
          'init',
          '--force',
        ], workingDirectory: packagePath);
      });

      test('Then it overwrites the existing config', () {
        expect(result.exitCode, equals(0));
        expect(configFile.readAsStringSync(), equals('version: ^0.8.0\n'));
      });
    });
  });

  group('Given a descriptor-scaffolded directory without pubspec.yaml', () {
    late String dpkExecutable;
    late String directoryPath;

    setUp(() async {
      dpkExecutable = path.join(Directory.current.path, 'bin', 'dpk.dart');
      await d.dir('empty').create();
      directoryPath = d.path('empty');
    });

    test('When running dpk init then it reports the missing pubspec', () async {
      final result = await runDpk(dpkExecutable, [
        'init',
      ], workingDirectory: directoryPath);

      expect(result.exitCode, equals(1));
      expect(result.stderr.toString(), contains('pubspec.yaml not found'));
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
