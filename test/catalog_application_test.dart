import 'package:dpk/catalog/catalog_application.dart';
import 'package:dpk/config/dpk_config.dart';
import 'package:test/test.dart';

void main() {
  const values = TemplateValues(
    packagePath: 'packages/core',
    packageName: 'core',
    packageVersion: '1.2.3',
  );

  group('Given a Flutter package pubspec', () {
    const pubspec = '''
name: core
environment:
  sdk: ^3.6.0
  flutter: ">=3.22.0"
dependencies:
  http: ^0.13.0 # old
  private:
    hosted: https://pub.example.com
    version: ^1.0.0
  untouched: ^2.0.0
dev_dependencies:
  test: ^1.0.0
''';

    group('When applying a catalog to it as a workspace package', () {
      late String result;

      setUp(() {
        result = applyCatalog(
          pubspec,
          catalog: const Catalog(
            environment: {'sdk': '^3.11.0'},
            version: '1.2.3',
            repository: r'https://github.com/o/r/tree/main/${DPK_PACKAGE_PATH}',
            homepage: 'https://DPK_PACKAGE_NAME.example.com',
            documentation:
                r'https://pub.dev/documentation/$DPK_PACKAGE_NAME/DPK_PACKAGE_VERSION/',
            topics: ['dart'],
            dependencies: {
              'http': '^1.2.0',
              'private': '^1.5.0',
              'test': '^1.25.0',
              'missing': '^9.0.0',
            },
          ),
          role: PubspecRole.package,
          values: values,
        );
      });

      test('Then catalog environment keys are merged, keeping flutter', () {
        expect(result, contains('sdk: ^3.11.0'));
        expect(result, contains('flutter: ">=3.22.0"'));
      });

      test('Then template variables are expanded in every form', () {
        expect(
          result,
          contains(
            'repository: https://github.com/o/r/tree/main/packages/core',
          ),
        );
        expect(result, contains('homepage: https://core.example.com'));
        expect(
          result,
          contains('documentation: https://pub.dev/documentation/core/1.2.3/'),
        );
      });

      test('Then catalog dependencies are updated and marked', () {
        expect(result, contains('http: ^1.2.0 $catalogMarker'));
        expect(result, contains('test: ^1.25.0 $catalogMarker'));
      });

      test('Then a private hosted dependency keeps its host', () {
        expect(result, contains('hosted: https://pub.example.com'));
        expect(result, contains('version: ^1.5.0'));
      });

      test('Then dependencies the package lacks are not added', () {
        expect(result, isNot(contains('missing')));
      });

      test('Then other dependencies are left alone', () {
        expect(result, contains('untouched: ^2.0.0\n'));
      });

      test('Then applying it again changes nothing', () {
        expect(
          applyCatalog(
            result,
            catalog: const Catalog(
              environment: {'sdk': '^3.11.0'},
              dependencies: {
                'http': '^1.2.0',
                'private': '^1.5.0',
                'test': '^1.25.0',
              },
            ),
            role: PubspecRole.package,
            values: values,
          ),
          equals(result),
        );
      });
    });
  });

  group('Given catalog dependencies with non-version sources', () {
    const pubspec = '''
name: core
dependencies:
  luthor: any
  flutter:
    sdk: flutter
''';

    test('When applying the catalog then each value is written as given', () {
      final result = applyCatalog(
        pubspec,
        catalog: const Catalog(
          dependencies: {
            'luthor': {
              'git': {
                'url': 'git@github.com:o/r.git',
                'path': 'packages/luthor',
              },
              'version': '^1.0.0',
            },
            'flutter': {'sdk': 'flutter'},
          },
        ),
        role: PubspecRole.package,
        values: values,
      );

      expect(result, contains('url: git@github.com:o/r.git'));
      expect(result, contains('version: ^1.0.0'));
      expect(result, isNot(contains('version: any')));
      expect(result, contains('flutter: $catalogMarker\n    sdk: flutter'));
    });
  });

  group('Given a pubspec with a stale catalog marker', () {
    const pubspec =
        '''
name: core
dependencies:
  dropped: ^1.0.0 $catalogMarker
  kept: ^1.0.0 # my note
''';

    test('When the dependency left the catalog then its marker is removed', () {
      final result = markCatalogDependencies(pubspec, {'kept'});

      expect(result, contains('dropped: ^1.0.0\n'));
      expect(result, contains('kept: ^1.0.0 $catalogMarker'));
    });
  });

  group('Given a dependency value that contains # inside quotes', () {
    const pubspec = 'name: core\ndependencies:\n  odd: "x#y" # old\n';

    test('When marking it then the quoted value stays intact', () {
      expect(
        markCatalogDependencies(pubspec, {'odd'}),
        contains('odd: "x#y" $catalogMarker'),
      );
    });
  });

  group('Given a pubspec with CRLF line endings', () {
    const pubspec = 'name: core\r\ndependencies:\r\n  http: ^0.13.0\r\n';

    test('When applying the catalog then CRLF is kept', () {
      final result = applyCatalog(
        pubspec,
        catalog: const Catalog(dependencies: {'http': '^1.2.0'}),
        role: PubspecRole.package,
        values: values,
      );

      expect(
        result,
        equals(
          'name: core\r\ndependencies:\r\n  http: ^1.2.0 $catalogMarker\r\n',
        ),
      );
    });
  });

  group('Given catalog package metadata', () {
    const pubspec = 'name: _\ndependencies:\n  http: ^1.0.0\n';
    const catalog = Catalog(version: '2.0.0');

    test('When applying to the root then metadata does not apply', () {
      final result = applyCatalog(
        pubspec,
        catalog: catalog,
        role: PubspecRole.root,
        values: values,
      );

      expect(result, isNot(contains('version: 2.0.0')));
    });

    test('When applying to a workspace package then metadata applies', () {
      final result = applyCatalog(
        pubspec,
        catalog: catalog,
        role: PubspecRole.package,
        values: values,
      );

      expect(result, contains('version: 2.0.0'));
    });
  });
}
