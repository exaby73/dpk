import 'package:dpk/utils/catalog_comment_utils.dart';
import 'package:test/test.dart';

void main() {
  group('addCatalogCommentsToDependencies', () {
    test('adds comment to simple hosted dependency', () {
      final yaml = '''
dependencies:
  meta: 1.15.0
''';
      final result = addCatalogCommentsToDependencies(yaml, {'meta'});
      expect(result, contains('meta: 1.15.0 # Configured via catalog'));
    });

    test('adds comment to git dependency key line', () {
      final yaml = '''
dependencies:
  luthor:
    git:
      url: https://github.com/exaby73/luthor.git
''';
      final result = addCatalogCommentsToDependencies(yaml, {'luthor'});
      expect(result, contains('luthor: # Configured via catalog'));
      expect(result, contains('git:'));
    });

    test('only adds comments to catalog dependencies', () {
      final yaml = '''
dependencies:
  meta: 1.15.0
  freezed: ^3.0.0
''';
      final result = addCatalogCommentsToDependencies(yaml, {'meta'});
      expect(result, contains('meta: 1.15.0 # Configured via catalog'));
      expect(result, contains('freezed: ^3.0.0'));
      // Ensure freezed doesn't have a comment by checking the exact line
      final lines = result.split('\n');
      final freezedLine = lines.firstWhere((line) => line.contains('freezed:'));
      expect(freezedLine, isNot(contains('#')));
    });

    test('replaces existing inline comment', () {
      final yaml = '''
dependencies:
  meta: 1.15.0 # old comment
''';
      final result = addCatalogCommentsToDependencies(yaml, {'meta'});
      expect(result, contains('meta: 1.15.0 # Configured via catalog'));
      expect(result, isNot(contains('old comment')));
    });

    test('adds comments to dev_dependencies', () {
      final yaml = '''
dev_dependencies:
  build_runner: 2.4.15
''';
      final result = addCatalogCommentsToDependencies(yaml, {'build_runner'});
      expect(result, contains('build_runner: 2.4.15 # Configured via catalog'));
    });

    test('handles quoted strings containing #', () {
      final yaml = '''
dependencies:
  test_pkg: "1.0.0 # not a comment"
''';
      final result = addCatalogCommentsToDependencies(yaml, {'test_pkg'});
      expect(
        result,
        contains('test_pkg: "1.0.0 # not a comment" # Configured via catalog'),
      );
    });

    test('adds comments to sdk dependencies', () {
      final yaml = '''
dependencies:
  flutter:
    sdk: flutter
''';
      final result = addCatalogCommentsToDependencies(yaml, {'flutter'});
      expect(result, contains('flutter: # Configured via catalog'));
      expect(result, contains('sdk: flutter'));
    });

    test('adds comments to path dependencies', () {
      final yaml = '''
dependencies:
  local_pkg:
    path: ../local_pkg
''';
      final result = addCatalogCommentsToDependencies(yaml, {'local_pkg'});
      expect(result, contains('local_pkg: # Configured via catalog'));
      expect(result, contains('path: ../local_pkg'));
    });

    test('returns unchanged yaml when catalog is empty', () {
      final yaml = '''
dependencies:
  meta: 1.15.0
''';
      final result = addCatalogCommentsToDependencies(yaml, {});
      expect(result, equals(yaml));
    });

    test('does not modify non-dependency sections', () {
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
    });

    test('handles multiple catalog dependencies', () {
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
      expect(result, contains('meta: 1.15.0 # Configured via catalog'));
      expect(result, contains('build_runner: 2.4.15 # Configured via catalog'));
      // Freezed should not have a comment
      final lines = result.split('\n');
      final freezedLine = lines.firstWhere((line) => line.contains('freezed:'));
      expect(freezedLine, isNot(contains('#')));
    });

    test('handles both dependencies and dev_dependencies', () {
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
      expect(result, contains('build_runner: 2.4.15 # Configured via catalog'));
    });

    test('does not add comments to dependency_overrides', () {
      final yaml = '''
dependencies:
  meta: 1.15.0

dependency_overrides:
  meta: 1.14.0
''';
      final result = addCatalogCommentsToDependencies(yaml, {'meta'});
      expect(result, contains('meta: 1.15.0 # Configured via catalog'));
      // dependency_overrides should not have the comment
      final lines = result.split('\n');
      final overrideIndex = lines.indexWhere(
        (line) => line.contains('dependency_overrides:'),
      );
      final overrideMetaLine = lines
          .skip(overrideIndex + 1)
          .firstWhere((line) => line.contains('meta:'));
      expect(overrideMetaLine, isNot(contains('Configured via catalog')));
    });

    test('handles trailing whitespace correctly', () {
      final yaml = '''
dependencies:
  meta: 1.15.0
''';
      final result = addCatalogCommentsToDependencies(yaml, {'meta'});
      expect(result, contains('meta: 1.15.0 # Configured via catalog'));
      // Should not have double spaces before comment
      expect(result, isNot(contains('1.15.0   #')));
    });

    test('handles empty lines and preserves structure', () {
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
      // Should preserve empty line
      expect(result.split('\n').where((line) => line.isEmpty).length, 2);
    });

    test('handles complex git dependency with all fields', () {
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
    });

    test('handles package names with hyphens and underscores', () {
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
    });

    test('handles version constraints with special characters', () {
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
    });
  });
}
