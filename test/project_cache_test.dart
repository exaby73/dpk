import 'dart:io';

import 'package:dpk/core/console.dart';
import 'package:dpk/core/errors.dart';
import 'package:dpk/core/process_runner.dart';
import 'package:dpk/patching/git.dart';
import 'package:dpk/patching/project_cache.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  late String root;
  late ProjectCache cache;
  late String package;

  setUp(() async {
    await d.dir('project', [
      d.file('pubspec.lock', _lockfile('1.0.0')),
      d.dir('pub_packages', [
        d.file('README.md', 'pub cache'),
        d.dir('hosted', [
          d.dir('pub.dev', [
            d.dir('foo-1.0.0', [
              d.file('pubspec.yaml', 'name: foo\nversion: 1.0.0\n'),
              d.file('CHANGELOG.md', '# 1.0.0\n'),
              d.dir('lib', [d.file('foo.dart', 'int answer() => 41;\n')]),
            ]),
          ]),
        ]),
      ]),
    ]).create();
    root = d.path('project');
    package = p.join(root, 'pub_packages', 'hosted', 'pub.dev', 'foo-1.0.0');
    cache = _cache(root);
  });

  group('Given a project cache with no baseline', () {
    test(
      'When syncing then a baseline is committed without a git identity',
      () async {
        await cache.sync();

        expect(cache.hasBaseline, isTrue);
        final log = await Process.run('git', [
          'log',
          '--format=%an',
        ], workingDirectory: p.join(root, 'pub_packages'));
        expect((log.stdout as String).trim(), equals('dpk'));
      },
    );

    test('When generating then dpk explains that a baseline is needed', () {
      expect(
        cache.generate,
        throwsA(
          isA<DpkException>().having(
            (e) => e.message,
            'message',
            contains('no baseline'),
          ),
        ),
      );
    });
  });

  group('Given a baseline and edits of every kind', () {
    setUp(() async {
      await cache.sync();
      File(
        p.join(package, 'lib', 'foo.dart'),
      ).writeAsStringSync('int answer() => 42;\n');
      File(p.join(package, 'CHANGELOG.md')).deleteSync();
      File(
        p.join(package, 'lib', 'new file.dart'),
      ).writeAsStringSync('// new\n');
      File(p.join(package, 'logo.bin')).writeAsBytesSync([0, 1, 2, 255, 0]);
    });

    group('When generating patches', () {
      late ({List<String> written, List<String> removed}) result;
      late String patch;

      setUp(() async {
        result = await cache.generate();
        patch = File(
          p.join(root, 'patches', 'hosted', 'foo-1.0.0.patch'),
        ).readAsStringSync();
      });

      test('Then one patch per package is written', () {
        expect(result.written, equals(['hosted/foo-1.0.0.patch']));
      });

      test(
        'Then edits, deletions, new files, and binary files are included',
        () {
          expect(patch, contains('+int answer() => 42;'));
          expect(patch, contains('deleted file mode'));
          expect(patch, contains('lib/new file.dart'));
          expect(patch, contains('GIT binary patch'));
        },
      );

      test('Then generating again changes nothing', () async {
        final again = await cache.generate();

        expect(again.written, isEmpty);
        expect(again.removed, isEmpty);
      });
    });

    group('When a teammate starts from a fresh cache and syncs', () {
      setUp(() async {
        await cache.generate();
        await _freshCache(root, package);
        await cache.sync();
      });

      test('Then the patch is applied', () {
        expect(
          File(p.join(package, 'lib', 'foo.dart')).readAsStringSync(),
          contains('42'),
        );
        expect(File(p.join(package, 'CHANGELOG.md')).existsSync(), isFalse);
        expect(
          File(p.join(package, 'logo.bin')).readAsBytesSync(),
          equals([0, 1, 2, 255, 0]),
        );
      });

      test('Then applying again reports nothing new', () async {
        expect(await cache.apply(), equals(0));
      });

      test('Then the patch state is applied', () async {
        expect(
          await cache.stateOf(cache.patches().single),
          equals(PatchState.applied),
        );
      });
    });
  });

  group('Given a patch made for an older version', () {
    setUp(() async {
      await cache.sync();
      File(
        p.join(package, 'lib', 'foo.dart'),
      ).writeAsStringSync('int answer() => 42;\n');
      await cache.generate();
      File(p.join(root, 'pubspec.lock')).writeAsStringSync(_lockfile('1.1.0'));
    });

    test(
      'When applying then dpk says the patch is stale and how to fix it',
      () {
        expect(
          cache.apply,
          throwsA(
            isA<DpkException>().having(
              (e) => e.message,
              'message',
              allOf(
                contains('was made for foo 1.0.0, but the lockfile uses 1.1.0'),
                contains('dpk patch generate'),
              ),
            ),
          ),
        );
      },
    );
  });

  group('Given edits that conflict with a saved patch', () {
    setUp(() async {
      await cache.sync();
      File(
        p.join(package, 'lib', 'foo.dart'),
      ).writeAsStringSync('int answer() => 42;\n');
      await cache.generate();
      await _freshCache(root, package);
      await cache.updateBaseline();
      File(
        p.join(package, 'lib', 'foo.dart'),
      ).writeAsStringSync('int answer() => 7;\n');
    });

    test('When applying then dpk refuses and offers --force', () {
      expect(
        cache.apply,
        throwsA(
          isA<DpkException>().having(
            (e) => e.message,
            'message',
            contains('apply --force'),
          ),
        ),
      );
    });

    test(
      'When applying with force then the edits are replaced by the patch',
      () async {
        await cache.apply(force: true);

        expect(
          File(p.join(package, 'lib', 'foo.dart')).readAsStringSync(),
          contains('42'),
        );
      },
    );
  });

  group('Given a patch directory set to the project root', () {
    setUp(() async {
      await d.file('project/keep.txt', 'important').create();
      cache = _cache(root, patchDirectory: root);
      await cache.sync();
      File(
        p.join(package, 'lib', 'foo.dart'),
      ).writeAsStringSync('int answer() => 42;\n');
    });

    test('When generating then only patch files are written', () async {
      await cache.generate();

      expect(
        File(p.join(root, 'keep.txt')).readAsStringSync(),
        equals('important'),
      );
      expect(
        File(p.join(root, 'hosted', 'foo-1.0.0.patch')).existsSync(),
        isTrue,
      );
    });
  });

  group('Given an applied patch', () {
    setUp(() async {
      await cache.sync();
      File(
        p.join(package, 'lib', 'foo.dart'),
      ).writeAsStringSync('int answer() => 42;\n');
      await cache.generate();
    });

    group('When removing it', () {
      late List<String> removed;

      setUp(() async {
        removed = await cache.remove('foo');
      });

      test('Then the patch file is deleted', () {
        expect(removed, equals(['hosted/foo-1.0.0.patch']));
        expect(cache.patches(), isEmpty);
      });

      test('Then the package is reset in the project cache', () {
        expect(
          File(p.join(package, 'lib', 'foo.dart')).readAsStringSync(),
          contains('41'),
        );
      });
    });

    test(
      'When the edit is undone and patches are generated then the patch is removed',
      () async {
        File(
          p.join(package, 'lib', 'foo.dart'),
        ).writeAsStringSync('int answer() => 41;\n');

        final result = await cache.generate();

        expect(result.removed, equals(['hosted/foo-1.0.0.patch']));
      },
    );
  });

  group('Given a git dependency checked out in the project cache', () {
    late String checkout;

    setUp(() async {
      checkout = await _gitCheckout(root);
      File(p.join(root, 'pubspec.lock')).writeAsStringSync(
        _lockfile('1.0.0', gitRef: p.basename(checkout).split('-').last),
      );
      await cache.sync();
      File(p.join(checkout, 'lib.dart')).writeAsStringSync('patched\n');
    });

    group(
      'When generating patches and starting over from a clean checkout',
      () {
        setUp(() async {
          await cache.generate();
          await Process.run('git', [
            'checkout',
            '--',
            '.',
          ], workingDirectory: checkout);
          await cache.sync();
        });

        test('Then the patch is stored under git/', () {
          expect(cache.patches().single.relativePath, startsWith('git/bar-'));
        });

        test('Then syncing applies it to the checkout', () {
          expect(
            File(p.join(checkout, 'lib.dart')).readAsStringSync(),
            equals('patched\n'),
          );
        });
      },
    );
  });

  group('Given pub downloaded a new package after the baseline', () {
    setUp(() async {
      await cache.sync();
      await d.dir('project/pub_packages/hosted/pub.dev/bar-2.0.0', [
        d.file('pubspec.yaml', 'name: bar\n'),
      ]).create();
    });

    test(
      'When generating then the new package is not mistaken for an edit',
      () async {
        final result = await cache.generate();

        expect(result.written, isEmpty);
      },
    );
  });
}

