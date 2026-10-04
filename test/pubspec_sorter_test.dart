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

        final lines = result.split('\n');
        final barIndex = lines.indexWhere((l) => l.contains('bar:'));
        final fooIndex = lines.indexWhere((l) => l.contains('foo:'));

        expect(barIndex, lessThan(fooIndex));

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

        expect(result, contains('# A nested comment'));
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

        expect(result, contains('# A nested comment'));
        expect(result, contains('url: https://github.com/exaby73/luthor.git'));
        expect(result, contains('path: packages/luthor'));
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

        expect(result, contains('simple_dep: ^1.0.0 # Simple comment'));
        expect(result, contains('complex_dep: # Complex comment'));

        final lines = result.split('\n');
        final complexDepLine = lines.firstWhere(
          (l) => l.trim().startsWith('complex_dep:'),
        );
        expect(complexDepLine, contains('# Complex comment'));
      },
    );

    test(
      'When a section ends with a nested dependency then sorting twice is stable',
      () {
        const input = '''
name: app

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
''';

        final firstPass = sortPubspec(input);
        final secondPass = sortPubspec(firstPass);

        expect(secondPass, equals(firstPass));
        expect(firstPass, isNot(contains('\n\n\n')));
      },
    );

    test(
      'When a nested dependency ends the file then sorting twice is stable',
      () {
        const input = '''
name: app

dev_dependencies:
  flutter_test:
    sdk: flutter
''';

        final firstPass = sortPubspec(input);
        final secondPass = sortPubspec(firstPass);

        expect(secondPass, equals(firstPass));
        expect(firstPass, endsWith('sdk: flutter\n'));
      },
    );

    test(
      'When a blank line follows a nested dependency then sorting twice is stable',
      () {
        const input = '''
name: app

dependencies:
  flutter:
    sdk: flutter

  dio: ^5.0.0
''';

        final firstPass = sortPubspec(input);
        final secondPass = sortPubspec(firstPass);

        expect(secondPass, equals(firstPass));
        expect(firstPass, isNot(contains('\n\n\n')));
        expect(firstPass, endsWith('sdk: flutter\n'));
      },
    );

    test(
      'When a nested dependency has inner blank lines then they are preserved',
      () {
        const input = '''
name: app

dependencies:
  my_pkg:
    git:
      url: https://github.com/example/repo.git

      path: packages/pkg
''';

        final result = sortPubspec(input);

        expect(
          result,
          contains(
            '      url: https://github.com/example/repo.git\n'
            '\n'
            '      path: packages/pkg\n',
          ),
        );
      },
    );
  });

  group('Given the stock Flutter app template pubspec', () {
    group('When sorted', () {
      late String result;

      setUp(() {
        result = sortPubspec(_flutterTemplate);
      });

      test(
        'Then only key order, dependency order, and blank lines between keys change',
        () {
          expect(result, equals(_sortedFlutterTemplate));
        },
      );

      test('Then sorting again changes nothing', () {
        expect(sortPubspec(result), equals(result));
      });
    });
  });

  group('Given top-level keys in every group', () {
    test('When sorted then groups are separated by exactly one blank line', () {
      const input = '''
flutter:
  uses-material-design: true
executables:
  dpk: main
dependency_overrides:
  zed: ^1.0.0
dev_dependencies:
  test: ^1.0.0
dependencies:
  yaml: ^3.0.0
  args: ^2.0.0
environment:
  sdk: ^3.0.0
ignored_advisories:
  - GHSA-xxxx-xxxx-xxxx
platforms:
  linux:
funding:
  - https://example.com/sponsor
topics:
  - cli
repository: https://github.com/example/app
version: 1.0.0
description: An app.
name: app
''';

      expect(
        sortPubspec(input),
        equals('''
name: app
description: An app.
version: 1.0.0
repository: https://github.com/example/app
topics:
  - cli
funding:
  - https://example.com/sponsor

platforms:
  linux:
ignored_advisories:
  - GHSA-xxxx-xxxx-xxxx

environment:
  sdk: ^3.0.0

dependencies:
  args: ^2.0.0
  yaml: ^3.0.0

dev_dependencies:
  test: ^1.0.0

dependency_overrides:
  zed: ^1.0.0

executables:
  dpk: main

flutter:
  uses-material-design: true
'''),
      );
    });

    test(
      'When keys in the first group are set apart without comments then the blank line is removed',
      () {
        expect(
          sortPubspec('name: app\n\nversion: 1.0.0\n'),
          equals('name: app\nversion: 1.0.0\n'),
        );
      },
    );

    test(
      'When a commented key in the first group moves then its comment moves with it without the blank line',
      () {
        const input = '''
name: app
publish_to: none

# The version comment
version: 1.0.0
''';

        expect(
          sortPubspec(input),
          equals('''
name: app
# The version comment
version: 1.0.0
publish_to: none
'''),
        );
      },
    );
  });

  group('Given unknown top-level keys', () {
    test('When an unknown key comes first then it stays at the start', () {
      const input = '''
custom_first: 1
version: 1.0.0
custom_a: a
custom_b: b
name: app
''';

      expect(
        sortPubspec(input),
        equals('''
custom_first: 1

name: app
version: 1.0.0
custom_a: a
custom_b: b
'''),
      );
    });

    test(
      'When an unknown key follows a section then it keeps its place and spacing',
      () {
        const input = '''
dependencies:
  a_pkg: ^1.0.0
environment:
  sdk: ^3.0.0

my_tool:
  option: true
name: app
''';

        expect(
          sortPubspec(input),
          equals('''
name: app

environment:
  sdk: ^3.0.0

my_tool:
  option: true

dependencies:
  a_pkg: ^1.0.0
'''),
        );
      },
    );

    test('When keys contain dashes or quotes then sorting twice is stable', () {
      const input = '''
"quoted key": 1
dash-key:
  nested-key: true
name: app
'version': 1.0.0
''';
      const expected = '''
"quoted key": 1
dash-key:
  nested-key: true

name: app
'version': 1.0.0
''';

      final firstPass = sortPubspec(input);

      expect(firstPass, equals(expected));
      expect(sortPubspec(firstPass), equals(expected));
    });
  });

  group('Given dependency sections', () {
    test('When entries use 4-space indentation then they are sorted', () {
      const input = '''
name: app

dependencies:
    zeta: ^1.0.0
    alpha:
        path: ../alpha
''';

      expect(
        sortPubspec(input),
        equals('''
name: app

dependencies:
    alpha:
        path: ../alpha
    zeta: ^1.0.0
'''),
      );
    });

    test(
      'When entries have comments, blank lines, and nested values then each entry moves as a whole',
      () {
        const input = '''
name: app

dependencies: # runtime deps
  # zeta comment
  zeta: ^1.0.0

  beta:
    git:
      url: https://example.com/beta.git

      ref: main
  alpha: ^1.0.0 # inline
  # trailing note
''';

        expect(
          sortPubspec(input),
          equals('''
name: app

dependencies: # runtime deps
  alpha: ^1.0.0 # inline
  beta:
    git:
      url: https://example.com/beta.git

      ref: main
  # zeta comment
  zeta: ^1.0.0
  # trailing note
'''),
        );
      },
    );

    test('When a section uses flow style then it is unchanged', () {
      const input = '''
name: app

dependencies: {zeta: ^1.0.0, alpha: ^1.0.0}
''';

      expect(sortPubspec(input), equals(input));
    });

    test('When a section is empty then it is unchanged', () {
      const input = '''
name: app

dev_dependencies:
''';

      expect(sortPubspec(input), equals(input));
    });

    test(
      'When the section ends with an indented comment then it stays in the section',
      () {
        const input = '''
dev_dependencies:
  test: ^1.0.0
  # lints: ^2.0.0
name: app
''';

        expect(
          sortPubspec(input),
          equals('''
name: app

dev_dependencies:
  test: ^1.0.0
  # lints: ^2.0.0
'''),
        );
      },
    );

    test(
      'When a commented-out dependency is the last line of the file then it is kept',
      () {
        const input = '''
name: app

dependencies:
  zeta: ^1.0.0
  alpha: ^1.0.0
  # beta: ^1.0.0''';

        expect(
          sortPubspec(input),
          equals('''
name: app

dependencies:
  alpha: ^1.0.0
  zeta: ^1.0.0
  # beta: ^1.0.0'''),
        );
      },
    );

    test(
      'When an unindented commented-out dependency ends the file then it stays at the end of the file',
      () {
        const input = '''
flutter:
  uses-material-design: true
dependencies:
  zeta: ^1.0.0
  alpha: ^1.0.0
#  beta: ^1.0.0''';

        expect(
          sortPubspec(input),
          equals('''
dependencies:
  alpha: ^1.0.0
  zeta: ^1.0.0

flutter:
  uses-material-design: true
#  beta: ^1.0.0'''),
        );
      },
    );

    test(
      'When anchors are defined before their aliases then they are preserved',
      () {
        const input = '''
name: app

dependencies:
  shared: &shared
    git:
      url: https://example.com/repo.git
      ref: main
  a_pkg: ^1.0.0

dependency_overrides:
  shared: *shared
''';

        expect(
          sortPubspec(input),
          equals('''
name: app

dependencies:
  a_pkg: ^1.0.0
  shared: &shared
    git:
      url: https://example.com/repo.git
      ref: main

dependency_overrides:
  shared: *shared
'''),
        );
      },
    );

    test(
      'When sorting entries would move an alias above its anchor then entries keep their order',
      () {
        const input = '''
name: app

dependencies:
  zeta: &v ^1.0.0
  alpha: *v
''';

        expect(sortPubspec(input), equals(input));
      },
    );
  });

  group('Given sections that are not dependency sections', () {
    test(
      'When the description is a block scalar then it is copied verbatim',
      () {
        const input = '''
description: >-
  A long description
  # not a comment

  second paragraph.
name: app
''';

        expect(
          sortPubspec(input),
          equals('''
name: app
description: >-
  A long description
  # not a comment

  second paragraph.
'''),
        );
      },
    );

    test(
      'When platforms have null children then they stay null without a value',
      () {
        const input = '''
platforms:
  linux:
  macos:
name: app
''';

        expect(
          sortPubspec(input),
          equals('''
name: app

platforms:
  linux:
  macos:
'''),
        );
      },
    );
  });

  group('Given comments outside sections', () {
    test(
      'When a header and a document marker precede the first key then they stay at the top',
      () {
        const input = '''
# Header comment

---
version: 1.0.0
name: app
''';

        expect(
          sortPubspec(input),
          equals('''
# Header comment

---
name: app
version: 1.0.0
'''),
        );
      },
    );

    test(
      'When a header is set apart from a commented first key then the header stays and the comment moves',
      () {
        const input = '''
# Header comment

# The version comment
version: 1.0.0
name: app
''';

        expect(
          sortPubspec(input),
          equals('''
# Header comment

name: app
# The version comment
version: 1.0.0
'''),
        );
      },
    );

    test('When a comment ends the file then it stays at the end', () {
      const input = '''
version: 1.0.0
name: app
# end of file
''';

      expect(
        sortPubspec(input),
        equals('''
name: app
version: 1.0.0
# end of file
'''),
      );
    });

    test(
      'When an unindented comment is set apart from the next key then it stays with the previous section',
      () {
        const input = '''
dependencies:
  a_pkg: ^1.0.0
# note about dependencies

name: app
''';

        expect(
          sortPubspec(input),
          equals('''
name: app

dependencies:
  a_pkg: ^1.0.0
# note about dependencies
'''),
        );
      },
    );
  });

  group('Given line endings', () {
    test('When the input uses CRLF then the output uses CRLF', () {
      const input =
          'dependencies:\r\n  b_pkg: ^1.0.0\r\n  a_pkg: ^1.0.0\r\nname: app\r\n';

      expect(
        sortPubspec(input),
        equals(
          'name: app\r\n\r\ndependencies:\r\n  a_pkg: ^1.0.0\r\n  b_pkg: ^1.0.0\r\n',
        ),
      );
    });

    test(
      'When the input ends with several newlines then the output ends with one',
      () {
        expect(
          sortPubspec('version: 1.0.0\nname: app\n\n\n'),
          equals('name: app\nversion: 1.0.0\n'),
        );
      },
    );

    test('When the input has no trailing newline then none is added', () {
      expect(
        sortPubspec('version: 1.0.0\nname: app'),
        equals('name: app\nversion: 1.0.0'),
      );
    });
  });

  group('Given content that is not a block mapping', () {
    test('When sorted then it is returned unchanged', () {
      for (final input in [
        'name: [unclosed\nversion: 1.0.0\n',
        'just a string\n',
        '{version: 1.0.0, name: app}\n',
        '- version\n- name\n',
        '# only a comment\n',
      ]) {
        expect(sortPubspec(input), equals(input), reason: input);
      }
    });
  });

  group('Given varied pubspec fixtures', () {
    test('When each is sorted twice then the second sort changes nothing', () {
      for (final fixture in _idempotenceFixtures) {
        final firstPass = sortPubspec(fixture);

        expect(sortPubspec(firstPass), equals(firstPass), reason: fixture);
      }
    });
  });
}

