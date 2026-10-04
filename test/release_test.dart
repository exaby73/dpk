import 'dart:convert';
import 'dart:io';

import 'package:dpk/release/conventional_commit.dart';
import 'package:dpk/release/release_plan.dart';
import 'package:dpk/workspace/workspace.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'utils/dpk_test_utils.dart';

void main() {
  group('Given conventional commit subjects', () {
    test('Then type, scope, and breaking marks are read', () {
      final commit = ConventionalCommit.parse('h', 'feat(cli)!: Add exec', '')!;

      expect(commit.type, equals('feat'));
      expect(commit.scope, equals('cli'));
      expect(commit.breaking, isTrue);
      expect(commit.bump, equals(Bump.major));
    });

    test('Then a BREAKING CHANGE footer marks a commit as breaking', () {
      final commit = ConventionalCommit.parse(
        'h',
        'fix: Tweak',
        'BREAKING CHANGE: gone',
      )!;

      expect(commit.bump, equals(Bump.major));
    });

    test('Then features and fixes ask for minor and patch bumps', () {
      expect(ConventionalCommit.parse('h', 'feat: x', '')!.bump, Bump.minor);
      expect(ConventionalCommit.parse('h', 'fix: x', '')!.bump, Bump.patch);
      expect(ConventionalCommit.parse('h', 'chore: x', '')!.bump, Bump.none);
    });

    test('Then subjects outside the format are ignored', () {
      expect(ConventionalCommit.parse('h', 'Update readme', ''), isNull);
    });
  });

  group('Given versions to raise', () {
    final cases = {
      ('1.2.3', Bump.major): '2.0.0',
      ('1.2.3', Bump.minor): '1.3.0',
      ('1.2.3', Bump.patch): '1.2.4',
      ('0.8.3', Bump.major): '0.9.0',
      ('0.8.3', Bump.minor): '0.8.4',
      ('0.8.3', Bump.patch): '0.8.4',
      ('1.0.0-beta.2', Bump.patch): '1.0.0',
    };

    for (final MapEntry(key: (from, bump), value: to) in cases.entries) {
      test(
        'When applying a ${bump.name} bump to $from then it becomes $to',
        () {
          expect(nextVersion(Version.parse(from), bump).toString(), equals(to));
        },
      );
    }

    test('When asking for a pre-release then the number counts up', () {
      expect(
        nextVersion(
          Version.parse('1.2.3'),
          Bump.minor,
          prerelease: 'beta',
        ).toString(),
        equals('1.3.0-beta.0'),
      );
      expect(
        nextVersion(
          Version.parse('1.3.0-beta.0'),
          Bump.minor,
          prerelease: 'beta',
        ).toString(),
        equals('1.3.0-beta.1'),
      );
    });

    test('When graduating then the pre-release suffix is dropped', () {
      expect(
        nextVersion(
          Version.parse('2.0.0-rc.1'),
          Bump.none,
          graduate: true,
        ).toString(),
        equals('2.0.0'),
      );
    });
  });

  group('Given a workspace where app depends on core', () {
    final core = _package('core', '1.0.0');
    final app = _package('app', '1.0.0', dependencies: {'core'});
    final idle = _package('idle', '1.0.0');

    group('When core gets a feature', () {
      late List<PackageRelease> releases;

      setUp(() {
        releases = planRelease(
          packages: [core, app, idle],
          commits: {
            'core': [ConventionalCommit.parse('a1', 'feat: Add cache', '')!],
          },
          constraints: {
            'app': {'core': '>=1.0.0 <1.1.0'},
          },
        );
      });

      test('Then core gets a minor release', () {
        expect(releases.first.to.toString(), equals('1.1.0'));
      });

      test('Then app gets a patch release with its constraint raised', () {
        final appRelease = releases.firstWhere((r) => r.package.name == 'app');
        expect(appRelease.to.toString(), equals('1.0.1'));
        expect(appRelease.constraintUpdates, equals({'core': '^1.1.0'}));
      });

      test('Then packages without changes are not released', () {
        expect(releases.map((r) => r.package.name), isNot(contains('idle')));
      });

      test('Then the changelog lists the feature', () {
        expect(
          releases.first.changelogEntry(),
          equals('## 1.1.0\n\n- Feat: Add cache\n'),
        );
      });
    });

    test(
      'When the catalog sets a shared version then every package gets it',
      () {
        final releases = planRelease(
          packages: [core, app, idle],
          commits: {
            'app': [ConventionalCommit.parse('a1', 'fix: Crash', '')!],
          },
          sharedVersion: Version.parse('1.0.0'),
        );

        expect(releases.map((r) => r.to.toString()).toSet(), equals({'1.0.1'}));
        expect(releases, hasLength(3));
      },
    );
  });

  group('Given an existing changelog with a title', () {
    test('When prepending then the entry goes under the title', () {
      expect(
        prependChangelog(
          '# Changelog\n\n## 1.0.0\n\n- Feat: A\n',
          '## 1.1.0\n\n- Fix: B\n',
        ),
        equals(
          '# Changelog\n\n## 1.1.0\n\n- Fix: B\n\n## 1.0.0\n\n- Feat: A\n',
        ),
      );
    });
  });

  group('Given a git workspace with releases tagged and new commits', () {
    setUp(() async {
      await d.dir('repo', [
        d.file(
          'pubspec.yaml',
          pubspec(
            '_',
            extra: 'workspace:\n  - packages/core\n  - packages/app\n',
          ),
        ),
        d.file(
          'dpk.yaml',
          'version: $versionConstraint\nscripts:\n'
              '  post:version: echo regenerated > generated.txt\n',
        ),
        d.file('generated.txt', 'stale\n'),
        d.dir('packages', [
          d.dir('core', [
            d.file(
              'pubspec.yaml',
              'name: core\nversion: 1.0.0\nresolution: workspace\n',
            ),
            d.file('CHANGELOG.md', '## 1.0.0\n\n- Feat: First\n'),
          ]),
          d.dir('app', [
            d.file(
              'pubspec.yaml',
              'name: app\nversion: 2.0.0\nresolution: workspace\ndependencies:\n  core: ">=1.0.0 <1.1.0"\n',
            ),
          ]),
        ]),
      ]).create();
      final root = d.path('repo');
      await _git(['init', '-q'], root);
      await _git(['add', '-A'], root);
      await _git(['commit', '-qm', 'chore: Initial'], root);
      await _git(['tag', 'core-v1.0.0'], root);
      await _git(['tag', 'app-v2.0.0'], root);
      File(d.path('repo/packages/core/lib.dart')).writeAsStringSync('// new');
      await _git(['add', '-A'], root);
      await _git(['commit', '-qm', 'feat(core): Add lib'], root);
    });

    test(
      'When running a dry run then the plan and changelogs are printed',
      () async {
        final result = await dpk([
          'release',
          'version',
          '--dry-run',
        ], directory: d.path('repo'));

        expect(result.exitCode, equals(0), reason: '$result');
        expect(result.stdout, contains('core 1.0.0 -> 1.1.0'));
        expect(result.stdout, contains('app 2.0.0 -> 2.0.1'));
        expect(result.stdout, contains('- Feat: Add lib'));
      },
    );

    group('When releasing', () {
      late DpkResult result;

      setUp(() async {
        result = await dpk(
          ['release', 'version', '--yes'],
          directory: d.path('repo'),
          environment: _gitIdentity,
        );
      });

      test('Then the versions and constraints are updated', () {
        expect(result.exitCode, equals(0), reason: '$result');
        expect(
          File(d.path('repo/packages/core/pubspec.yaml')).readAsStringSync(),
          contains('version: 1.1.0'),
        );
        final app = File(
          d.path('repo/packages/app/pubspec.yaml'),
        ).readAsStringSync();
        expect(app, contains('version: 2.0.1'));
        expect(app, contains('core: ^1.1.0'));
      });

      test('Then the changelogs get new entries on top', () {
        expect(
          File(d.path('repo/packages/core/CHANGELOG.md')).readAsStringSync(),
          startsWith('## 1.1.0\n\n- Feat: Add lib\n\n## 1.0.0'),
        );
        expect(
          File(d.path('repo/packages/app/CHANGELOG.md')).readAsStringSync(),
          contains('- Chore: Update core to ^1.1.0'),
        );
      });

      test('Then the release is committed and tagged', () async {
        final tags = await _git(['tag', '--list'], d.path('repo'));
        final log = await _git(['log', '-1', '--format=%s'], d.path('repo'));
        expect(tags.split('\n'), containsAll(['core-v1.1.0', 'app-v2.0.1']));
        expect(log.trim(), equals('chore: Release packages'));
      });

      test(
        'Then the tags are annotated, so --follow-tags pushes them',
        () async {
          final type = await _git([
            'cat-file',
            '-t',
            'core-v1.1.0',
          ], d.path('repo'));
          expect(type.trim(), equals('tag'));
        },
      );

      test(
        'Then files a post:version hook changes are in the release commit',
        () async {
          final files = await _git([
            'show',
            '--name-only',
            '--format=',
            'HEAD',
          ], d.path('repo'));
          final status = await _git(['status', '--porcelain'], d.path('repo'));
          expect(files.split('\n'), contains('generated.txt'));
          expect(status.trim(), isEmpty);
        },
      );
    });

    test(
      'When the working tree has changes then dpk refuses to release',
      () async {
        File(d.path('repo/dirty.txt')).writeAsStringSync('x');

        final result = await dpk(
          ['release', 'version', '--yes'],
          directory: d.path('repo'),
          environment: _gitIdentity,
        );

        expect(result.exitCode, equals(1));
        expect(result.stderr, contains('working tree has changes'));
      },
    );
  });

  group('Given packages and a pub server that already has one of them', () {
    late HttpServer server;
    late RecordingProcessRunner runner;

    setUp(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) {
        final published = {
          'core': ['1.0.0'],
        };
        final name = request.uri.pathSegments.last;
        final versions = published[name];
        request.response.statusCode = versions == null ? 404 : 200;
        request.response.write(
          jsonEncode({
            'versions': [
              for (final v in versions ?? <String>[]) {'version': v},
            ],
          }),
        );
        request.response.close();
      });
      addTearDown(server.close);
      runner = RecordingProcessRunner();

      await d.dir('repo', [
        d.file(
          'pubspec.yaml',
          pubspec(
            '_',
            extra:
                'workspace:\n  - packages/core\n  - packages/app\n  - packages/private\n',
          ),
        ),
        d.file('dpk.yaml', 'version: $versionConstraint\n'),
        d.dir('packages', [
          d.dir('app', [
            d.file(
              'pubspec.yaml',
              'name: app\nversion: 1.0.0\nresolution: workspace\ndependencies:\n  core: any\n',
            ),
          ]),
          d.dir('core', [
            d.file(
              'pubspec.yaml',
              'name: core\nversion: 1.1.0\nresolution: workspace\n',
            ),
          ]),
          d.dir('private', [
            d.file(
              'pubspec.yaml',
              'name: private\nversion: 1.0.0\npublish_to: none\nresolution: workspace\n',
            ),
          ]),
        ]),
      ]).create();
    });

    group('When publishing', () {
      late DpkResult result;

      setUp(() async {
        result = await dpk(
          ['release', 'publish', '--yes'],
          directory: d.path('repo'),
          processRunner: runner,
          environment: {
            'PUB_HOSTED_URL': 'http://${server.address.host}:${server.port}',
          },
        );
      });

      test('Then unpublished versions are published, dependencies first', () {
        expect(result.exitCode, equals(0), reason: '$result');
        expect([
          for (final process in runner.processes)
            if (process.executable == 'dart')
              process.workingDirectory!.split('/').last,
        ], equals(['core', 'app']));
        expect(
          runner.dartCommands,
          everyElement(equals('pub publish --force')),
        );
      });

      test('Then publish_to: none packages are skipped', () {
        expect(result.stdout, isNot(contains('private')));
      });
    });
  });

  group('Given a git workspace whose versions are not on the pub server', () {
    late HttpServer server;
    late RecordingProcessRunner runner;

    setUp(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) {
        request.response.statusCode = 404;
        request.response.close();
      });
      addTearDown(server.close);
      runner = RecordingProcessRunner(passThrough: {'git'});
    });

    Future<DpkResult> publish(List<String> extra) => dpk(
      ['release', 'publish', '--yes', ...extra],
      directory: d.path('repo'),
      processRunner: runner,
      environment: {
        ..._gitIdentity,
        'PUB_HOSTED_URL': 'http://${server.address.host}:${server.port}',
      },
    );

    group('When publishing', () {
      late DpkResult result;

      setUp(() async {
        await _publishFixture(clean: true);
        result = await publish(const []);
      });

      test(
        'Then each published version without a tag gets an annotated tag',
        () async {
          expect(result.exitCode, equals(0), reason: '$result');
          final type = await _git([
            'cat-file',
            '-t',
            'core-v1.1.0',
          ], d.path('repo'));
          expect(type.trim(), equals('tag'));
        },
      );

      test('Then dpk says how to push the new tags', () {
        expect(result.stdout, contains('git push origin core-v1.1.0'));
        expect(result.stdout, isNot(contains('Tagged app-v1.0.0')));
      });
    });

    test('When publishing with --no-tag then no tag is created', () async {
      await _publishFixture(clean: true);

      await publish(['--no-tag']);

      final tags = await _git(['tag', '--list'], d.path('repo'));
      expect(tags.trim().split('\n'), equals(['app-v1.0.0']));
    });

    test('When the working tree has changes then dpk refuses to tag', () async {
      await _publishFixture(clean: false);

      final result = await publish(const []);

      expect(result.exitCode, equals(1));
      expect(result.stderr, contains('pass --no-tag'));
      expect(runner.dartCommands, isEmpty);
    });
  });
}

