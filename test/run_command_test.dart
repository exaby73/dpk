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
version: ^0.8.0
scripts:
  cwd: dart tool/print_cwd.dart
  echo_args: dart tool/echo_args.dart
  before:
    command: dart tool/append_hook.dart before
    scripts:
      - build
  pre:build: dart tool/append_hook.dart pre
  build: dart tool/append_hook.dart build
  post:build: dart tool/append_hook.dart post
  after:
    command: dart tool/append_hook.dart after
    scripts:
      - build
  test: dart tool/append_hook.dart test
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
          d.file('append_hook.dart', '''
import 'dart:io';

void main(List<String> args) {
  File('hook.log').writeAsStringSync(
    '\${args.single}\\n',
    mode: FileMode.append,
  );
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

    group('When running a script with targeted before and after hooks', () {
      late ProcessResult result;
      late File hookLog;

      setUp(() async {
        hookLog = File(path.join(projectPath, 'hook.log'));
        result = await runDpk(dpkExecutable, [
          '-C',
          projectPath,
          'run',
          'build',
        ]);
      });

      test('Then the targeted hooks wrap the exact hooks', () {
        expect(result.exitCode, equals(0));
        expect(
          hookLog.readAsLinesSync(),
          equals(['before', 'pre', 'build', 'post', 'after']),
        );
      });
    });

    group('When running a script outside a targeted before and after list', () {
      late ProcessResult result;
      late File hookLog;

      setUp(() async {
        hookLog = File(path.join(projectPath, 'hook.log'));
        result = await runDpk(dpkExecutable, [
          '-C',
          projectPath,
          'run',
          'test',
        ]);
      });

      test('Then the targeted hooks are skipped', () {
        expect(result.exitCode, equals(0));
        expect(hookLog.readAsLinesSync(), equals(['test']));
      });
    });

    group('When all is true on a hook script', () {
      late ProcessResult result;
      late File hookLog;

      setUp(() async {
        final dpkYaml = File(path.join(projectPath, 'dpk.yaml'));
        dpkYaml.writeAsStringSync('''
version: ^0.8.0
scripts:
  before:
    command: dart tool/append_hook.dart before_all
    scripts:
      - ignored
    all: true
  after:
    command: dart tool/append_hook.dart after_all
    scripts:
      - ignored
    all: true
  test: dart tool/append_hook.dart test
''');
        hookLog = File(path.join(projectPath, 'hook.log'));
        result = await runDpk(dpkExecutable, [
          '-C',
          projectPath,
          'run',
          'test',
        ]);
      });

      test('Then scripts is ignored and the hook applies', () {
        expect(result.exitCode, equals(0));
        expect(
          hookLog.readAsLinesSync(),
          equals(['before_all', 'test', 'after_all']),
        );
      });
    });

    group('When a before hook recursively invokes a matching script', () {
      late ProcessResult result;
      late File hookLog;

      setUp(() async {
        final dpkYaml = File(path.join(projectPath, 'dpk.yaml'));
        dpkYaml.writeAsStringSync('''
version: ^0.8.0
scripts:
  before:
    command: dart $dpkExecutable run build
    all: true
  build: dart tool/append_hook.dart build
  test: dart tool/append_hook.dart test
''');
        hookLog = File(path.join(projectPath, 'hook.log'));
        result = await runDpk(dpkExecutable, [
          '-C',
          projectPath,
          'run',
          'test',
        ]);
      });

      test('Then the recursive before hook is skipped', () {
        expect(result.exitCode, equals(0));
        expect(hookLog.readAsLinesSync(), equals(['build', 'test']));
        expect(result.stderr.toString(), contains('recursive hook "before"'));
      });
    });

    group('When an after hook recursively invokes a matching script', () {
      late ProcessResult result;
      late File hookLog;

      setUp(() async {
        final dpkYaml = File(path.join(projectPath, 'dpk.yaml'));
        dpkYaml.writeAsStringSync('''
version: ^0.8.0
scripts:
  after:
    command: dart $dpkExecutable run report
    all: true
  report: dart tool/append_hook.dart report
  test: dart tool/append_hook.dart test
''');
        hookLog = File(path.join(projectPath, 'hook.log'));
        result = await runDpk(dpkExecutable, [
          '-C',
          projectPath,
          'run',
          'test',
        ]);
      });

      test('Then the recursive after hook is skipped', () {
        expect(result.exitCode, equals(0));
        expect(hookLog.readAsLinesSync(), equals(['test', 'report']));
        expect(result.stderr.toString(), contains('recursive hook "after"'));
      });
    });
  });
}

Future<ProcessResult> runDpk(String executable, List<String> arguments) {
  return Process.run('dart', [executable, ...arguments]);
}
