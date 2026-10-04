import 'package:dpk/scripts/run_plan.dart';
import 'package:dpk/workspace/workspace.dart';
import 'package:test/test.dart';

void main() {
  group('Given a workspace with three packages', () {
    final workspace = _workspace(current: 'packages/a');

    test(
      'When nothing selects packages then the plan runs in the current one',
      () {
        final plan = planRun(workspace: workspace);

        expect(_names(plan), equals(['a']));
        expect(plan.isSingle, isTrue);
      },
    );

    test('When run_in_packages uses a glob then it matches by path', () {
      final plan = planRun(workspace: workspace, runInPackages: ['packages/*']);

      expect(_names(plan), equals(['a', 'b']));
    });

    test('When a glob starts with ./ then it still matches', () {
      final plan = planRun(
        workspace: workspace,
        runInPackages: ['./packages/*'],
      );

      expect(_names(plan), equals(['a', 'b']));
    });

    test('When run_in_packages names a package then it matches by name', () {
      final plan = planRun(workspace: workspace, runInPackages: ['app']);

      expect(_names(plan), equals(['app']));
    });

    test('When globs overlap then each package appears once', () {
      final plan = planRun(
        workspace: workspace,
        runInPackages: ['packages/*', 'packages/a', 'a'],
      );

      expect(_names(plan), equals(['a', 'b']));
    });

    test('When run_in_packages lists . then the root is included', () {
      final plan = planRun(workspace: workspace, runInPackages: ['.']);

      expect(_names(plan), equals(['_']));
    });

    test('When run_in_packages matches nothing then planning fails', () {
      expect(
        () => planRun(workspace: workspace, runInPackages: ['pakages/*']),
        throwsA(
          isA<RunPlanException>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('matches no workspace packages'),
              contains('a (packages/a)'),
            ),
          ),
        ),
      );
    });

    test('When filters narrow run_in_packages then only matches remain', () {
      final plan = planRun(
        workspace: workspace,
        runInPackages: ['packages/*'],
        filters: ['b'],
      );

      expect(_names(plan), equals(['b']));
    });

    test(
      'When filters are given alone then they select from the workspace',
      () {
        final plan = planRun(workspace: workspace, filters: ['apps/*', 'a']);

        expect(_names(plan), equals(['a', 'app']));
      },
    );

    test('When every package is the default then the root is left out', () {
      final plan = planRun(workspace: workspace, allPackagesByDefault: true);

      expect(_names(plan), equals(['a', 'b', 'app']));
    });

    test(
      'When dependency order is on then dependencies inside the plan are known',
      () {
        final plan = planRun(
          workspace: workspace,
          allPackagesByDefault: true,
          dependencyOrder: true,
        );

        expect(plan.dependencies['app'], equals({'a', 'b'}));
        expect(plan.dependencies['b'], equals({'a'}));
        expect(plan.dependencies['a'], isEmpty);
      },
    );
  });

  group('Given workspace packages that depend on each other in a cycle', () {
    final workspace = _workspace(
      current: '.',
      dependencies: {
        'a': {'b'},
        'b': {'a'},
      },
    );

    test('When planning in dependency order then the cycle is reported', () {
      expect(
        () => planRun(
          workspace: workspace,
          allPackagesByDefault: true,
          dependencyOrder: true,
        ),
        throwsA(
          isA<RunPlanException>().having(
            (e) => e.message,
            'message',
            contains('a -> b -> a'),
          ),
        ),
      );
    });
  });

  group('Given a standalone package', () {
    final package = WorkspacePackage(
      name: 'solo',
      path: '/solo',
      relativePath: '.',
    );
    final workspace = Workspace(
      root: package,
      packages: const [],
      current: package,
    );

    test(
      'When run_in_packages is set then planning explains it needs a workspace',
      () {
        expect(
          () => planRun(workspace: workspace, runInPackages: ['packages/*']),
          throwsA(isA<RunPlanException>()),
        );
      },
    );

    test('When every package is the default then the package itself runs', () {
      expect(
        _names(planRun(workspace: workspace, allPackagesByDefault: true)),
        equals(['solo']),
      );
    });
  });
}

List<String> _names(RunPlan plan) => [for (final p in plan.packages) p.name];

Workspace _workspace({
  required String current,
  Map<String, Set<String>>? dependencies,
}) {
  final deps =
      dependencies ??
      {
        'a': <String>{},
        'b': {'a'},
        'app': {'a', 'b', 'outside'},
      };
  WorkspacePackage package(String name, String path) => WorkspacePackage(
    name: name,
    path: '/w/$path',
    relativePath: path,
    dependencies: deps[name] ?? const {},
  );
  final root = WorkspacePackage(name: '_', path: '/w', relativePath: '.');
  final packages = [
    package('a', 'packages/a'),
    package('b', 'packages/b'),
    if (dependencies == null) package('app', 'apps/app'),
  ];
  return Workspace(
    root: root,
    packages: packages,
    current: current == '.'
        ? root
        : packages.firstWhere((p) => p.relativePath == current),
  );
}
