import 'dart:io';

import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'utils/dpk_test_utils.dart';

void main() {
  group('Given a project-mode workspace with build output everywhere', () {
    setUp(() async {
      await d.dir('repo', [
        d.file(
          'pubspec.yaml',
          pubspec('_', extra: 'workspace:\n  - packages/a\n  - packages/app\n'),
        ),
        d.file('pubspec.lock', 'packages: {}\n'),
        d.file('dpk.yaml', '''
version: $versionConstraint
mode: project
scripts:
  pre:clean: echo pre-clean > hook.log
'''),
        d.dir('.dart_tool', [d.file('package_config.json', '{}')]),
        d.dir('pub_packages', [d.dir('hosted')]),
        d.dir('packages', [
          d.dir('a', [
            d.file(
              'pubspec.yaml',
              pubspec('a', extra: 'resolution: workspace\n'),
            ),
            d.dir('build', [d.file('out.txt', 'x')]),
            d.dir('lib', [d.file('a.dart', '')]),
          ]),
          d.dir('app', [
            d.file(
              'pubspec.yaml',
              pubspec(
                'app',
                extra:
                    'resolution: workspace\ndependencies:\n  flutter:\n    sdk: flutter\n',
              ),
            ),
            d.dir('.dart_tool', [d.file('x', '')]),
            d.dir('build', [d.file('app.apk', '')]),
          ]),
        ]),
      ]).create();
    });

    group('When cleaning', () {
      late DpkResult result;

      setUp(() async {
        result = await dpk(['clean'], directory: d.path('repo'));
      });

      test('Then .dart_tool and build are removed everywhere', () {
        expect(result.exitCode, equals(0), reason: '$result');
        expect(Directory(d.path('repo/.dart_tool')).existsSync(), isFalse);
        expect(
          Directory(d.path('repo/packages/a/build')).existsSync(),
          isFalse,
        );
        expect(
          Directory(d.path('repo/packages/app/build')).existsSync(),
          isFalse,
        );
        expect(
          Directory(d.path('repo/packages/app/.dart_tool')).existsSync(),
          isFalse,
        );
      });

      test('Then sources, the lockfile, and the project cache stay', () {
        expect(File(d.path('repo/packages/a/lib/a.dart')).existsSync(), isTrue);
        expect(File(d.path('repo/pubspec.lock')).existsSync(), isTrue);
        expect(Directory(d.path('repo/pub_packages')).existsSync(), isTrue);
      });

      test('Then the clean hooks run', () {
        expect(
          File(d.path('repo/hook.log')).readAsStringSync(),
          contains('pre-clean'),
        );
      });
    });

    test('When cleaning with --dry-run then nothing is removed', () async {
      final result = await dpk([
        'clean',
        '--dry-run',
      ], directory: d.path('repo'));

      expect(result.stdout, contains('Would remove packages/a/build'));
      expect(Directory(d.path('repo/packages/a/build')).existsSync(), isTrue);
    });

    test(
      'When cleaning with --filter then other packages are untouched',
      () async {
        await dpk(['clean', '--filter', 'a'], directory: d.path('repo'));

        expect(
          Directory(d.path('repo/packages/a/build')).existsSync(),
          isFalse,
        );
        expect(
          Directory(d.path('repo/packages/app/build')).existsSync(),
          isTrue,
        );
        expect(Directory(d.path('repo/.dart_tool')).existsSync(), isTrue);
      },
    );

    test(
      'When cleaning with --lockfile and --cache then both are removed',
      () async {
        await dpk([
          'clean',
          '--lockfile',
          '--cache',
        ], directory: d.path('repo'));

        expect(File(d.path('repo/pubspec.lock')).existsSync(), isFalse);
        expect(Directory(d.path('repo/pub_packages')).existsSync(), isFalse);
      },
    );

    test(
      'When flutter is on PATH then Flutter packages run flutter clean',
      () async {
        final bin = Directory(d.path('fake-bin'))..createSync();
        final flutter = File('${bin.path}/flutter')
          ..writeAsStringSync(
            '#!/bin/sh\necho "flutter \$*" > "\$PWD/flutter.log"\n',
          );
        await Process.run('chmod', ['755', flutter.path]);

        final result = await dpk(
          ['clean'],
          directory: d.path('repo'),
          environment: {'PATH': bin.path},
        );

        expect(result.exitCode, equals(0), reason: '$result');
        expect(
          File(d.path('repo/packages/app/flutter.log')).readAsStringSync(),
          contains('flutter clean'),
        );
        expect(
          File(d.path('repo/packages/a/flutter.log')).existsSync(),
          isFalse,
        );
      },
      testOn: '!windows',
    );
  });

  group('Given a project in global mode', () {
    setUp(() async {
      await d.dir('app', [
        d.file('pubspec.yaml', pubspec('app')),
        d.file('dpk.yaml', 'version: $versionConstraint\n'),
      ]).create();
    });

    test(
      'When cleaning with --cache then dpk explains it needs project mode',
      () async {
        final result = await dpk([
          'clean',
          '--cache',
        ], directory: d.path('app'));

        expect(result.exitCode, equals(1));
        expect(result.stderr, contains('only exists in project mode'));
      },
    );

    test('When nothing needs cleaning then dpk says so', () async {
      final result = await dpk(['clean'], directory: d.path('app'));

      expect(result.stdout, contains('Nothing to clean.'));
    });
  });
}
