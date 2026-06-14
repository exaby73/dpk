import 'dart:io';

import 'package:dpk/commands/pub_passthrough_command.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  group('Given a descriptor-scaffolded dpk project', () {
    late String dpkExecutable;
    late String projectPath;

    setUp(() async {
      dpkExecutable = path.join(Directory.current.path, 'bin', 'dpk.dart');
      await d.dir('project', [
        d.file('pubspec.yaml', '''
name: passthrough_sample
environment:
  sdk: ^3.8.0
'''),
        d.file('dpk.yaml', '''
version: ^0.7.0
'''),
      ]).create();
      projectPath = d.path('project');
    });

    group('When help is requested', () {
      late ProcessResult result;

      setUp(() async {
        result = await runDpk(dpkExecutable, ['--help']);
      });

      test('Then passthrough pub commands are listed', () {
        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), contains('add'));
        expect(result.stdout.toString(), contains('bump'));
        expect(result.stdout.toString(), contains('deps'));
        expect(result.stdout.toString(), contains('publish'));
        expect(result.stdout.toString(), contains('remove'));
        expect(result.stdout.toString(), contains('workspace'));
      });
    });

    group('When running a passthrough command with pub options', () {
      late ProcessResult result;

      setUp(() async {
        result = await runDpk(dpkExecutable, [
          '-C',
          projectPath,
          'deps',
          '--style',
          'list',
        ]);
      });

      test('Then the command is forwarded to dart pub', () {
        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), contains('passthrough_sample'));
      });
    });

    group(
      'When running a passthrough command with command-local dpk options',
      () {
        late ProcessResult result;

        setUp(() async {
          result = await runDpk(dpkExecutable, [
            'deps',
            '-C',
            projectPath,
            '--style',
            'list',
          ]);
        });

        test(
          'Then dpk options are consumed before pub arguments are forwarded',
          () {
            expect(result.exitCode, equals(0));
            expect(result.stdout.toString(), contains('passthrough_sample'));
          },
        );
      },
    );
  });

  group('Given pub passthrough command validation', () {
    test(
      'When an unsupported pub command is registered then it is rejected',
      () {
        expect(
          () => PubPassthroughCommand(
            commandName: 'not-a-pub-command',
            commandDescription: 'Invalid command',
          ),
          throwsArgumentError,
        );
      },
    );
  });
}

Future<ProcessResult> runDpk(String executable, List<String> arguments) {
  return Process.run('dart', [executable, ...arguments]);
}
