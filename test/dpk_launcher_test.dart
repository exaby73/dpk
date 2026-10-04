@TestOn('!windows')
@Timeout(Duration(minutes: 4))
library;

import 'dart:io';

import 'package:dpk/core/self_command.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'utils/dpk_test_utils.dart';

void main() {
  group('Given dpk running on the Dart VM', () {
    test('Then its command is the dart executable followed by the script', () {
      final command = currentDpkCommand();

      expect(command.first, equals(Platform.resolvedExecutable));
      expect(command.last, equals(Platform.script.toFilePath()));
      expect(
        command,
        everyElement(isNot(startsWith('--resolved_executable_name='))),
      );
    });
  });

  group('Given a dpk command', () {
    test('When writing its launcher then the launcher runs that command', () {
      final directory = writeDpkLauncher(['/opt/dpk bin', "it's"]);

      expect(
        File(p.join(directory, 'dpk')).readAsStringSync(),
        equals('#!/bin/sh\nexec \'/opt/dpk bin\' \'it\'"\'"\'s\' "\$@"\n'),
      );
      expect(writeDpkLauncher(['/opt/dpk bin', "it's"]), equals(directory));
    });
  });

  group('Given a project whose script calls dpk, with no dpk installed', () {
    late String aotBinary;

    setUpAll(() async {
      final output = Directory.systemTemp.createTempSync('dpk_aot');
      aotBinary = p.join(output.path, 'dpk');
      final compile = await Process.run(Platform.resolvedExecutable, [
        'compile',
        'exe',
        p.join(Directory.current.path, 'bin', 'dpk.dart'),
        '-o',
        aotBinary,
      ]);
      expect(compile.exitCode, equals(0), reason: '${compile.stderr}');
      addTearDown(() => output.deleteSync(recursive: true));
    });

    setUp(() async {
      await d.dir('project', [
        d.file('pubspec.yaml', pubspec('sample')),
        d.file('dpk.yaml', '''
version: $versionConstraint
scripts:
  nested: command -v dpk > which.txt && dpk list --json > list.json
'''),
      ]).create();
    });

    final dartEntry = p.join(Directory.current.path, 'bin', 'dpk.dart');
    final launches = <String, List<String> Function(String aot)>{
      'dart bin/dpk.dart': (_) => [Platform.resolvedExecutable, dartEntry],
      'dart run bin/dpk.dart': (_) => [
        Platform.resolvedExecutable,
        'run',
        dartEntry,
      ],
      'a compiled binary': (aot) => [aot],
    };

    for (final MapEntry(key: name, value: launch) in launches.entries) {
      group('When dpk is started as $name', () {
        late ProcessResult result;
        late List<String> command;

        setUp(() async {
          command = launch(aotBinary);
          result = await Process.run(
            command.first,
            [...command.skip(1), 'run', 'nested'],
            workingDirectory: d.path('project'),
            environment: {'PATH': '/usr/bin:/bin'},
          );
        });

        test('Then dpk inside the script is the same dpk', () {
          expect(result.exitCode, equals(0), reason: '${result.stderr}');
          expect(
            File(d.path('project/list.json')).readAsStringSync(),
            contains('"name": "sample"'),
          );
        });

        test('Then the script finds dpk through the launcher', () {
          final launcher = File(
            d.path('project/which.txt'),
          ).readAsStringSync().trim();
          expect(launcher, contains('dpk-launchers'));
          expect(
            File(launcher).readAsStringSync(),
            contains(name == 'a compiled binary' ? aotBinary : dartEntry),
          );
        });
      });
    }
  });
}
