import 'dart:io';

import 'package:dpk/config/config.dart';
import 'package:dpk/config/data/scripts.dart';
import 'package:dpk/utils/workspace.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('Given workspace fixture directories', () {
    late Directory workspaceRoot;
    late Directory pkgWithDpk;
    late Directory pkgWithoutDpk;
    late Directory pkgWithForbiddenFields;

    setUpAll(() {
      final fixturesDir = Directory(
        path.join(Directory.current.path, 'test', 'fixtures'),
      );
      workspaceRoot = Directory(path.join(fixturesDir.path, 'test_workspace'));
      pkgWithDpk = Directory(
        path.join(workspaceRoot.path, 'packages', 'pkg_with_dpk'),
      );
      pkgWithoutDpk = Directory(
        path.join(workspaceRoot.path, 'packages', 'pkg_without_dpk'),
      );
      pkgWithForbiddenFields = Directory(
        path.join(workspaceRoot.path, 'packages', 'pkg_with_forbidden_fields'),
      );
    });

    setUp(() {
      clearWorkspaceInfoCache();
    });

    test(
      'When inspecting the workspace root then it is the root package',
      () async {
        final info = await getWorkspaceInfo(workspaceRoot);

        expect(info.isWorkspace, isTrue);
        expect(info.workspaceRoot, isNotNull);
        expect(info.workspaceRoot!.path, equals(workspaceRoot.path));
        expect(info.isWorkspacePackage, isFalse);
      },
    );

    test(
      'When inspecting a workspace package then it is linked to the root',
      () async {
        final info = await getWorkspaceInfo(pkgWithDpk);

        expect(info.isWorkspace, isTrue);
        expect(info.workspaceRoot, isNotNull);
        expect(info.workspaceRoot!.path, equals(workspaceRoot.path));
        expect(info.isWorkspacePackage, isTrue);
      },
    );

    test(
      'When inspecting a non-workspace package then no workspace is reported',
      () async {
        final info = await getWorkspaceInfo(Directory.current);

        expect(info.isWorkspace, isFalse);
        expect(info.workspaceRoot, isNull);
        expect(info.isWorkspacePackage, isFalse);
      },
    );

    group('When loading config for a package with dpk.yaml', () {
      late Map<String, dynamic> scriptsMap;

      setUp(() async {
        final config = await loadConfig(pkgWithDpk);
        scriptsMap = config.scripts!.scriptsMap;
      });

      test('Then root scripts are inherited', () {
        expect(scriptsMap.containsKey('root_script'), isTrue);
        expect(scriptsMap['root_script']!.command, equals('echo "from root"'));
      });

      test('Then shared scripts are overridden by the package', () {
        expect(scriptsMap.containsKey('shared_script'), isTrue);
        expect(
          scriptsMap['shared_script']!.command,
          equals('echo "shared from package"'),
        );
      });

      test('Then package-only scripts are available', () {
        expect(scriptsMap.containsKey('pkg_script'), isTrue);
        expect(
          scriptsMap['pkg_script']!.command,
          equals('echo "package only"'),
        );
      });
    });

    group('When loading config for a package without dpk.yaml', () {
      late Map<String, dynamic> scriptsMap;

      setUp(() async {
        final config = await loadConfig(pkgWithoutDpk);
        scriptsMap = config.scripts!.scriptsMap;
      });

      test('Then root scripts are inherited', () {
        expect(scriptsMap.containsKey('root_script'), isTrue);
        expect(scriptsMap['root_script']!.command, equals('echo "from root"'));
      });

      test('Then shared scripts use the root definition', () {
        expect(scriptsMap.containsKey('shared_script'), isTrue);
        expect(
          scriptsMap['shared_script']!.command,
          equals('echo "shared from root"'),
        );
      });

      test('Then package-only scripts are not available', () {
        expect(scriptsMap.containsKey('pkg_script'), isFalse);
      });
    });

    group('When loading config for the workspace root', () {
      late Map<String, dynamic> scriptsMap;

      setUp(() async {
        final config = await loadConfig(workspaceRoot);
        scriptsMap = config.scripts!.scriptsMap;
      });

      test('Then root scripts are available', () {
        expect(scriptsMap.containsKey('root_script'), isTrue);
        expect(scriptsMap.containsKey('shared_script'), isTrue);
      });

      test('Then package-only scripts are not available', () {
        expect(scriptsMap.containsKey('pkg_script'), isFalse);
      });

      test('Then shared scripts use the root definition', () {
        expect(
          scriptsMap['shared_script']!.command,
          equals('echo "shared from root"'),
        );
      });
    });

    test(
      'When loading config for a non-workspace package then local scripts load',
      () async {
        final config = await loadConfig(Directory.current);

        expect(config.scripts, isNotNull);
      },
    );

    test('When parsing script metadata then description is retained', () {
      final yaml =
          loadYaml('''
documented:
  command: dart test
  description: Run documented script
''')
              as YamlMap;

      final scripts = Scripts.fromYaml(yaml);

      expect(
        scripts.scriptsMap['documented']!.description,
        equals('Run documented script'),
      );
    });

    test('When loading forbidden package config then validation fails', () {
      expect(
        () => loadConfig(pkgWithForbiddenFields),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            anyOf(contains('catalog'), contains('mode')),
          ),
        ),
      );
    });

    test('When validating catalog in package dpk.yaml then it is rejected', () {
      expect(
        () => validatePackageDpkYaml({'catalog': {}}),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('catalog'),
          ),
        ),
      );
    });

    test('When validating mode in package dpk.yaml then it is rejected', () {
      expect(
        () => validatePackageDpkYaml({'mode': 'project'}),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('mode'),
          ),
        ),
      );
    });

    test(
      'When validating dependency_overrides in package dpk.yaml then it is rejected',
      () {
        expect(
          () => validatePackageDpkYaml({'dependency_overrides': {}}),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains('dependency_overrides'),
            ),
          ),
        );
      },
    );

    test('When validating scripts in package dpk.yaml then it is allowed', () {
      expect(
        () => validatePackageDpkYaml({
          'scripts': {'test': 'dart test'},
        }),
        returnsNormally,
      );
    });

    test('When loading missing dpk.yaml then null is returned', () {
      final nonExistentDir = Directory(
        path.join(Directory.systemTemp.path, 'non_existent_dir_12345'),
      );
      final result = loadDpkYamlRaw(nonExistentDir);

      expect(result, isNull);
    });

    test('When loading workspace dpk.yaml then the raw yaml is returned', () {
      final result = loadDpkYamlRaw(workspaceRoot);

      expect(result, isNotNull);
      expect(result!.containsKey('scripts'), isTrue);
    });

    test('When loading package without dpk.yaml then null is returned', () {
      final result = loadDpkYamlRaw(pkgWithoutDpk);

      expect(result, isNull);
    });

    test(
      'When finding dpk.yaml from the workspace root then the root is returned',
      () async {
        final result = await findDpkYamlDirectory(workspaceRoot);

        expect(result, isNotNull);
        expect(result!.path, equals(workspaceRoot.path));
      },
    );

    test(
      'When finding dpk.yaml from a package with config then the package is returned',
      () async {
        final result = await findDpkYamlDirectory(pkgWithDpk);

        expect(result, isNotNull);
        expect(result!.path, equals(pkgWithDpk.path));
      },
    );

    test(
      'When finding dpk.yaml from a package without config then root is returned',
      () async {
        final result = await findDpkYamlDirectory(pkgWithoutDpk);

        expect(result, isNotNull);
        expect(result!.path, equals(workspaceRoot.path));
      },
    );
  });
}
