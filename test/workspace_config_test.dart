import 'dart:io';

import 'package:dpk/config/config.dart';
import 'package:dpk/utils/workspace.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  late Directory fixturesDir;
  late Directory workspaceRoot;
  late Directory pkgWithDpk;
  late Directory pkgWithoutDpk;
  late Directory pkgWithForbiddenFields;

  setUpAll(() {
    // Get the test fixtures directory
    final testDir = Directory.current;
    fixturesDir = Directory(path.join(testDir.path, 'test', 'fixtures'));
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
    // Clear workspace info cache before each test
    clearWorkspaceInfoCache();
  });

  group('WorkspaceInfo', () {
    test('detects workspace root correctly', () async {
      final info = await getWorkspaceInfo(workspaceRoot);

      expect(info.isWorkspace, isTrue);
      expect(info.workspaceRoot, isNotNull);
      expect(info.workspaceRoot!.path, equals(workspaceRoot.path));
      expect(info.isWorkspacePackage, isFalse);
    });

    test('detects workspace package correctly', () async {
      final info = await getWorkspaceInfo(pkgWithDpk);

      expect(info.isWorkspace, isTrue);
      expect(info.workspaceRoot, isNotNull);
      expect(info.workspaceRoot!.path, equals(workspaceRoot.path));
      expect(info.isWorkspacePackage, isTrue);
    });

    test('detects non-workspace package correctly', () async {
      // Use current directory (dpk project itself, not a workspace)
      final info = await getWorkspaceInfo(Directory.current);

      expect(info.isWorkspace, isFalse);
      expect(info.workspaceRoot, isNull);
      expect(info.isWorkspacePackage, isFalse);
    });
  });

  group('Config Loading - Workspace Script Merging', () {
    test('merges workspace root and package scripts', () async {
      final config = await loadConfig(pkgWithDpk);

      expect(config.scripts, isNotNull);
      final scriptsMap = config.scripts!.scriptsMap;

      // Should have root_script from workspace root
      expect(scriptsMap.containsKey('root_script'), isTrue);
      expect(scriptsMap['root_script']!.command, equals('echo "from root"'));

      // Should have shared_script overridden by package
      expect(scriptsMap.containsKey('shared_script'), isTrue);
      expect(
        scriptsMap['shared_script']!.command,
        equals('echo "shared from package"'),
      );

      // Should have pkg_script from package
      expect(scriptsMap.containsKey('pkg_script'), isTrue);
      expect(scriptsMap['pkg_script']!.command, equals('echo "package only"'));
    });

    test('package script completely overrides root script', () async {
      final config = await loadConfig(pkgWithDpk);

      final scriptsMap = config.scripts!.scriptsMap;

      // Verify that shared_script uses package version (complete override)
      expect(
        scriptsMap['shared_script']!.command,
        equals('echo "shared from package"'),
      );
      expect(
        scriptsMap['shared_script']!.command,
        isNot(equals('echo "shared from root"')),
      );
    });

    test('package without dpk.yaml inherits root scripts', () async {
      final config = await loadConfig(pkgWithoutDpk);

      expect(config.scripts, isNotNull);
      final scriptsMap = config.scripts!.scriptsMap;

      // Should have root_script from workspace root
      expect(scriptsMap.containsKey('root_script'), isTrue);
      expect(scriptsMap['root_script']!.command, equals('echo "from root"'));

      // Should have shared_script from workspace root
      expect(scriptsMap.containsKey('shared_script'), isTrue);
      expect(
        scriptsMap['shared_script']!.command,
        equals('echo "shared from root"'),
      );

      // Should NOT have pkg_script (package-specific)
      expect(scriptsMap.containsKey('pkg_script'), isFalse);
    });

    test('workspace root uses only its own scripts', () async {
      final config = await loadConfig(workspaceRoot);

      expect(config.scripts, isNotNull);
      final scriptsMap = config.scripts!.scriptsMap;

      // Should have root scripts
      expect(scriptsMap.containsKey('root_script'), isTrue);
      expect(scriptsMap.containsKey('shared_script'), isTrue);

      // Should NOT have package-specific scripts
      expect(scriptsMap.containsKey('pkg_script'), isFalse);

      // shared_script should be the root version
      expect(
        scriptsMap['shared_script']!.command,
        equals('echo "shared from root"'),
      );
    });

    test('non-workspace uses only local dpk.yaml', () async {
      // Test with the dpk project itself (not a workspace)
      final config = await loadConfig(Directory.current);

      // Should load scripts from current directory's dpk.yaml
      expect(config.scripts, isNotNull);
      // The actual scripts depend on the current dpk.yaml,
      // but it should not merge from any parent workspace
    });
  });

  group('Config Validation', () {
    test('throws error when package dpk.yaml contains catalog', () async {
      expect(
        () => loadConfig(pkgWithForbiddenFields),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('catalog'),
          ),
        ),
      );
    });

    test('throws error when package dpk.yaml contains mode', () async {
      expect(
        () => loadConfig(pkgWithForbiddenFields),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            anyOf(contains('mode'), contains('catalog')),
          ),
        ),
      );
    });

    test('validatePackageDpkYaml rejects forbidden fields', () {
      expect(
        () => validatePackageDpkYaml({'catalog': {}}),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('catalog'),
          ),
        ),
      );

      expect(
        () => validatePackageDpkYaml({'mode': 'project'}),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('mode'),
          ),
        ),
      );

      expect(
        () => validatePackageDpkYaml({'dependency_overrides': {}}),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('dependency_overrides'),
          ),
        ),
      );
    });

    test('validatePackageDpkYaml allows scripts', () {
      expect(
        () => validatePackageDpkYaml({
          'scripts': {'test': 'dart test'},
        }),
        returnsNormally,
      );
    });
  });

  group('Helper Functions', () {
    test('loadDpkYamlRaw returns null for non-existent file', () {
      final nonExistentDir = Directory(
        path.join(Directory.systemTemp.path, 'non_existent_dir_12345'),
      );
      final result = loadDpkYamlRaw(nonExistentDir);
      expect(result, isNull);
    });

    test('loadDpkYamlRaw loads existing dpk.yaml', () {
      final result = loadDpkYamlRaw(workspaceRoot);
      expect(result, isNotNull);
      expect(result!.containsKey('scripts'), isTrue);
    });

    test('loadDpkYamlRaw returns null for package without dpk.yaml', () {
      final result = loadDpkYamlRaw(pkgWithoutDpk);
      expect(result, isNull);
    });
  });

  group('findDpkYamlDirectory', () {
    test('finds dpk.yaml in current directory', () async {
      final result = await findDpkYamlDirectory(workspaceRoot);
      expect(result, isNotNull);
      expect(result!.path, equals(workspaceRoot.path));
    });

    test('finds dpk.yaml in workspace root from package', () async {
      final result = await findDpkYamlDirectory(pkgWithDpk);
      expect(result, isNotNull);
      // Should find the package's own dpk.yaml first
      expect(result!.path, equals(pkgWithDpk.path));
    });

    test('finds dpk.yaml in workspace root when package has none', () async {
      final result = await findDpkYamlDirectory(pkgWithoutDpk);
      expect(result, isNotNull);
      // Should walk up and find workspace root dpk.yaml
      expect(result!.path, equals(workspaceRoot.path));
    });

    test('respects workspace boundaries', () async {
      // This test ensures we don't search beyond workspace root
      // If the package doesn't have dpk.yaml and root doesn't either,
      // it should stop at workspace root
      final result = await findDpkYamlDirectory(pkgWithoutDpk);
      expect(result, isNotNull);
      // Should find workspace root and stop there
      expect(result!.path, equals(workspaceRoot.path));
    });
  });
}
