import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  group('Given a descriptor-scaffolded dpk project with scripts', () {
    late String dpkExecutable;
    late String projectPath;

    setUp(() async {
      dpkExecutable = path.join(Directory.current.path, 'bin', 'dpk.dart');
      await d.dir('project', [
        d.file('pubspec.yaml', '''
name: sample
environment:
  sdk: ^3.8.0
'''),
        d.file('dpk.yaml', '''
version: ^0.7.0
scripts:
  cwd: dart tool/print_cwd.dart
  echo_args: dart tool/echo_args.dart
'''),
        d.dir('tool', [
          d.file('print_cwd.dart', '''
import 'dart:io';

void main() {
  print(Directory.current.path);
}
'''),
          d.file('echo_args.dart', '''
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  print(jsonEncode(args));
  File('injected').writeAsStringSync('created by script');
}
'''),
        ]),
      ]).create();
      projectPath = d.path('project');
    });

    group('When running a script through -C from another directory', () {
      late ProcessResult result;

      setUp(() async {
        result = await runDpk(dpkExecutable, ['-C', projectPath, 'run', 'cwd']);
      });

      test('Then the script runs in the target project directory', () {
        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), contains(projectPath));
      });
    });

    group('When running a script through run -C from another directory', () {
      late ProcessResult result;

      setUp(() async {
        result = await runDpk(dpkExecutable, ['run', '-C', projectPath, 'cwd']);
      });

      test('Then the script runs in the target project directory', () {
        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), contains(projectPath));
      });
    });

    group('When forwarding a shell metacharacter argument to a script', () {
      late ProcessResult result;
      late File injectedByShell;

      setUp(() async {
        injectedByShell = File(path.join(projectPath, 'shell_injected'));
        result = await runDpk(dpkExecutable, [
          '-C',
          projectPath,
          'run',
          'echo_args',
          'value; touch shell_injected',
        ]);
      });

      test('Then the argument is delivered as data', () {
        final outputLines = const LineSplitter()
            .convert(result.stdout.toString())
            .where((line) => line.trim().startsWith('['))
            .toList();

        expect(result.exitCode, equals(0));
        expect(
          jsonDecode(outputLines.single),
          equals(['value; touch shell_injected']),
        );
      });

      test('Then the shell does not execute the argument', () {
        expect(injectedByShell.existsSync(), isFalse);
      });
    });
  });
}

Future<ProcessResult> runDpk(String executable, List<String> arguments) {
  return Process.run('dart', [executable, ...arguments]);
}
