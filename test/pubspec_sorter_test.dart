import 'package:dpk/utils/pubspec_sorter.dart';
import 'package:test/test.dart';

void main() {
  group('Given the pubspec sorter', () {
    test('When content is empty then it is returned unchanged', () {
      expect(sortPubspec(''), equals(''));
      expect(sortPubspec('   '), equals('   '));
    });

    test(
      'When top-level keys are unordered then they are sorted in pubspec order',
      () {
        const input = '''
dependencies:
  foo: ^1.0.0
name: my_app
environment:
  sdk: ^3.0.0
version: 1.0.0
''';

        final result = sortPubspec(input);

        // Verify order: name, version, environment, dependencies
        final lines = result.split('\n');
        final nameIndex = lines.indexWhere((l) => l.startsWith('name:'));
        final versionIndex = lines.indexWhere((l) => l.startsWith('version:'));
        final envIndex = lines.indexWhere((l) => l.startsWith('environment:'));
        final depsIndex = lines.indexWhere(
          (l) => l.startsWith('dependencies:'),
        );

        expect(nameIndex, lessThan(versionIndex));
        expect(versionIndex, lessThan(envIndex));
        expect(envIndex, lessThan(depsIndex));
      },
    );

    test(
      'When sections are adjacent then blank lines are added between groups',
      () {
        const input = '''
name: my_app
environment:
  sdk: ^3.0.0
dependencies:
  foo: ^1.0.0
''';

        final result = sortPubspec(input);

        // There should be blank lines between groups
        expect(result, contains('\n\nenvironment:'));
        expect(result, contains('\n\ndependencies:'));
      },
    );

    test(
      'When dependencies are unordered then packages are sorted alphabetically',
      () {
        const input = '''
name: my_app
dependencies:
  zebra: ^1.0.0
  alpha: ^2.0.0
  beta: ^3.0.0
''';

        final result = sortPubspec(input);
        final lines = result.split('\n');

        final alphaIndex = lines.indexWhere((l) => l.contains('alpha:'));
        final betaIndex = lines.indexWhere((l) => l.contains('beta:'));
        final zebraIndex = lines.indexWhere((l) => l.contains('zebra:'));

        expect(alphaIndex, lessThan(betaIndex));
        expect(betaIndex, lessThan(zebraIndex));
      },
    );

    test(
      'When dev dependencies are unordered then packages are sorted alphabetically',
      () {
        const input = '''
name: my_app
dev_dependencies:
  test: ^1.0.0
  lints: ^2.0.0
  build_runner: ^3.0.0
''';

        final result = sortPubspec(input);
        final lines = result.split('\n');

        final buildRunnerIndex = lines.indexWhere(
          (l) => l.contains('build_runner:'),
        );
        final lintsIndex = lines.indexWhere((l) => l.contains('lints:'));
        final testIndex = lines.indexWhere((l) => l.contains('test:'));

        expect(buildRunnerIndex, lessThan(lintsIndex));
        expect(lintsIndex, lessThan(testIndex));
      },
    );

    test(
      'When top-level fields have inline comments then comments are preserved',
      () {
        const input = '''
name: my_app # This is my app
version: 1.0.0 # Initial version
''';

        final result = sortPubspec(input);

        expect(result, contains('# This is my app'));
        expect(result, contains('# Initial version'));
      },
    );

    test('When fields have leading comments then comments are preserved', () {
      const input = '''
# This is the app name
name: my_app
# This is the version
version: 1.0.0
''';

      final result = sortPubspec(input);

      expect(result, contains('# This is the app name'));
      expect(result, contains('name: my_app'));
      expect(result, contains('# This is the version'));
      expect(result, contains('version: 1.0.0'));
    });

    test(
      'When unknown keys are present then they stay after their predecessor',
      () {
        const input = '''
name: my_app
custom_field: some_value
version: 1.0.0
''';

        final result = sortPubspec(input);
        final lines = result.split('\n');

        // custom_field should stay after name (its predecessor in original)
        final nameIndex = lines.indexWhere((l) => l.startsWith('name:'));
        final customIndex = lines.indexWhere(
          (l) => l.startsWith('custom_field:'),
        );
        final versionIndex = lines.indexWhere((l) => l.startsWith('version:'));

        expect(nameIndex, lessThan(customIndex));
        expect(customIndex, lessThan(versionIndex));
      },
    );

    test(
      'When non-dependency nested keys are present then nested content is preserved',
      () {
        const input = '''
name: my_app
flutter:
  uses-material-design: true
  assets:
    - images/
''';

        final result = sortPubspec(input);

        // flutter content should be preserved as-is
        expect(result, contains('flutter:'));
        expect(result, contains('uses-material-design: true'));
      },
    );

    test(
      'When quoted strings contain hash characters then they are preserved as values',
      () {
        const input = '''
name: "my # app"
description: 'test # value'
version: 1.0.0
''';

        final result = sortPubspec(input);

        // The # inside quotes should not be treated as comments
        // Note: yaml_edit may normalize quotes, so check for the content
        expect(result, contains('my # app'));
        expect(result, contains('test # value'));
      },
    );

    test(
      'When dependencies have complex values then values are preserved while keys sort',
      () {
        const input = '''
name: my_app
dependencies:
  foo:
    git:
      url: https://github.com/example/foo.git
      ref: main
  bar: ^1.0.0
''';

        final result = sortPubspec(input);

        // bar should come before foo (alphabetical)
        final lines = result.split('\n');
        final barIndex = lines.indexWhere((l) => l.contains('bar:'));
        final fooIndex = lines.indexWhere((l) => l.contains('foo:'));

        expect(barIndex, lessThan(fooIndex));

        // Git dependency should be preserved
        expect(result, contains('git:'));
        expect(result, contains('url: https://github.com/example/foo.git'));
      },
    );

    test(
      'When dependency overrides are unordered then override packages are sorted',
      () {
        const input = '''
name: my_app
dependency_overrides:
  zebra:
    path: ../zebra
  alpha: ^1.0.0
''';

        final result = sortPubspec(input);
        final lines = result.split('\n');

        // alpha should come before zebra
        final alphaIndex = lines.indexWhere((l) => l.contains('alpha:'));
        final zebraIndex = lines.indexWhere((l) => l.contains('zebra:'));

        expect(alphaIndex, lessThan(zebraIndex));
      },
    );

    test('When environment has nested content then it is preserved', () {
      const input = '''
name: my_app
environment:
  sdk: ^3.0.0
  flutter: ^3.0.0
''';

      final result = sortPubspec(input);

      // environment content should be preserved as-is (not sorted)
      expect(result, contains('environment:'));
      expect(result, contains('sdk: ^3.0.0'));
      expect(result, contains('flutter: ^3.0.0'));
    });

    test('When dependencies section is empty then it is preserved', () {
      const input = '''
name: my_app
dependencies:
version: 1.0.0
''';

      final result = sortPubspec(input);

      expect(result, contains('name: my_app'));
      expect(result, contains('version: 1.0.0'));
      expect(result, contains('dependencies:'));
    });

    test(
      'When a full pubspec is unordered then sections and dependency keys are sorted',
      () {
        const input = '''
flutter:
  uses-material-design: true
dev_dependencies:
  test: ^1.0.0
  lints: ^2.0.0
dependencies:
  foo: ^1.0.0
  bar: ^2.0.0
environment:
  sdk: ^3.0.0
version: 1.0.0
description: A sample app
name: my_app
''';

        final result = sortPubspec(input);
        final lines = result.split('\n');

        // Check overall order
        final nameIndex = lines.indexWhere((l) => l.startsWith('name:'));
        final descIndex = lines.indexWhere((l) => l.startsWith('description:'));
        final versionIndex = lines.indexWhere((l) => l.startsWith('version:'));
        final envIndex = lines.indexWhere((l) => l.startsWith('environment:'));
        final depsIndex = lines.indexWhere(
          (l) => l.startsWith('dependencies:'),
        );
        final devDepsIndex = lines.indexWhere(
          (l) => l.startsWith('dev_dependencies:'),
        );
        final flutterIndex = lines.indexWhere((l) => l.startsWith('flutter:'));

        expect(nameIndex, lessThan(descIndex));
        expect(descIndex, lessThan(versionIndex));
        expect(versionIndex, lessThan(envIndex));
        expect(envIndex, lessThan(depsIndex));
        expect(depsIndex, lessThan(devDepsIndex));
        expect(devDepsIndex, lessThan(flutterIndex));

        // Check dependency sorting
        final barIndex = lines.indexWhere((l) => l.contains('  bar:'));
        final fooIndex = lines.indexWhere((l) => l.contains('  foo:'));
        expect(barIndex, lessThan(fooIndex));

        final lintsIndex = lines.indexWhere((l) => l.contains('  lints:'));
        final testIndex = lines.indexWhere((l) => l.contains('  test:'));
        expect(lintsIndex, lessThan(testIndex));
      },
    );

    test(
      'When dependencies have leading comments then comments are preserved',
      () {
        const input = '''
name: my_app
dependencies:
  # This is zebra
  zebra: ^1.0.0
  # This is alpha
  alpha: ^2.0.0
''';

        final result = sortPubspec(input);

        // Comments should be preserved
        expect(result, contains('# This is zebra'));
        expect(result, contains('# This is alpha'));
      },
    );

    test(
      'When dependency values have nested comments then comments are preserved',
      () {
        const input = '''
name: my_app
dependencies:
  luthor:
    # A nested comment
    path: ../luthor
  alpha: ^1.0.0
''';

        final result = sortPubspec(input);

        // The nested comment inside luthor's value should be preserved
        expect(result, contains('# A nested comment'));
        // alpha should come before luthor (alphabetical)
        final lines = result.split('\n');
        final alphaIndex = lines.indexWhere((l) => l.contains('alpha:'));
        final luthorIndex = lines.indexWhere((l) => l.contains('luthor:'));
        expect(alphaIndex, lessThan(luthorIndex));
      },
    );

    test(
      'When git dependency values have nested comments then comments are preserved',
      () {
        const input = '''
name: my_app
dependencies:
  luthor:
    # A nested comment
    git:
      url: https://github.com/exaby73/luthor.git
      path: packages/luthor
  alpha: ^1.0.0
''';

        final result = sortPubspec(input);

        // The nested comment inside luthor's value should be preserved
        expect(result, contains('# A nested comment'));
        expect(result, contains('url: https://github.com/exaby73/luthor.git'));
        expect(result, contains('path: packages/luthor'));
        // alpha should come before luthor (alphabetical)
        final lines = result.split('\n');
        final alphaIndex = lines.indexWhere((l) => l.contains('alpha:'));
        final luthorIndex = lines.indexWhere((l) => l.contains('luthor:'));
        expect(alphaIndex, lessThan(luthorIndex));
      },
    );

    test(
      'When complex dependency keys have inline comments then comments stay on key lines',
      () {
        const input = '''
name: my_app
dependencies:
  simple_dep: ^1.0.0 # Simple comment
  complex_dep: # Complex comment
    git:
      url: https://github.com/example/repo.git
      path: packages/pkg
''';

        final result = sortPubspec(input);

        // Both comments should be preserved
        expect(result, contains('simple_dep: ^1.0.0 # Simple comment'));
        expect(result, contains('complex_dep: # Complex comment'));

        // Complex comment should be on the key line, not nested lines
        final lines = result.split('\n');
        final complexDepLine = lines.firstWhere(
          (l) => l.trim().startsWith('complex_dep:'),
        );
        expect(complexDepLine, contains('# Complex comment'));
      },
    );
  });
}