/// The pubspec that `flutter create` writes for a new app.
const _flutterTemplate = '''
name: my_app
description: "A new Flutter project."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: ^3.8.0

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^5.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package
''';

/// [_flutterTemplate] after sorting. `version` moves above `publish_to`,
/// each dependency entry moves with the comments above it, and the blank
/// lines between top-level keys of one group and between dependency entries
/// are gone. Every other line is unchanged.
const _sortedFlutterTemplate = '''
name: my_app
description: "A new Flutter project."
# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

environment:
  sdk: ^3.8.0

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8
  flutter:
    sdk: flutter

dev_dependencies:
  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^5.0.0
  flutter_test:
    sdk: flutter

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package
''';

/// Inputs of many shapes for the idempotence test.
const _idempotenceFixtures = [
  _flutterTemplate,
  '''
dependencies:
  zeta: ^1.0.0
  alpha: ^1.0.0
name: app
''',
  '''
name: app

dependencies:
    zeta: ^1.0.0
    alpha:
        path: ../alpha
''',
  '''
name: app
dependencies: {zeta: ^1.0.0, alpha: ^1.0.0}
dev_dependencies:
''',
  '''
description: >-
  A long description

  second paragraph.
name: app
''',
  '''
name: app
dependencies:
  shared: &shared
    path: ../shared
  a_pkg: ^1.0.0
dependency_overrides:
  shared: *shared
''',
  '''
platforms:
  linux:
  macos:
name: app
''',
  'dependencies:\r\n  b_pkg: ^1.0.0\r\n  a_pkg: ^1.0.0\r\nname: app\r\n',
  '''
# Header comment

---
# The version comment
version: 1.0.0
name: app
# end of file
''',
  '''
custom_first: 1
"quoted key": 2
dash-key:
  nested-key: true
version: 1.0.0

custom_after_version: 3
name: app
''',
  '''
flutter:
  uses-material-design: true
# note about flutter

dependencies:
  # zeta comment
  zeta: ^1.0.0
  # orphan comment

  beta:
    git:
      url: https://example.com/beta.git

      ref: main

  alpha: ^1.0.0
  # trailing note
#  commented: ^1.0.0
name: app
''',
  '''
name: app

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
''',
  '''
name: app

dependencies:
  flutter:
    sdk: flutter

  dio: ^5.0.0
''',
  '''
version: 1.0.0
# note

name: app
description: d
''',
];
