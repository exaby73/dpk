import 'dart:io';

import 'package:dpk/workspace/workspace.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'utils/dpk_test_utils.dart';

void main() {
  group('Given a pub workspace whose root package is not named _', () {
    setUp(() async {
      await d.dir('repo', [
        d.file(
          'pubspec.yaml',
          pubspec(
            'my_root',
            extra: 'workspace:\n  - packages/a\n  - packages/b\n',
          ),
        ),
        d.dir('packages', [
          d.dir('a', [
            d.file(
              'pubspec.yaml',
              pubspec(
                'a',
                extra: 'resolution: workspace\ndependencies:\n  b: any\n',
              ),
            ),
            d.dir('lib', [d.dir('src')]),
          ]),
          d.dir('b', [
            d.file(
              'pubspec.yaml',
              pubspec('b', extra: 'resolution: workspace\n'),
            ),
          ]),
        ]),
      ]).create();
    });

    group('When discovering from a folder inside a workspace package', () {
      late Workspace workspace;

      setUp(() {
        workspace = Workspace.discover(d.path('repo/packages/a/lib/src'))!;
      });

      test('Then the root is the directory with the workspace list', () {
        expect(workspace.root.name, equals('my_root'));
        expect(workspace.root.path, equals(canonicalPath(d.path('repo'))));
      });

      test('Then the current package is the enclosing workspace package', () {
        expect(workspace.current.name, equals('a'));
        expect(workspace.current.relativePath, equals('packages/a'));
      });

      test('Then every workspace package is listed with its dependencies', () {
        expect(workspace.packages.map((p) => p.name), equals(['a', 'b']));
        expect(workspace.packageNamed('a')!.dependencies, contains('b'));
      });
    });

    test(
      'When discovering from the root then the current package is the root',
      () {
        final workspace = Workspace.discover(d.path('repo'))!;

        expect(workspace.current, same(workspace.root));
      },
    );
  });

  group('Given a workspace declared only by dpk.yaml globs', () {
    setUp(() async {
      await d.dir('repo', [
        d.file('pubspec.yaml', pubspec('_')),
        d.file(
          'dpk.yaml',
          'version: $versionConstraint\nworkspace:\n  - packages/*\n',
        ),
        d.dir('packages', [
          d.dir('member', [
            d.file(
              'pubspec.yaml',
              pubspec('member', extra: 'resolution: workspace\n'),
            ),
          ]),
          d.dir('stray', [d.file('pubspec.yaml', pubspec('stray'))]),
          d.dir('.hidden', [
            d.file(
              'pubspec.yaml',
              pubspec('hidden', extra: 'resolution: workspace\n'),
            ),
          ]),
        ]),
      ]).create();
    });

    test('Then only packages with resolution: workspace are members', () {
      final workspace = Workspace.discover(d.path('repo'))!;

      expect(workspace.packages.map((p) => p.name), equals(['member']));
    });

    test('Then a stray package is its own standalone root', () {
      final workspace = Workspace.discover(d.path('repo/packages/stray'))!;

      expect(workspace.root.name, equals('stray'));
      expect(workspace.isWorkspace, isFalse);
    });
  });

  group('Given a standalone package', () {
    setUp(() async {
      await d.dir('app', [d.file('pubspec.yaml', pubspec('app'))]).create();
    });

    test('Then it is the root and the current package', () {
      final workspace = Workspace.discover(d.path('app'))!;

      expect(workspace.root.name, equals('app'));
      expect(workspace.current, same(workspace.root));
      expect(workspace.packages, isEmpty);
    });
  });

  group('Given a directory reached through a symbolic link', () {
    setUp(() async {
      await d.dir('real', [d.file('pubspec.yaml', pubspec('real'))]).create();
      Link(d.path('link')).createSync(d.path('real'));
    });

    test('Then the package path is the resolved real path', () {
      final workspace = Workspace.discover(d.path('link'))!;

      expect(workspace.root.path, equals(canonicalPath(d.path('real'))));
    });
  });

  group('Given a directory with no pubspec above it', () {
    test('Then discovery finds nothing', () {
      final empty = Directory.systemTemp.createTempSync('dpk_empty');
      addTearDown(() => empty.deleteSync(recursive: true));

      expect(Workspace.discover(p.join(empty.path)), isNull);
    });
  });
}
