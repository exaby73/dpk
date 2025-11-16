import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  late Directory testWorkspaceRoot;
  late Directory pkgWithDpk;
  late Directory pkgWithoutDpk;
  late Directory pkgWithForbiddenFields;
  late String dpkExecutable;

  setUpAll(() {
    // Get the test fixtures directory
    final testDir = Directory.current;
    final fixturesDir = Directory(path.join(testDir.path, 'test', 'fixtures'));
    testWorkspaceRoot =
        Directory(path.join(fixturesDir.path, 'test_workspace'));
    pkgWithDpk = Directory(
      path.join(testWorkspaceRoot.path, 'packages', 'pkg_with_dpk'),
    );
    pkgWithoutDpk = Directory(
      path.join(testWorkspaceRoot.path, 'packages', 'pkg_without_dpk'),
    );
    pkgWithForbiddenFields = Directory(
      path.join(testWorkspaceRoot.path, 'packages', 'pkg_with_forbidden_fields'),
    );

    // Path to dpk executable
    dpkExecutable = path.join(testDir.path, 'bin', 'dpk.dart');
  });

  group('E2E - Workspace Script Execution', () {
    test('package can execute root script', () async {
      final result = await Process.run(
        'dart',
        [dpkExecutable, 'run', 'root_script'],
        workingDirectory: pkgWithDpk.path,
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), contains('from root'));
    });

    test('package executes overridden script from package dpk.yaml', () async {
      final result = await Process.run(
        'dart',
        [dpkExecutable, 'run', 'shared_script'],
        workingDirectory: pkgWithDpk.path,
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), contains('shared from package'));
      expect(result.stdout.toString(), isNot(contains('shared from root')));
    });

    test('package can execute package-specific script', () async {
      final result = await Process.run(
        'dart',
        [dpkExecutable, 'run', 'pkg_script'],
        workingDirectory: pkgWithDpk.path,
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), contains('package only'));
    });

    test('package without dpk.yaml executes root scripts', () async {
      final result = await Process.run(
        'dart',
        [dpkExecutable, 'run', 'root_script'],
        workingDirectory: pkgWithoutDpk.path,
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), contains('from root'));
    });

    test('package without dpk.yaml executes shared script from root', () async {
      final result = await Process.run(
        'dart',
        [dpkExecutable, 'run', 'shared_script'],
        workingDirectory: pkgWithoutDpk.path,
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), contains('shared from root'));
    });

    test('package without dpk.yaml cannot execute package-specific script', () async {
      final result = await Process.run(
        'dart',
        [dpkExecutable, 'run', 'pkg_script'],
        workingDirectory: pkgWithoutDpk.path,
      );

      expect(result.exitCode, isNot(equals(0)));
    });

    test('workspace root executes its own scripts', () async {
      final result = await Process.run(
        'dart',
        [dpkExecutable, 'run', 'root_script'],
        workingDirectory: testWorkspaceRoot.path,
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), contains('from root'));
    });

    test('workspace root executes shared script (not overridden)', () async {
      final result = await Process.run(
        'dart',
        [dpkExecutable, 'run', 'shared_script'],
        workingDirectory: testWorkspaceRoot.path,
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), contains('shared from root'));
    });

    test('workspace root cannot execute package-specific script', () async {
      final result = await Process.run(
        'dart',
        [dpkExecutable, 'run', 'pkg_script'],
        workingDirectory: testWorkspaceRoot.path,
      );

      expect(result.exitCode, isNot(equals(0)));
    });
  });

  group('E2E - Workspace Validation', () {
    test('fails when package dpk.yaml contains forbidden fields', () async {
      // Try to run any command in the package with forbidden fields
      final result = await Process.run(
        'dart',
        [dpkExecutable, 'run', 'some_script'],
        workingDirectory: pkgWithForbiddenFields.path,
      );

      expect(result.exitCode, isNot(equals(0)));
      expect(
        result.stderr.toString(),
        anyOf(contains('catalog'), contains('mode')),
      );
    });
  });

  group('E2E - Script Availability', () {
    test('package-specific script not available at workspace root', () async {
      // Attempt to run package-specific script from workspace root
      final result = await Process.run(
        'dart',
        [dpkExecutable, 'run', 'pkg_script'],
        workingDirectory: testWorkspaceRoot.path,
      );

      // Should fail because pkg_script is not defined at workspace root
      expect(result.exitCode, isNot(equals(0)));
    });

    test('package-specific script not available in other packages', () async {
      // Attempt to run pkg_script from package without dpk.yaml
      final result = await Process.run(
        'dart',
        [dpkExecutable, 'run', 'pkg_script'],
        workingDirectory: pkgWithoutDpk.path,
      );

      // Should fail because pkg_script is only in pkg_with_dpk
      expect(result.exitCode, isNot(equals(0)));
    });
  });

  group('E2E - Scripts with runInPackages', () {
    test('root script with runInPackages runs from workspace root', () async {
      // Run multi_package script from workspace root
      final result = await Process.run(
        'dart',
        [dpkExecutable, 'run', 'multi_package'],
        workingDirectory: testWorkspaceRoot.path,
      );

      expect(result.exitCode, equals(0));
      final output = result.stdout.toString();

      // Should run in all workspace packages
      expect(output, contains('pkg_with_dpk'));
      expect(output, contains('pkg_without_dpk'));
      expect(output, contains('pkg_with_forbidden_fields'));
    });

    test('root script with runInPackages runs from package directory', () async {
      // Run multi_package script from package directory
      // Should run in all workspace packages (not just the current one)
      final result = await Process.run(
        'dart',
        [dpkExecutable, 'run', 'multi_package'],
        workingDirectory: pkgWithDpk.path,
      );

      expect(result.exitCode, equals(0));
      final output = result.stdout.toString();

      // Should run in all workspace packages, not throw an error
      expect(output, contains('pkg_with_dpk'));
      expect(output, contains('pkg_without_dpk'));
      expect(output, contains('pkg_with_forbidden_fields'));
    });
  });
}