Future<void> _publishFixture({required bool clean}) async {
  await d.dir('repo', [
    d.file(
      'pubspec.yaml',
      pubspec('_', extra: 'workspace:\n  - packages/core\n  - packages/app\n'),
    ),
    d.file('dpk.yaml', 'version: $versionConstraint\n'),
    d.dir('packages', [
      d.dir('app', [
        d.file(
          'pubspec.yaml',
          'name: app\nversion: 1.0.0\nresolution: workspace\n',
        ),
      ]),
      d.dir('core', [
        d.file(
          'pubspec.yaml',
          'name: core\nversion: 1.1.0\nresolution: workspace\n',
        ),
      ]),
    ]),
  ]).create();
  final root = d.path('repo');
  await _git(['init', '-q'], root);
  await _git(['add', '-A'], root);
  await _git(['commit', '-qm', 'chore: Initial'], root);
  await _git(['tag', '-a', 'app-v1.0.0', '-m', 'app 1.0.0'], root);
  if (!clean) {
    File(d.path('repo/dirty.txt')).writeAsStringSync('x');
  }
}

WorkspacePackage _package(
  String name,
  String version, {
  Set<String> dependencies = const {},
}) => WorkspacePackage(
  name: name,
  path: '/w/packages/$name',
  relativePath: 'packages/$name',
  version: version,
  dependencies: dependencies,
);

/// A git identity and no signing, so release commits work on any machine.
const _gitIdentity = {
  'GIT_AUTHOR_NAME': 'test',
  'GIT_AUTHOR_EMAIL': 'test@example.com',
  'GIT_COMMITTER_NAME': 'test',
  'GIT_COMMITTER_EMAIL': 'test@example.com',
  'GIT_CONFIG_COUNT': '2',
  'GIT_CONFIG_KEY_0': 'commit.gpgsign',
  'GIT_CONFIG_VALUE_0': 'false',
  'GIT_CONFIG_KEY_1': 'tag.gpgsign',
  'GIT_CONFIG_VALUE_1': 'false',
};

Future<String> _git(List<String> arguments, String directory) async {
  final result = await Process.run('git', [
    '-c',
    'user.name=test',
    '-c',
    'user.email=test@example.com',
    '-c',
    'commit.gpgsign=false',
    '-c',
    'tag.gpgsign=false',
    ...arguments,
  ], workingDirectory: directory);
  return result.stdout as String;
}
