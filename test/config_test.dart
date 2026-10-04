import 'package:dpk/config/config_migration.dart';
import 'package:dpk/config/config_reader.dart';
import 'package:dpk/config/project.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'utils/dpk_test_utils.dart';

void main() {
  group('Given dpk.yaml files with mistakes', () {
    final cases = {
      'a misspelled top-level key': (
        'sortpubspec: true\n',
        'Unknown key "sortpubspec" at the top level. Did you mean "sort_pubspec"?',
      ),
      'a misspelled mode': (
        'mode: projct\n',
        'mode: "projct" is not a mode. Use "global" or "project".',
      ),
      'a script without a command': (
        'scripts:\n  hello:\n    description: Say hi\n',
        'scripts.hello.command is required.',
      ),
      'a script with a misspelled key': (
        'scripts:\n  hello:\n    command: echo hi\n    run_in_package: [a]\n',
        'Did you mean "run_in_packages"?',
      ),
      'run_in_packages given as text': (
        'scripts:\n  hello:\n    command: echo hi\n    run_in_packages: packages/*\n',
        'scripts.hello.run_in_packages: expected a list, found text.',
      ),
      'env with a nested value': (
        'scripts:\n  hello:\n    command: echo hi\n    env:\n      A:\n        - 1\n',
        'scripts.hello.env.A: expected text, found a list.',
      ),
      'sort_pubspec given as text': (
        'sort_pubspec: yes-please\n',
        'sort_pubspec: expected true or false, found text.',
      ),
      'run_hooks_from naming a missing script': (
        'scripts:\n  build: echo b\n  watch:\n    command: echo w\n    run_hooks_from: biuld\n',
        'no script named "biuld". Did you mean "build"?',
      ),
      'scripts on a script that is not a shared hook': (
        'scripts:\n  build:\n    command: echo b\n    scripts: [x]\n',
        '"scripts" only applies to the shared hooks "before" and "after".',
      ),
      'the legacy nested dpk mapping': (
        'dpk:\n  mode: project\n',
        'The nested "dpk:" mapping is no longer supported.',
      ),
      'an invalid catalog resolution': (
        'catalog:\n  resolution: hosted\n',
        'catalog.resolution: "hosted" is not a resolution.',
      ),
    };

    for (final MapEntry(key: description, value: (body, message))
        in cases.entries) {
      test(
        'When the file has $description then the error explains it',
        () async {
          await d.dir('project', [
            d.file('pubspec.yaml', pubspec('sample')),
            d.file('dpk.yaml', 'version: $versionConstraint\n$body'),
          ]).create();

          expect(
            () => Project.load(d.path('project')),
            throwsA(
              isA<ConfigException>().having(
                (e) => e.toString(),
                'message',
                allOf(contains('dpk.yaml:'), contains(message)),
              ),
            ),
          );
        },
      );
    }
  });

  group('Given a dpk.yaml that needs a newer dpk and has new keys', () {
    setUp(() async {
      await d.dir('project', [
        d.file('pubspec.yaml', pubspec('sample')),
        d.file('dpk.yaml', 'version: ^99.0.0\nfuture_key: true\n'),
      ]).create();
    });

    test(
      'Then the version mismatch is reported instead of the unknown key',
      () {
        expect(
          () => Project.load(d.path('project')),
          throwsA(
            isA<ProjectException>().having(
              (e) => e.message,
              'message',
              allOf(
                contains('requires dpk ^99.0.0'),
                contains('dart install dpk'),
              ),
            ),
          ),
        );
      },
    );
  });

  group('Given a version that is not a constraint', () {
    setUp(() async {
      await d.dir('project', [
        d.file('pubspec.yaml', pubspec('sample')),
        d.file('dpk.yaml', 'version: banana\n'),
      ]).create();
    });

    test('Then the error names the key and shows an example', () {
      expect(
        () => Project.load(d.path('project')),
        throwsA(
          isA<ConfigException>().having(
            (e) => e.toString(),
            'message',
            contains(
              '"banana" is not a version constraint. Use one like ^1.0.0.',
            ),
          ),
        ),
      );
    });
  });

  group('Given an empty dpk.yaml', () {
    setUp(() async {
      await d.dir('project', [
        d.file('pubspec.yaml', pubspec('sample')),
        d.file('dpk.yaml', ''),
      ]).create();
    });

    test('Then the error says the file is empty', () {
      expect(
        () => Project.load(d.path('project')),
        throwsA(
          isA<ConfigException>().having(
            (e) => e.toString(),
            'message',
            contains('The file is empty'),
          ),
        ),
      );
    });
  });

  group('Given a package without a dpk.yaml', () {
    setUp(() async {
      await d.dir('project', [
        d.file('pubspec.yaml', pubspec('sample')),
      ]).create();
    });

    test('Then the error suggests dpk init', () {
      expect(
        () => Project.load(d.path('project')),
        throwsA(
          isA<ProjectException>().having(
            (e) => e.message,
            'message',
            contains('Run "dpk init" to create one.'),
          ),
        ),
      );
    });
  });

  group('Given legacy camelCase keys', () {
    late Project project;

    setUp(() async {
      await d.dir('project', [
        d.file('pubspec.yaml', pubspec('sample')),
        d.file(
          'dpk.yaml',
          'version: $versionConstraint\nsortPubspec: true\nscripts:\n'
              '  build: echo b\n  watch:\n    command: echo w\n'
              '    runHooksFrom: build\n',
        ),
      ]).create();
      project = Project.load(d.path('project'));
    });

    test('Then the values still apply', () {
      expect(project.config.sortPubspec, isTrue);
      expect(project.scripts['watch']!.runHooksFrom, equals('build'));
    });

    test('Then each one produces a deprecation warning with its location', () {
      expect(project.warnings.map((w) => w.toString()), [
        endsWith(
          'dpk.yaml:2:1: "sortPubspec" is deprecated. Rename it to '
          '"sort_pubspec"; "dpk get" does this for you.',
        ),
        endsWith(
          'dpk.yaml:7:5: "scripts.watch.runHooksFrom" is deprecated. Rename '
          'it to "run_hooks_from"; "dpk get" does this for you.',
        ),
      ]);
    });
  });

  group('Given a workspace package with its own dpk.yaml', () {
    setUp(() async {
      await d.dir('repo', [
        d.file(
          'pubspec.yaml',
          pubspec('_', extra: 'workspace:\n  - packages/a\n'),
        ),
        d.file(
          'dpk.yaml',
          'version: $versionConstraint\nmode: project\nscripts:\n'
              '  shared: echo root\n  root_only: echo root\n',
        ),
        d.dir('packages', [
          d.dir('a', [
            d.file(
              'pubspec.yaml',
              pubspec('a', extra: 'resolution: workspace\n'),
            ),
            d.file('dpk.yaml', 'scripts:\n  shared: echo package\n'),
          ]),
        ]),
      ]).create();
    });

    group('When loading the project from the package', () {
      late Project project;

      setUp(() {
        project = Project.load(d.path('repo/packages/a'));
      });

      test('Then package scripts override root scripts', () {
        expect(project.scripts['shared']!.command, equals('echo package'));
        expect(project.scripts['root_only']!.command, equals('echo root'));
      });

      test('Then the root config still applies', () {
        expect(project.isProjectMode, isTrue);
      });

      test('Then the project cache is resolved at the workspace root', () {
        expect(project.cacheDirectory, endsWith('repo/pub_packages'));
      });
    });

    test(
      'When the package config sets mode then the error points to the root',
      () async {
        await d.file('repo/packages/a/dpk.yaml', 'mode: project\n').create();

        expect(
          () => Project.load(d.path('repo/packages/a')),
          throwsA(
            isA<ConfigException>().having(
              (e) => e.toString(),
              'message',
              contains('"mode" is only allowed in the workspace root config.'),
            ),
          ),
        );
      },
    );
  });

  group('Given a dpk.yaml with deprecated keys and comments', () {
    const before = '''
# Project config
version: ^1.0.0
sortPubspec: true # keep sorted
scripts:
  watch:
    runHooksFrom: build # inherit
    runInPackages:
      - packages/*
''';

    test('When migrating then only the key names change', () {
      expect(
        migrateConfig(before),
        equals('''
# Project config
version: ^1.0.0
sort_pubspec: true # keep sorted
scripts:
  watch:
    run_hooks_from: build # inherit
    run_in_packages:
      - packages/*
'''),
      );
    });
  });
}
