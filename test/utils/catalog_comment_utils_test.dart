import 'package:dpk/utils/catalog_comment_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Given the catalog comment helper', () {
    test(
      'When a hosted dependency is catalog-managed then an inline comment is added',
      () {
        final yaml = '''
dependencies:
  meta: 1.15.0
''';
        final result = addCatalogCommentsToDependencies(yaml, {'meta'});

        expect(result, contains('meta: 1.15.0 # Configured via catalog'));
      },
    );

    test(
      'When a git dependency is catalog-managed then the key line is commented',
      () {
        final yaml = '''
dependencies:
  luthor:
    git:
      url: https://github.com/exaby73/luthor.git
''';
        final result = addCatalogCommentsToDependencies(yaml, {'luthor'});

        expect(result, contains('luthor: # Configured via catalog'));
        expect(result, contains('git:'));
      },
    );

    test(
      'When only one dependency is catalog-managed then other dependencies are unchanged',
      () {
        final yaml = '''
dependencies:
  meta: 1.15.0
  freezed: ^3.0.0
''';
        final result = addCatalogCommentsToDependencies(yaml, {'meta'});
        final freezedLine = findLine(result, 'freezed:');

        expect(result, contains('meta: 1.15.0 # Configured via catalog'));
        expect(result, contains('freezed: ^3.0.0'));
        expect(freezedLine, isNot(contains('#')));
      },
    );

    test(
      'When a dependency has an inline comment then the catalog comment replaces it',
      () {
        final yaml = '''
dependencies:
  meta: 1.15.0 # old comment
''';
        final result = addCatalogCommentsToDependencies(yaml, {'meta'});

        expect(result, contains('meta: 1.15.0 # Configured via catalog'));
        expect(result, isNot(contains('old comment')));
      },
    );

    test(
      'When a dev dependency is catalog-managed then an inline comment is added',
      () {
        final yaml = '''
dev_dependencies:
  build_runner: 2.4.15
''';
        final result = addCatalogCommentsToDependencies(yaml, {'build_runner'});

        expect(
          result,
          contains('build_runner: 2.4.15 # Configured via catalog'),
        );
      },
    );

    test(
      'When a quoted value contains hash text then it is preserved before the comment',
      () {
        final yaml = '''
dependencies:
  test_pkg: "1.0.0 # not a comment"
''';
        final result = addCatalogCommentsToDependencies(yaml, {'test_pkg'});

        expect(
          result,
          contains(
            'test_pkg: "1.0.0 # not a comment" # Configured via catalog',
          ),
        );
      },
    );

    test(
      'When an sdk dependency is catalog-managed then the key line is commented',
      () {
        final yaml = '''
dependencies:
  flutter:
    sdk: flutter
''';
        final result = addCatalogCommentsToDependencies(yaml, {'flutter'});

        expect(result, contains('flutter: # Configured via catalog'));
        expect(result, contains('sdk: flutter'));
      },
    );

    test(
      'When a path dependency is catalog-managed then the key line is commented',
      () {
        final yaml = '''
dependencies:
  local_pkg:
    path: ../local_pkg
''';
        final result = addCatalogCommentsToDependencies(yaml, {'local_pkg'});

        expect(result, contains('local_pkg: # Configured via catalog'));
        expect(result, contains('path: ../local_pkg'));
      },
    );

    test('When the catalog is empty then yaml is unchanged', () {
      final yaml = '''
dependencies:
  meta: 1.15.0
''';
      final result = addCatalogCommentsToDependencies(yaml, {});

      expect(result, equals(yaml));
    });

    test(
      'When yaml has non-dependency sections then only dependencies are commented',
      () {
        final yaml = '''
name: test_package
version: 1.0.0

dependencies:
  meta: 1.15.0

environment:
  sdk: ^3.0.0
''';
        final result = addCatalogCommentsToDependencies(yaml, {'meta'});

        expect(result, contains('name: test_package'));
        expect(result, contains('version: 1.0.0'));
        expect(result, contains('sdk: ^3.0.0'));
        expect(result, contains('meta: 1.15.0 # Configured via catalog'));
      },
    );

    test(
      'When multiple dependencies are catalog-managed then each receives a comment',
      () {
        final yaml = '''
dependencies:
  meta: 1.15.0
  build_runner: 2.4.15
  freezed: ^3.0.0
''';
        final result = addCatalogCommentsToDependencies(yaml, {
          'meta',
          'build_runner',
        });
        final freezedLine = findLine(result, 'freezed:');

        expect(result, contains('meta: 1.15.0 # Configured via catalog'));
        expect(
          result,
          contains('build_runner: 2.4.15 # Configured via catalog'),
        );
        expect(freezedLine, isNot(contains('#')));
      },
    );

    test(
      'When catalog dependencies span dependency sections then both sections are commented',
      () {
        final yaml = '''
dependencies:
  meta: 1.15.0

dev_dependencies:
  build_runner: 2.4.15
''';
        final result = addCatalogCommentsToDependencies(yaml, {
          'meta',
          'build_runner',
        });

        expect(result, contains('meta: 1.15.0 # Configured via catalog'));
        expect(
          result,
          contains('build_runner: 2.4.15 # Configured via catalog'),
        );
      },
    );

    test(
      'When dependency_overrides repeats a catalog dependency then override is not commented',
      () {
        final yaml = '''
dependencies:
  meta: 1.15.0

dependency_overrides:
  meta: 1.14.0
''';
        final result = addCatalogCommentsToDependencies(yaml, {'meta'});
        final lines = result.split('\n');
        final overrideIndex = lines.indexWhere(
          (line) => line.contains('dependency_overrides:'),
        );
        final overrideMetaLine = lines
            .skip(overrideIndex + 1)
            .firstWhere((line) => line.contains('meta:'));

        expect(result, contains('meta: 1.15.0 # Configured via catalog'));
        expect(overrideMetaLine, isNot(contains('Configured via catalog')));
      },
    );

    test(
      'When a dependency line has trailing whitespace then comment spacing is normalized',
      () {
        final yaml = '''
dependencies:
  meta: 1.15.0
''';
        final result = addCatalogCommentsToDependencies(yaml, {'meta'});

        expect(result, contains('meta: 1.15.0 # Configured via catalog'));
        expect(result, isNot(contains('1.15.0   #')));
      },
    );

    test('When yaml has empty lines then structure is preserved', () {
      final yaml = '''
dependencies:
  meta: 1.15.0

  build_runner: 2.4.15
''';
      final result = addCatalogCommentsToDependencies(yaml, {
        'meta',
        'build_runner',
      });

      expect(result, contains('meta: 1.15.0 # Configured via catalog'));
      expect(result, contains('build_runner: 2.4.15 # Configured via catalog'));
      expect(result.split('\n').where((line) => line.isEmpty).length, 2);
    });

    test(
      'When a complex git dependency is catalog-managed then all fields are preserved',
      () {
        final yaml = '''
dependencies:
  luthor:
    git:
      url: https://github.com/exaby73/luthor.git
      path: packages/luthor
      ref: main
''';
        final result = addCatalogCommentsToDependencies(yaml, {'luthor'});

        expect(result, contains('luthor: # Configured via catalog'));
        expect(result, contains('git:'));
        expect(result, contains('url: https://github.com/exaby73/luthor.git'));
        expect(result, contains('path: packages/luthor'));
        expect(result, contains('ref: main'));
      },
    );

    test(
      'When package names contain hyphens and underscores then comments are added',
      () {
        final yaml = '''
dependencies:
  my_package: 1.0.0
  my-other-package: 2.0.0
''';
        final result = addCatalogCommentsToDependencies(yaml, {
          'my_package',
          'my-other-package',
        });

        expect(result, contains('my_package: 1.0.0 # Configured via catalog'));
        expect(
          result,
          contains('my-other-package: 2.0.0 # Configured via catalog'),
        );
      },
    );

    test(
      'When version constraints contain special characters then comments are added',
      () {
        final yaml = '''
dependencies:
  meta: ">=1.15.0 <2.0.0"
  build_runner: ^2.4.15
  freezed: "2.0.0"
''';
        final result = addCatalogCommentsToDependencies(yaml, {
          'meta',
          'build_runner',
          'freezed',
        });

        expect(
          result,
          contains('meta: ">=1.15.0 <2.0.0" # Configured via catalog'),
        );
        expect(
          result,
          contains('build_runner: ^2.4.15 # Configured via catalog'),
        );
        expect(result, contains('freezed: "2.0.0" # Configured via catalog'));
      },
    );
  });
}

String findLine(String text, String pattern) {
  return text.split('\n').firstWhere((line) => line.contains(pattern));
}