ProjectCache _cache(String root, {String? patchDirectory}) {
  final console = Console.buffered();
  return ProjectCache(
    cachePath: p.join(root, 'pub_packages'),
    patchPath: patchDirectory ?? p.join(root, 'patches'),
    lockfilePath: p.join(root, 'pubspec.lock'),
    git: Git(SystemProcessRunner(console)),
    console: console,
  );
}

/// Recreates the cache as a fresh `dpk get` would leave it: pristine package
/// files and no baseline.
Future<void> _freshCache(String root, String package) async {
  await Directory(p.join(root, 'pub_packages', '.git')).delete(recursive: true);
  await Directory(package).delete(recursive: true);
  await d.dir('project/pub_packages/hosted/pub.dev/foo-1.0.0', [
    d.file('pubspec.yaml', 'name: foo\nversion: 1.0.0\n'),
    d.file('CHANGELOG.md', '# 1.0.0\n'),
    d.dir('lib', [d.file('foo.dart', 'int answer() => 41;\n')]),
  ]).create();
}

/// Creates a git checkout of a `bar` package in the cache the way pub does,
/// and returns its path.
Future<String> _gitCheckout(String root) async {
  final staging = p.join(root, 'pub_packages', 'git', 'staging');
  Directory(staging).createSync(recursive: true);
  File(p.join(staging, 'lib.dart')).writeAsStringSync('original\n');
  Future<void> git(List<String> arguments) => Process.run('git', [
    '-c',
    'user.name=t',
    '-c',
    'user.email=t@t',
    ...arguments,
  ], workingDirectory: staging);
  await git(['init', '-q']);
  await git(['add', '-A']);
  await git(['commit', '-qm', 'initial']);
  final sha = (await Process.run('git', [
    'rev-parse',
    'HEAD',
  ], workingDirectory: staging)).stdout.toString().trim();
  final checkout = p.join(root, 'pub_packages', 'git', 'bar-$sha');
  Directory(staging).renameSync(checkout);
  return checkout;
}

String _lockfile(String version, {String? gitRef}) =>
    '''
packages:
  ${gitRef == null ? '' : '''bar:
    dependency: "direct main"
    description:
      path: "."
      ref: HEAD
      resolved-ref: $gitRef
      url: "https://example.com/bar.git"
    source: git
    version: "1.0.0"
  '''}foo:
    dependency: "direct main"
    description:
      name: foo
      url: "https://pub.dev"
    source: hosted
    version: "$version"
sdks:
  dart: ">=3.11.0 <4.0.0"
''';
