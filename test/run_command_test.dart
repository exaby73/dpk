import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'utils/dpk_test_utils.dart';

void main() {
  group('Given a package with scripts and hooks', () {
    setUp(() async {
      await d.dir('project', [
        d.file('pubspec.yaml', pubspec('sample')),
        d.file('dpk.yaml', '''
version: $versionConstraint
scripts:
  args:
    command: printf '<%s>' --fixed
    description: Print the arguments.
  where: pwd
  env:
    command: printf '%s|%s|%s' "\$GREETING" "\$DPK_PACKAGE_NAME" "\$DPK_ROOT"
    env:
      GREETING: 42
  dotenv:
    command: printf '%s|%s' "\$FROM_FILE" "\$OVERRIDDEN"
    env_file: .env.test
    env:
      OVERRIDDEN: env
  before:
    command: echo before >> hook.log
    scripts: [build]
  pre:build: echo pre >> hook.log
  build: echo build >> hook.log
  post:build: echo post >> hook.log
  after:
    command: echo after >> hook.log
    scripts: [build]
  watch:
    command: echo watch >> hook.log
    run_hooks_from: build
  fail: exit 3
  pre:guarded: exit 4
  guarded: echo guarded >> hook.log
'''),
      ]).create();
    });

    group('When passing options after the script name', () {
      late DpkResult result;

      setUp(() async {
        result = await dpk([
          'run',
          'args',
          '--coverage',
          '-v',
          '--help',
          '--version',
          '-C',
          'x',
          'a b',
        ], directory: d.path('project'));
      });

      test('Then the script receives every argument unchanged', () {
        expect(result.exitCode, equals(0), reason: '$result');
        expect(
          result.stdout,
          equals('<--fixed><--coverage><-v><--help><--version><-C><x><a b>'),
        );
      });

      test('Then dpk prints the command it runs on stderr', () {
        expect(
          result.stderr,
          contains("> args: printf '<%s>' --fixed --coverage"),
        );
      });
    });

    test(
      'When a leading -- separates the arguments then it is dropped',
      () async {
        final result = await dpk([
          'run',
          'args',
          '--',
          '--coverage',
        ], directory: d.path('project'));

        expect(result.stdout, equals('<--fixed><--coverage>'));
      },
    );

    test(
      'When running a script then env values and DPK variables are set',
      () async {
        final result = await dpk(['run', 'env'], directory: d.path('project'));

        expect(
          result.stdout,
          equals(
            '42|sample|${Directory(d.path('project')).resolveSymbolicLinksSync()}',
          ),
        );
      },
    );

    test(
      'When a script has an env_file then env overrides its values',
      () async {
        await d
            .file(
              'project/.env.test',
              '# comment\nexport FROM_FILE="file value"\nOVERRIDDEN=file\n',
            )
            .create();

        final result = await dpk([
          'run',
          'dotenv',
        ], directory: d.path('project'));

        expect(result.stdout, equals('file value|env'));
      },
    );

    test('When the env_file is missing then dpk says so', () async {
      final result = await dpk(['run', 'dotenv'], directory: d.path('project'));

      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('env_file'));
    });

    test('When running build then its hooks run in order', () async {
      await dpk(['run', 'build'], directory: d.path('project'));

      expect(
        File(d.path('project/hook.log')).readAsLinesSync(),
        equals(['before', 'pre', 'build', 'post', 'after']),
      );
    });

    test(
      'When a script uses run_hooks_from then the shared hooks apply too',
      () async {
        await dpk(['run', 'watch'], directory: d.path('project'));

        expect(
          File(d.path('project/hook.log')).readAsLinesSync(),
          equals(['before', 'pre', 'watch', 'post', 'after']),
        );
      },
    );

    test('When a script fails then dpk exits with its exit code', () async {
      final result = await dpk(['run', 'fail'], directory: d.path('project'));

      expect(result.exitCode, equals(3));
    });

    test('When a pre hook fails then the script does not run', () async {
      final result = await dpk([
        'run',
        'guarded',
      ], directory: d.path('project'));

      expect(result.exitCode, equals(4));
      expect(File(d.path('project/hook.log')).existsSync(), isFalse);
    });

    group('When running dpk run without a script', () {
      late DpkResult result;

      setUp(() async {
        result = await dpk(['run'], directory: d.path('project'));
      });

      test('Then it succeeds', () {
        expect(result.exitCode, equals(0));
      });

      test('Then scripts show their description, or else their command', () {
        expect(result.stdout, contains('args'));
        expect(result.stdout, contains('Print the arguments.'));
        expect(result.stdout, matches(RegExp(r'where +pwd')));
      });

      test('Then hooks are listed apart from scripts', () {
        final hooks = result.stdout.substring(result.stdout.indexOf('Hooks:'));
        expect(hooks, contains('runs before build'));
        expect(hooks, contains('pre:build'));
      });
    });

    test(
      'When running dpk run --help then it shows the same listing',
      () async {
        final result = await dpk([
          'run',
          '--help',
        ], directory: d.path('project'));

        expect(result.stdout, contains('Scripts:'));
      },
    );

    test(
      'When the script name is misspelled then dpk suggests the right one',
      () async {
        final result = await dpk([
          'run',
          'biuld',
        ], directory: d.path('project'));

        expect(result.exitCode, equals(64));
        expect(result.stderr, contains('build'));
      },
    );
  });

  group('Given a workspace with three packages', () {
    setUp(() async {
      await d.dir('repo', [
        d.file(
          'pubspec.yaml',
          pubspec(
            'root',
            extra:
                'workspace:\n  - packages/a\n  - packages/b\n  - packages/c\n',
          ),
        ),
        d.file('dpk.yaml', '''
version: $versionConstraint
scripts:
  where: pwd
  each:
    command: printf 'in %s' "\$DPK_PACKAGE_NAME"
    run_in_packages: [packages/*]
  typo:
    command: echo hi
    run_in_packages: [pakages/*]
  failing:
    command: if [ "\$DPK_PACKAGE_NAME" = b ]; then exit 5; fi; echo ok
    run_in_packages: [packages/*]
  ordered:
    command: echo "\$DPK_PACKAGE_NAME" >> "\$DPK_ROOT/order.log"
    run_in_packages: [packages/*]
    dependency_order: true
    concurrency: 1
  tail:
    command: printf 'no newline'
    run_in_packages: [packages/a, packages/b]
'''),
        d.dir('packages', [
          d.dir('a', [
            d.file(
              'pubspec.yaml',
              pubspec(
                'a',
                extra: 'resolution: workspace\ndependencies:\n  c: any\n',
              ),
            ),
            d.dir('lib'),
          ]),
          d.dir('b', [
            d.file(
              'pubspec.yaml',
              pubspec(
                'b',
                extra: 'resolution: workspace\ndependencies:\n  a: any\n',
              ),
            ),
          ]),
          d.dir('c', [
            d.file(
              'pubspec.yaml',
              pubspec('c', extra: 'resolution: workspace\n'),
            ),
          ]),
        ]),
      ]).create();
    });

    test(
      'When running a script from a workspace package then it runs there',
      () async {
        final result = await dpk([
          'run',
          'where',
        ], directory: d.path('repo/packages/a/lib'));

        expect(result.stdout.trim(), equals(_real(d.path('repo/packages/a'))));
      },
    );

    test(
      'When running a script with -C then it runs in that package',
      () async {
        final result = await dpk([
          '-C',
          'packages/b',
          'run',
          'where',
        ], directory: d.path('repo'));

        expect(result.stdout.trim(), equals(_real(d.path('repo/packages/b'))));
      },
    );

    group('When running a script in several packages', () {
      late DpkResult result;

      setUp(() async {
        result = await dpk(['run', 'each'], directory: d.path('repo'));
      });

      test('Then each line is prefixed with its package', () {
        expect(result.stdout, contains('a | in a'));
        expect(result.stdout, contains('b | in b'));
        expect(result.stdout, contains('c | in c'));
      });

      test('Then a summary lists every package', () {
        expect(result.stderr, contains('✓ a'));
        expect(result.stderr, contains('✓ c'));
      });

      test('Then no color codes are written to a non-terminal', () {
        expect(result.stdout + result.stderr, isNot(contains('\x1b[')));
      });
    });

    test('When the last line has no newline then it still appears', () async {
      final result = await dpk(['run', 'tail'], directory: d.path('repo'));

      expect(result.stdout, contains('a | no newline'));
      expect(result.stdout, contains('b | no newline'));
    });

    test(
      'When run_in_packages matches nothing then dpk fails and lists packages',
      () async {
        final result = await dpk(['run', 'typo'], directory: d.path('repo'));

        expect(result.exitCode, equals(1));
        expect(result.stderr, contains('matches no workspace packages'));
        expect(result.stderr, contains('a (packages/a)'));
      },
    );

    test('When one package fails then dpk exits with that exit code', () async {
      final result = await dpk(['run', 'failing'], directory: d.path('repo'));

      expect(result.exitCode, equals(5));
      expect(result.stderr, contains('✗ b (exit code 5)'));
    });

    test(
      'When --fail-fast is set and a package fails then later ones are skipped',
      () async {
        final result = await dpk([
          'run',
          '-j',
          '1',
          '--fail-fast',
          'failing',
        ], directory: d.path('repo'));

        expect(result.exitCode, equals(5));
        expect(result.stderr, contains('- c (stopped by --fail-fast)'));
      },
    );

    test('When --filter selects a package then only it runs', () async {
      final result = await dpk([
        'run',
        '--filter',
        'b',
        'each',
      ], directory: d.path('repo'));

      expect(result.stdout.trim(), equals('in b'));
    });

    test(
      'When dependency order is on then dependencies finish first',
      () async {
        await dpk(['run', 'ordered'], directory: d.path('repo'));

        expect(
          File(d.path('repo/order.log')).readAsLinesSync(),
          equals(['c', 'a', 'b']),
        );
      },
    );

    group('When running dpk exec', () {
      late DpkResult result;

      setUp(() async {
        result = await dpk([
          'exec',
          '--filter',
          'packages/a',
          '--filter',
          'c',
          '--',
          'printf',
          '%s-%s',
          r'$DPK_PACKAGE_NAME',
          'x',
        ], directory: d.path('repo'));
      });

      test('Then the command runs in the selected packages', () {
        expect(result.exitCode, equals(0), reason: '$result');
        expect(result.stdout, contains(r'a | $DPK_PACKAGE_NAME-x'));
        expect(result.stdout, contains(r'c | $DPK_PACKAGE_NAME-x'));
        expect(result.stdout, isNot(contains('b |')));
      });
    });

    test(
      'When dpk exec gets one argument then it runs as a shell command line',
      () async {
        final result = await dpk([
          'exec',
          '--filter',
          'a',
          r'echo "$DPK_PACKAGE_NAME" && echo done',
        ], directory: d.path('repo'));

        expect(result.stdout.trim().split('\n'), equals(['a', 'done']));
      },
    );

    group('When running dpk list', () {
      late DpkResult result;

      setUp(() async {
        result = await dpk(['list', '--graph'], directory: d.path('repo'));
      });

      test('Then every package is listed with its path', () {
        expect(result.stdout, contains('packages/a'));
        expect(result.stdout, contains('packages/c'));
      });

      test('Then the graph shows workspace dependencies', () {
        expect(result.stdout, contains('└─ c'));
      });
    });
  });
}

String _real(String path) =>
    p.normalize(Directory(path).resolveSymbolicLinksSync());
