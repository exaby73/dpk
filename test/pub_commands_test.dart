import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'utils/dpk_test_utils.dart';

void main() {
  group('Given a workspace in project mode with a catalog and hooks', () {
    late RecordingProcessRunner runner;

    setUp(() async {
      runner = RecordingProcessRunner();
      await d.dir('repo', [
        d.file(
          'pubspec.yaml',
          pubspec('_', extra: 'workspace:\n  - packages/a\n'),
        ),
        d.file('dpk.yaml', '''
version: $versionConstraint
mode: project
catalog:
  dependencies:
    http: ^1.2.0
scripts:
  pre:add: echo pre-add
  post:add: echo post-add
'''),
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

    group('When adding a catalog dependency from a workspace package', () {
      setUp(() async {
        await dpk(
          ['add', 'http', 'dev:http', 'path:^1.9.0', '-C', 'x'],
          directory: d.path('repo/packages/a'),
          processRunner: runner,
        );
      });

      test(
        'Then the catalog version is used and other arguments pass through',
        () {
          expect(
            runner.dartCommands,
            equals(['pub add http:^1.2.0 dev:http:^1.2.0 path:^1.9.0 -C x']),
          );
        },
      );

      test('Then pub runs in the workspace package, not the root', () {
        final dart = runner.processes.firstWhere((p) => p.executable == 'dart');
        expect(dart.workingDirectory, equals(_real(d.path('repo/packages/a'))));
      });

      test('Then pub uses the project cache at the workspace root', () {
        final dart = runner.processes.firstWhere((p) => p.executable == 'dart');
        expect(
          dart.environment!['PUB_CACHE'],
          equals(p.join(_real(d.path('repo')), 'pub_packages')),
        );
      });

      test('Then the hooks run around the command', () {
        expect(runner.scripts, equals(['echo pre-add', 'echo post-add']));
      });
    });

    test(
      'When running a global command then the project cache is not used',
      () async {
        await dpk(
          ['global', 'activate', 'dpk'],
          directory: d.path('repo'),
          processRunner: runner,
        );

        expect(
          runner.processes.single.environment,
          isNot(contains('PUB_CACHE')),
        );
      },
    );

    test(
      'When asking a pub command for help then it runs without hooks',
      () async {
        await dpk(
          ['add', '--help'],
          directory: d.path('repo'),
          processRunner: runner,
        );

        expect(runner.dartCommands, equals(['pub add --help']));
        expect(runner.scripts, isEmpty);
      },
    );

    test(
      'When passing -v before the command then pub gets --verbose',
      () async {
        await dpk(
          ['-v', 'deps', '--style=compact'],
          directory: d.path('repo'),
          processRunner: runner,
        );

        expect(
          runner.dartCommands,
          equals(['pub --verbose deps --style=compact']),
        );
      },
    );
  });

  group('Given no dpk project', () {
    test(
      'When running a pub command that needs no project then it runs',
      () async {
        final runner = RecordingProcessRunner();
        final empty = Directory.systemTemp.createTempSync('dpk_none');
        addTearDown(() => empty.deleteSync(recursive: true));

        final result = await dpk(
          ['global', 'list'],
          directory: empty.path,
          processRunner: runner,
        );

        expect(result.exitCode, equals(0));
        expect(runner.dartCommands, equals(['pub global list']));
      },
    );
  });

  group('Given a workspace whose dpk.yaml globs add packages', () {
    late RecordingProcessRunner runner;

    setUp(() async {
      runner = RecordingProcessRunner();
      await d.dir('repo', [
        d.file(
          'pubspec.yaml',
          '${pubspec('my_root')}workspace:\n  - packages/old\n',
        ),
        d.file('dpk.yaml', '''
version: $versionConstraint
sortPubspec: true
workspace:
  - packages/*
catalog:
  environment:
    sdk: ^3.11.0
  repository: https://github.com/o/r/tree/main/DPK_PACKAGE_PATH
  dependencies:
    http: ^1.2.0
scripts:
  pre:get: echo pre
  before:
    command: echo before
    scripts: [get]
  post:get: echo post
'''),
        d.dir('packages', [
          d.dir('a', [
            d.file(
              'pubspec.yaml',
              'name: a\nresolution: workspace\ndependencies:\n  http: ^1.0.0\n  args: ^2.0.0\n',
            ),
          ]),
          d.dir('stray', [d.file('pubspec.yaml', pubspec('stray'))]),
        ]),
      ]).create();
    });

    group('When checking with --check', () {
      late DpkResult result;

      setUp(() async {
        result = await dpk(
          ['get', '--check'],
          directory: d.path('repo'),
          processRunner: runner,
        );
      });

      test('Then it fails and lists the files dpk get would change', () {
        expect(result.exitCode, equals(1));
        expect(result.stderr, contains('pubspec.yaml'));
        expect(result.stderr, contains('dpk.yaml'));
      });

      test('Then nothing is written and pub does not run', () {
        expect(
          File(d.path('repo/packages/a/pubspec.yaml')).readAsStringSync(),
          contains('http: ^1.0.0'),
        );
        expect(runner.processes, isEmpty);
      });
    });

    group('When running dpk get', () {
      late DpkResult result;

      setUp(() async {
        result = await dpk(
          ['get', '--offline'],
          directory: d.path('repo/packages/a'),
          processRunner: runner,
        );
      });

      test(
        'Then the root workspace list holds only real workspace members',
        () {
          final root = File(d.path('repo/pubspec.yaml')).readAsStringSync();
          expect(root, contains('workspace:\n  - packages/a\n'));
          expect(root, isNot(contains('stray')));
        },
      );

      test('Then the catalog is applied to workspace packages and sorted', () {
        final a = File(
          d.path('repo/packages/a/pubspec.yaml'),
        ).readAsStringSync();
        expect(
          a,
          contains('repository: https://github.com/o/r/tree/main/packages/a'),
        );
        expect(
          a,
          contains(
            'dependencies:\n  args: ^2.0.0\n  http: ^1.2.0 # Configured via catalog',
          ),
        );
      });

      test('Then deprecated keys in dpk.yaml are renamed', () {
        expect(
          File(d.path('repo/dpk.yaml')).readAsStringSync(),
          contains('sort_pubspec: true'),
        );
      });

      test('Then pub get runs with the forwarded options', () {
        expect(runner.dartCommands, equals(['pub get --offline']));
      });

      test('Then the before hook runs after pub get', () {
        expect(
          runner.scripts,
          equals(['echo pre', 'echo before', 'echo post']),
        );
      });

      test('Then a check afterwards passes', () async {
        expect(result.exitCode, equals(0), reason: '$result');
        final check = await dpk(
          ['get', '--check'],
          directory: d.path('repo'),
          processRunner: runner,
        );
        expect(check.exitCode, equals(0), reason: '$check');
      });
    });

    group('When running dpk get --dry-run', () {
      late DpkResult result;

      setUp(() async {
        result = await dpk(
          ['get', '--dry-run'],
          directory: d.path('repo'),
          processRunner: runner,
        );
      });

      test('Then no file is written', () {
        expect(
          File(d.path('repo/packages/a/pubspec.yaml')).readAsStringSync(),
          contains('http: ^1.0.0'),
        );
        expect(
          File(d.path('repo/dpk.yaml')).readAsStringSync(),
          contains('sortPubspec'),
        );
      });

      test('Then dpk says what it would change and pub runs a dry run', () {
        expect(result.stderr, contains('Would update'));
        expect(runner.dartCommands, equals(['pub get --dry-run']));
      });
    });
  });

  group('Given a standalone package with sort_pubspec on', () {
    setUp(() async {
      await d.dir('app', [
        d.file(
          'pubspec.yaml',
          'dependencies:\n  b: any\n  a: any\nname: app\n',
        ),
        d.file('dpk.yaml', 'version: $versionConstraint\nsort_pubspec: true\n'),
      ]).create();
    });

    test('When running dpk get then its pubspec is sorted', () async {
      await dpk(
        ['get'],
        directory: d.path('app'),
        processRunner: RecordingProcessRunner(),
      );

      expect(
        File(d.path('app/pubspec.yaml')).readAsStringSync(),
        equals('name: app\n\ndependencies:\n  a: any\n  b: any\n'),
      );
    });
  });
}

String _real(String path) =>
    p.normalize(Directory(path).resolveSymbolicLinksSync());
