import 'dart:io';

import 'package:dpk/constants/embedded_dpk_skill.dart';
import 'package:dpk/constants/pubspec.dart' show dpkVersion;
import 'package:dpk/core/command_runner.dart';
import 'package:dpk/core/console.dart';
import 'package:dpk/core/context.dart';
import 'package:dpk/core/invocation.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'utils/dpk_test_utils.dart';

void main() {
  group('Given an empty directory', () {
    late Directory empty;

    setUp(() {
      empty = Directory.systemTemp.createTempSync('dpk_cli');
      addTearDown(() => empty.deleteSync(recursive: true));
    });

    test(
      'When asking for the version then dpk and Dart versions print',
      () async {
        final result = await dpk(['--version'], directory: empty.path);

        expect(result.exitCode, equals(0));
        expect(result.stdout, contains('Version:  $dpkVersion'));
        expect(result.stdout, contains('Dart SDK:'));
      },
    );

    test('When asking for help then commands are grouped', () async {
      final result = await dpk(['--help'], directory: empty.path);

      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('Scripts and workspaces'));
      expect(result.stdout, contains('Other pub commands'));
      expect(result.stdout, contains('dpk install-completion-files'));
    });

    test(
      'When running a project command then the error suggests dpk init',
      () async {
        final result = await dpk(['run', 'test'], directory: empty.path);

        expect(result.exitCode, equals(1));
        expect(result.stderr, startsWith('error: No pubspec.yaml found'));
      },
    );

    test(
      'When giving an unknown option before the command then dpk explains it',
      () async {
        final result = await dpk(['--coverage', 'run'], directory: empty.path);

        expect(result.exitCode, equals(64));
        expect(result.stderr, contains('dpk options go before the command'));
      },
    );

    test('When -C names a missing directory then dpk says so', () async {
      final result = await dpk(['-C', 'nope', 'get'], directory: empty.path);

      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('does not exist'));
    });

    test('When printing the skill then it matches the bundled guide', () async {
      final result = await dpk(['skills'], directory: empty.path);

      expect(result.stdout.trim(), equals(embeddedDpkSkill.trim()));
    });
  });

  group('Given a package that requires a newer dpk', () {
    setUp(() async {
      await d.dir('project', [
        d.file('pubspec.yaml', pubspec('sample')),
        d.file('dpk.yaml', 'version: ^99.0.0\n'),
      ]).create();
    });

    test('When running a command then the error says how to fix it', () async {
      final result = await dpk(['run'], directory: d.path('project'));

      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('requires dpk ^99.0.0'));
      expect(result.stderr, contains('dart install dpk'));
    });

    test('When asking for help then help still works', () async {
      final result = await dpk(['help', 'run'], directory: d.path('project'));

      expect(result.exitCode, equals(0));
    });
  });

  group('Given the dpk command runner', () {
    test('Then shell completion is never installed without asking', () {
      final runner = DpkCommandRunner(
        DpkContext(
          invocation: const Invocation(),
          console: Console.buffered(),
          processRunner: RecordingProcessRunner(),
          workingDirectory: '.',
          environment: const {},
        ),
      );

      expect(runner.enableAutoInstall, isFalse);
    });
  });

  group('Given a package without dpk.yaml', () {
    setUp(() async {
      await d.dir('app', [d.file('pubspec.yaml', pubspec('app'))]).create();
    });

    group('When running dpk init in project mode', () {
      late DpkResult result;

      setUp(() async {
        result = await dpk([
          'init',
          '--mode',
          'project',
        ], directory: d.path('app'));
      });

      test('Then dpk.yaml is created with the schema and starter scripts', () {
        final config = File(d.path('app/dpk.yaml')).readAsStringSync();
        expect(result.exitCode, equals(0), reason: '$result');
        expect(config, contains('yaml-language-server: \$schema='));
        expect(config, contains('version: $versionConstraint'));
        expect(config, contains('mode: project'));
        expect(config, contains('command: dart test'));
      });

      test('Then the project cache is ignored by git and the analyzer', () {
        expect(
          File(d.path('app/.gitignore')).readAsStringSync(),
          contains('pub_packages/'),
        );
        expect(
          File(d.path('app/analysis_options.yaml')).readAsStringSync(),
          contains('- pub_packages/**'),
        );
      });

      test('Then the next steps are printed', () {
        expect(result.stdout, contains('dpk get'));
      });

      test('Then the created config loads', () async {
        final listing = await dpk(['run'], directory: d.path('app'));
        expect(listing.stdout, contains('Run the tests.'));
      });
    });

    test(
      'When the version constraint is invalid then init fails before writing',
      () async {
        final result = await dpk([
          'init',
          '--version-constraint',
          'banana',
        ], directory: d.path('app'));

        expect(result.exitCode, equals(1));
        expect(File(d.path('app/dpk.yaml')).existsSync(), isFalse);
      },
    );

    test('When dpk.yaml exists then init refuses without --force', () async {
      await dpk(['init'], directory: d.path('app'));

      final result = await dpk(['init'], directory: d.path('app'));

      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('--force'));
    });
  });

  group('Given a workspace package', () {
    setUp(() async {
      await d.dir('repo', [
        d.file(
          'pubspec.yaml',
          pubspec('_', extra: 'workspace:\n  - packages/a\n'),
        ),
        d.dir('packages', [
          d.dir('a', [
            d.file(
              'pubspec.yaml',
              pubspec('a', extra: 'resolution: workspace\n'),
            ),
          ]),
        ]),
      ]).create();
    });

    test(
      'When running dpk init in it then dpk points to the workspace root',
      () async {
        final result = await dpk([
          'init',
        ], directory: d.path('repo/packages/a'));

        expect(result.exitCode, equals(1));
        expect(result.stderr, contains('Run dpk init at the workspace root'));
      },
    );
  });
}
