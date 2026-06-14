import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  group('Given a descriptor-scaffolded dpk project with get hooks', () {
    late String dpkExecutable;
    late String projectPath;

    setUp(() async {
      dpkExecutable = path.join(Directory.current.path, 'bin', 'dpk.dart');
      await d.dir('project', [
        d.file('pubspec.yaml', '''
name: get_sample
environment:
  sdk: ^3.8.0
'''),
        d.file('dpk.yaml', '''
version: ^0.8.0
scripts:
  pre:get: dart tool/record_lock.dart pre_get
  before:
    command: dart tool/record_lock.dart before_get
    scripts:
      - get
  post:get: dart tool/record_lock.dart post_get
  after:
    command: dart tool/record_lock.dart after_get
    scripts:
      - get
'''),
        d.dir('tool', [
          d.file('record_lock.dart', '''
import 'dart:io';

void main(List<String> args) {
  File('hook.log').writeAsStringSync(
    '\${args.single}:\${File('pubspec.lock').existsSync()}\\n',
    mode: FileMode.append,
  );
}
'''),
        ]),
      ]).create();
      projectPath = d.path('project');
    });

    group('When running dpk get', () {
      late ProcessResult result;
      late File hookLog;

      setUp(() async {
        hookLog = File(path.join(projectPath, 'hook.log'));
        result = await runDpk(dpkExecutable, ['-C', projectPath, 'get']);
      });

      test('Then the shared before hook runs after pub get', () {
        expect(result.exitCode, equals(0));
        expect(
          hookLog.readAsLinesSync(),
          equals([
            'pre_get:false',
            'before_get:true',
            'post_get:true',
            'after_get:true',
          ]),
        );
      });
    });
  });
}

Future<ProcessResult> runDpk(String executable, List<String> arguments) {
  return Process.run('dart', [executable, ...arguments]);
}
