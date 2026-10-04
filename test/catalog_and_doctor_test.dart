import 'dart:convert';
import 'dart:io';

import 'package:dpk/config/dpk_config.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'utils/dpk_test_utils.dart';

void main() {
  group('Given a workspace whose catalog lags behind pub', () {
    late RecordingProcessRunner runner;

    setUp(() async {
      runner = RecordingProcessRunner(
        outputs: {
          'pub outdated --json': jsonEncode({
            'packages': [
              _versions(
                'http',
                current: '1.1.0',
                upgradable: '1.2.2',
                resolvable: '2.0.1',
                latest: '2.0.1',
              ),
              _versions(
                'meta',
                current: '1.15.0',
                upgradable: '1.15.0',
                resolvable: '1.19.0',
                latest: '1.19.0',
              ),
            ],
          }),
        },
      );
      await d.dir('repo', [
        d.file(
          'pubspec.yaml',
          pubspec('_', extra: 'workspace:\n  - packages/a\n'),
        ),
        d.file('dpk.yaml', '''
version: $versionConstraint
catalog:
  dependencies:
    http: ^1.1.0 # web
    meta: 1.15.0
    local:
      path: ../local
'''),
        d.dir('packages', [
          d.dir('a', [
            d.file(
              'pubspec.yaml',
              'name: a\nresolution: workspace\ndependencies:\n  http: ^1.1.0\n  meta: 1.15.0\n',
            ),
          ]),
        ]),
      ]).create();
    });

    group('When listing outdated catalog dependencies', () {
      late DpkResult result;

      setUp(() async {
        result = await dpk(
          ['catalog', 'outdated'],
          directory: d.path('repo'),
          processRunner: runner,
        );
      });

      test(
        'Then each version constraint is compared with the latest version',
        () {
          expect(
            result.stdout,
            matches(RegExp(r'http +\^1\.1\.0 +1\.1\.0 +2\.0\.1')),
          );
          expect(
            result.stdout,
            matches(RegExp(r'meta +1\.15\.0 +1\.15\.0 +1\.19\.0')),
          );
        },
      );

      test(
        'Then the summary counts the constraints that exclude the latest',
        () {
          expect(
            result.stdout,
            contains('2 catalog constraints exclude the latest version'),
          );
        },
      );
    });

    group('When upgrading within the current constraints', () {
      setUp(() async {
        await dpk(
          ['catalog', 'upgrade'],
          directory: d.path('repo'),
          processRunner: runner,
        );
      });

      test('Then caret constraints get a raised lower bound', () {
        expect(
          File(d.path('repo/dpk.yaml')).readAsStringSync(),
          contains('http: ^1.2.2 # web'),
        );
      });

      test('Then exact versions stay exact', () {
        expect(
          File(d.path('repo/dpk.yaml')).readAsStringSync(),
          contains('meta: 1.15.0'),
        );
      });

      test('Then dpk get runs so pubspecs follow the catalog', () {
        expect(
          File(d.path('repo/packages/a/pubspec.yaml')).readAsStringSync(),
          contains('http: ^1.2.2'),
        );
        expect(runner.dartCommands, contains('pub get'));
      });
    });

    test(
      'When upgrading across major versions then the newest resolvable versions are used',
      () async {
        await dpk(
          ['catalog', 'upgrade', '--major-versions'],
          directory: d.path('repo'),
          processRunner: runner,
        );

        final config = File(d.path('repo/dpk.yaml')).readAsStringSync();
        expect(config, contains('http: ^2.0.1'));
        expect(config, contains('meta: 1.19.0'));
      },
    );

    test('When upgrading with --dry-run then dpk.yaml is unchanged', () async {
      final result = await dpk(
        ['catalog', 'upgrade', '--major-versions', '--dry-run'],
        directory: d.path('repo'),
        processRunner: runner,
      );

      expect(result.stdout, contains('http: ^1.1.0 -> ^2.0.1'));
      expect(
        File(d.path('repo/dpk.yaml')).readAsStringSync(),
        contains('http: ^1.1.0'),
      );
    });
  });

  group('Given a project-mode project without ignore rules', () {
    setUp(() async {
      await d.dir('app', [
        d.file('pubspec.yaml', pubspec('app')),
        d.file(
          'dpk.yaml',
          'version: $versionConstraint\nmode: project\nscripts:\n  a:\n    command: x\n    runHooksFrom: get\n',
        ),
      ]).create();
    });

    group('When running dpk doctor', () {
      late DpkResult result;

      setUp(() async {
        result = await dpk(['doctor'], directory: d.path('app'));
      });

      test('Then the dpk and project basics are reported', () {
        expect(result.stdout, contains('✓ dpk '));
        expect(result.stdout, contains('Standalone package app'));
      });

      test('Then setup gaps are warnings, not failures', () {
        expect(result.exitCode, equals(0), reason: '$result');
        expect(result.stdout, contains('! pub_packages/ is not in .gitignore'));
        expect(
          result.stdout,
          contains('is not excluded in analysis_options.yaml'),
        );
        expect(
          result.stdout,
          contains('"scripts.a.runHooksFrom" is deprecated'),
        );
      });
    });
  });

  group('Given a directory without a dpk project', () {
    test(
      'When running dpk doctor then the project problem fails the check',
      () async {
        final empty = Directory.systemTemp.createTempSync('dpk_doctor');
        addTearDown(() => empty.deleteSync(recursive: true));

        final result = await dpk(['doctor'], directory: empty.path);

        expect(result.exitCode, equals(1));
        expect(result.stdout, contains('✗ No pubspec.yaml found'));
      },
    );
  });

  group('Given the published JSON schema', () {
    final schema =
        jsonDecode(File('schema/dpk.schema.json').readAsStringSync())
            as Map<String, Object?>;
    final definitions = schema['definitions']! as Map<String, Object?>;

    Set<String> propertiesOf(Map<String, Object?> node) =>
        (node['properties']! as Map<String, Object?>).keys.toSet();

    test('Then it covers every top-level key', () {
      expect(propertiesOf(schema), equals(DpkConfig.keys.toSet()));
    });

    test('Then it covers every script key, including the deprecated ones', () {
      final script =
          ((definitions['script']! as Map)['oneOf'] as List)[1]
              as Map<String, Object?>;
      expect(
        propertiesOf(script),
        equals({...Script.keys, ...Script.legacyKeys.keys}),
      );
    });

    test('Then it covers every catalog key', () {
      expect(
        propertiesOf(definitions['catalog']! as Map<String, Object?>),
        equals(Catalog.keys.toSet()),
      );
    });
  });
}

Map<String, Object?> _versions(
  String name, {
  required String current,
  required String upgradable,
  required String resolvable,
  required String latest,
}) => {
  'package': name,
  'current': {'version': current},
  'upgradable': {'version': upgradable},
  'resolvable': {'version': resolvable},
  'latest': {'version': latest},
};
