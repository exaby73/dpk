@Timeout(Duration(minutes: 3))
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'utils/dpk_test_utils.dart';

void main() {
  group(
    'Given a project-mode workspace with a catalog, run through the executable',
    () {
      setUpAll(() async {
        await d.dir('repo', [
          d.file('pubspec.yaml', pubspec('my_root')),
          d.file('dpk.yaml', '''
version: $versionConstraint
mode: project
sort_pubspec: true
workspace:
  - packages/*
catalog:
  environment:
    sdk: ^3.11.0
  version: 1.2.3
  repository: https://example.com/DPK_PACKAGE_NAME
scripts:
  shared: echo "root \$DPK_PACKAGE_NAME"
  each:
    command: echo "in \$DPK_PACKAGE_NAME"
    run_in_packages: [packages/*]
  fail: exit 7
'''),
          d.dir('packages', [
            d.dir('core', [
              d.file('pubspec.yaml', 'name: core\nresolution: workspace\n'),
            ]),
            d.dir('app', [
              d.file(
                'pubspec.yaml',
                'name: app\nresolution: workspace\ndependencies:\n  core: any\n',
              ),
              d.file('dpk.yaml', 'scripts:\n  shared: echo "app override"\n'),
            ]),
          ]),
        ]).create();
      });

      group('When running dpk get', () {
        late ProcessResult result;

        setUpAll(() async {
          result = await _runExecutable([
            'get',
            '--offline',
          ], directory: d.path('repo'));
        });

        test('Then it succeeds', () {
          expect(
            result.exitCode,
            equals(0),
            reason: '${result.stdout}\n${result.stderr}',
          );
        });

        test('Then the workspace list is written to the root pubspec', () {
          expect(
            File(d.path('repo/pubspec.yaml')).readAsStringSync(),
            contains('workspace:\n  - packages/app\n  - packages/core\n'),
          );
        });

        test('Then the catalog metadata reaches each workspace package', () {
          final core = File(
            d.path('repo/packages/core/pubspec.yaml'),
          ).readAsStringSync();
          expect(core, contains('version: 1.2.3'));
          expect(core, contains('repository: https://example.com/core'));
        });

        test('Then pub resolves the workspace', () {
          expect(
            File(d.path('repo/.dart_tool/package_config.json')).existsSync(),
            isTrue,
          );
        });
      });

      test(
        'When running a script in a workspace package then its override wins',
        () async {
          final result = await _runExecutable([
            'run',
            'shared',
          ], directory: d.path('repo/packages/app'));

          expect(result.stdout, equals('app override\n'));
        },
      );

      test(
        'When running a script in a package without overrides then it runs there',
        () async {
          final result = await _runExecutable([
            'run',
            'shared',
          ], directory: d.path('repo/packages/core'));

          expect(result.stdout, equals('root core\n'));
        },
      );

      test(
        'When running a script across packages then each package reports',
        () async {
          final result = await _runExecutable([
            'run',
            'each',
          ], directory: d.path('repo'));

          expect(result.stdout, contains('core | in core'));
          expect(result.stdout, contains('app  | in app'));
        },
      );

      test(
        'When a script fails then the process exits with its exit code',
        () async {
          final result = await _runExecutable([
            'run',
            'fail',
          ], directory: d.path('repo'));

          expect(result.exitCode, equals(7));
        },
      );
    },
  );
}

/// Runs the real `bin/dpk.dart` entry point in a separate process.
Future<ProcessResult> _runExecutable(
  List<String> arguments, {
  required String directory,
}) => Process.run(
  Platform.resolvedExecutable,
  [p.join(Directory.current.path, 'bin', 'dpk.dart'), ...arguments],
  workingDirectory: directory,
  environment: {'NO_COLOR': '1'},
);
