import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('Given a workspace fixture and the dpk executable', () {
    late Directory testWorkspaceRoot;
    late Directory pkgWithDpk;
    late Directory pkgWithoutDpk;
    late Directory pkgWithForbiddenFields;
    late String dpkExecutable;

    setUpAll(() {
      final testDir = Directory.current;
      final fixturesDir = Directory(
        path.join(testDir.path, 'test', 'fixtures'),
      );
      testWorkspaceRoot = Directory(
        path.join(fixturesDir.path, 'test_workspace'),
      );
      pkgWithDpk = Directory(
        path.join(testWorkspaceRoot.path, 'packages', 'pkg_with_dpk'),
      );
      pkgWithoutDpk = Directory(
        path.join(testWorkspaceRoot.path, 'packages', 'pkg_without_dpk'),
      );
      pkgWithForbiddenFields = Directory(
        path.join(
          testWorkspaceRoot.path,
          'packages',
          'pkg_with_forbidden_fields',
        ),
      );
      dpkExecutable = path.join(testDir.path, 'bin', 'dpk.dart');
    });

    group('When running scripts from a package with dpk.yaml', () {
      late ProcessResult rootScriptResult;
      late ProcessResult sharedScriptResult;
      late ProcessResult packageScriptResult;

      setUpAll(() async {
        rootScriptResult = await runDpk(dpkExecutable, [
          'run',
          'root_script',
        ], workingDirectory: pkgWithDpk.path);
        sharedScriptResult = await runDpk(dpkExecutable, [
          'run',
          'shared_script',
        ], workingDirectory: pkgWithDpk.path);
        packageScriptResult = await runDpk(dpkExecutable, [
          'run',
          'pkg_script',
        ], workingDirectory: pkgWithDpk.path);
      });

      test('Then root scripts are available', () {
        expect(rootScriptResult.exitCode, equals(0));
        expect(rootScriptResult.stdout.toString(), contains('from root'));
      });

      test('Then overridden shared scripts use the package definition', () {
        expect(sharedScriptResult.exitCode, equals(0));
        expect(
          sharedScriptResult.stdout.toString(),
          contains('shared from package'),
        );
        expect(
          sharedScriptResult.stdout.toString(),
          isNot(contains('shared from root')),
        );
      });

      test('Then package-specific scripts are available', () {
        expect(packageScriptResult.exitCode, equals(0));
        expect(packageScriptResult.stdout.toString(), contains('package only'));
      });
    });

    group('When running scripts from a package without dpk.yaml', () {
      late ProcessResult rootScriptResult;
      late ProcessResult sharedScriptResult;
      late ProcessResult packageScriptResult;

      setUpAll(() async {
        rootScriptResult = await runDpk(dpkExecutable, [
          'run',
          'root_script',
        ], workingDirectory: pkgWithoutDpk.path);
        sharedScriptResult = await runDpk(dpkExecutable, [
          'run',
          'shared_script',
        ], workingDirectory: pkgWithoutDpk.path);
        packageScriptResult = await runDpk(dpkExecutable, [
          'run',
          'pkg_script',
        ], workingDirectory: pkgWithoutDpk.path);
      });

      test('Then root scripts are inherited', () {
        expect(rootScriptResult.exitCode, equals(0));
        expect(rootScriptResult.stdout.toString(), contains('from root'));
      });

      test('Then shared scripts use the root definition', () {
        expect(sharedScriptResult.exitCode, equals(0));
        expect(
          sharedScriptResult.stdout.toString(),
          contains('shared from root'),
        );
      });

      test('Then package-specific scripts are unavailable', () {
        expect(packageScriptResult.exitCode, isNot(equals(0)));
      });
    });

    group('When running scripts from the workspace root', () {
      late ProcessResult rootScriptResult;
      late ProcessResult sharedScriptResult;
      late ProcessResult packageScriptResult;

      setUpAll(() async {
        rootScriptResult = await runDpk(dpkExecutable, [
          'run',
          'root_script',
        ], workingDirectory: testWorkspaceRoot.path);
        sharedScriptResult = await runDpk(dpkExecutable, [
          'run',
          'shared_script',
        ], workingDirectory: testWorkspaceRoot.path);
        packageScriptResult = await runDpk(dpkExecutable, [
          'run',
          'pkg_script',
        ], workingDirectory: testWorkspaceRoot.path);
      });

      test('Then root scripts are available', () {
        expect(rootScriptResult.exitCode, equals(0));
        expect(rootScriptResult.stdout.toString(), contains('from root'));
      });

      test('Then shared scripts use the root definition', () {
        expect(sharedScriptResult.exitCode, equals(0));
        expect(
          sharedScriptResult.stdout.toString(),
          contains('shared from root'),
        );
      });

      test('Then package-specific scripts are unavailable', () {
        expect(packageScriptResult.exitCode, isNot(equals(0)));
      });
    });

    test(
      'When running from a package with forbidden dpk fields then validation fails',
      () async {
        final result = await runDpk(dpkExecutable, [
          'run',
          'some_script',
        ], workingDirectory: pkgWithForbiddenFields.path);

        expect(result.exitCode, isNot(equals(0)));
        expect(
          result.stderr.toString(),
          anyOf(contains('catalog'), contains('mode')),
        );
      },
    );

    group('When running a runInPackages script', () {
      late ProcessResult fromRootResult;
      late ProcessResult fromPackageResult;

      setUpAll(() async {
        fromRootResult = await runDpk(dpkExecutable, [
          'run',
          'multi_package',
        ], workingDirectory: testWorkspaceRoot.path);
        fromPackageResult = await runDpk(dpkExecutable, [
          'run',
          'multi_package',
        ], workingDirectory: pkgWithDpk.path);
      });

      test('Then it runs in all packages from the workspace root', () {
        expect(fromRootResult.exitCode, equals(0));
        expect(fromRootResult.stdout.toString(), contains('pkg_with_dpk'));
        expect(fromRootResult.stdout.toString(), contains('pkg_without_dpk'));
        expect(
          fromRootResult.stdout.toString(),
          contains('pkg_with_forbidden_fields'),
        );
      });

      test('Then it runs in all packages from a package directory', () {
        expect(fromPackageResult.exitCode, equals(0));
        expect(fromPackageResult.stdout.toString(), contains('pkg_with_dpk'));
        expect(
          fromPackageResult.stdout.toString(),
          contains('pkg_without_dpk'),
        );
        expect(
          fromPackageResult.stdout.toString(),
          contains('pkg_with_forbidden_fields'),
        );
      });
    });
  });

  group('Given the example monorepo and the dpk executable', () {
    late String dpkExecutable;
    late Directory monorepoRoot;
    late Directory package1;
    late Directory package2;

    setUpAll(() {
      final testDir = Directory.current;
      dpkExecutable = path.join(testDir.path, 'bin', 'dpk.dart');
      monorepoRoot = Directory(path.join(testDir.path, 'examples', 'monorepo'));
      package1 = Directory(
        path.join(monorepoRoot.path, 'packages', 'package_1'),
      );
      package2 = Directory(
        path.join(monorepoRoot.path, 'packages', 'package_2'),
      );
    });

    group('When running dpk get', () {
      late ProcessResult result;
      late String package1Content;
      late String package2Content;

      setUpAll(() async {
        result = await runDpk(dpkExecutable, [
          'get',
        ], workingDirectory: monorepoRoot.path);
        package1Content = File(
          path.join(package1.path, 'pubspec.yaml'),
        ).readAsStringSync();
        package2Content = File(
          path.join(package2.path, 'pubspec.yaml'),
        ).readAsStringSync();
      });

      test('Then catalog comments are added to workspace packages', () {
        expect(result.exitCode, equals(0));
        expect(
          package1Content,
          contains('meta: 1.15.0 # Configured via catalog'),
        );
        expect(package1Content, contains('luthor: # Configured via catalog'));
        expect(
          package2Content,
          contains('meta: 1.15.0 # Configured via catalog'),
        );
      });

      test('Then catalog comments survive pubspec sorting', () {
        expect(package1Content, contains('# Configured via catalog'));
      });

      test('Then catalog package metadata is applied', () {
        expect(package1Content, contains('version: 1.2.3'));
        expect(package1Content, contains('resolution: workspace'));
        expect(package1Content, contains('publish_to: none'));
        expect(
          package1Content,
          contains('homepage: https://example.com/package_1'),
        );
        expect(
          package1Content,
          contains(
            'repository: https://github.com/exaby73/dpk/tree/main/examples/monorepo/packages/package_1',
          ),
        );
        expect(
          package1Content,
          contains('issue_tracker: https://github.com/exaby73/dpk/issues'),
        );
        expect(
          package1Content,
          contains(
            'documentation: https://pub.dev/documentation/package_1/1.2.3/',
          ),
        );
        expect(
          package1Content,
          contains('funding:\n  - https://github.com/sponsors/package_1'),
        );
        expect(
          package1Content,
          contains('platforms:\n  linux: null\n  macos: null'),
        );
      });

      test('Then non-catalog dependencies do not receive comments', () {
        final lines = package1Content.split('\n');
        final freezedLine = lines.firstWhere(
          (line) => line.contains('freezed_annotation:'),
          orElse: () => '',
        );
        expect(freezedLine, isNot(contains('Configured via catalog')));
      });
    });
  });
}

Future<ProcessResult> runDpk(
  String executable,
  List<String> arguments, {
  required String workingDirectory,
}) {
  return Process.run('dart', [
    executable,
    ...arguments,
  ], workingDirectory: workingDirectory);
}
