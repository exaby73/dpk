import 'package:dpk/workspace/workspace.dart';
import 'package:glob/glob.dart';

/// A run plan could not be built, for example because a glob matched no
/// workspace package.
final class RunPlanException implements Exception {
  RunPlanException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// How to run a command across workspace packages.
final class RunPlan {
  const RunPlan({
    required this.packages,
    this.concurrency,
    this.failFast = false,
    this.dependencyOrder = false,
    this.dependencies = const {},
  });

  /// The packages to run in, in workspace order.
  final List<WorkspacePackage> packages;

  /// The most packages to run at once. `null` runs all at once.
  final int? concurrency;

  /// Whether to stop the remaining packages when one fails.
  final bool failFast;

  /// Whether a package waits for its workspace dependencies to finish.
  final bool dependencyOrder;

  /// For each package name, the names of the planned packages it depends on.
  /// Only filled in when [dependencyOrder] is on.
  final Map<String, Set<String>> dependencies;

  /// Whether the command runs once in one package, with the terminal.
  bool get isSingle => packages.length == 1;
}

/// Chooses the packages a command runs in.
///
/// - With neither [runInPackages] nor [filters], it runs in the current
///   package.
/// - [runInPackages] selects workspace packages by name or by a glob over
///   their paths relative to the workspace root (`.` is the root).
/// - [filters] narrow that selection. Without [runInPackages], they select
///   from every package in the workspace.
/// - [allPackagesByDefault] makes an empty selection mean every workspace
///   package, as `dpk exec` does.
///
/// Throws a [RunPlanException] when a selection matches nothing.
RunPlan planRun({
  required Workspace workspace,
  List<String>? runInPackages,
  List<String> filters = const [],
  bool allPackagesByDefault = false,
  int? concurrency,
  bool failFast = false,
  bool dependencyOrder = false,
}) {
  var selected = <WorkspacePackage>[workspace.current];

  if (runInPackages != null) {
    if (!workspace.isWorkspace) {
      throw RunPlanException(
        'run_in_packages needs a workspace, but '
        '${workspace.root.relativePathOrName} has no workspace packages.',
      );
    }
    selected = _select(workspace.allPackages, runInPackages);
    if (selected.isEmpty) {
      throw RunPlanException(
        'run_in_packages (${runInPackages.join(', ')}) matches no workspace '
        'packages. ${_available(workspace)}',
      );
    }
  } else if (filters.isNotEmpty || allPackagesByDefault) {
    selected = workspace.isWorkspace ? workspace.packages : [workspace.root];
  }

  if (filters.isNotEmpty) {
    final candidates = runInPackages == null ? workspace.allPackages : selected;
    selected = _select(candidates, filters);
    if (selected.isEmpty) {
      throw RunPlanException(
        '--filter ${filters.join(', ')} matches no '
        '${runInPackages == null ? 'workspace' : 'selected'} packages. '
        '${_available(workspace)}',
      );
    }
  }

  final dependencies = dependencyOrder
      ? _dependenciesWithin(selected)
      : const <String, Set<String>>{};
  if (dependencyOrder) {
    _checkForCycles(dependencies);
  }

  return RunPlan(
    packages: selected,
    concurrency: concurrency,
    failFast: failFast,
    dependencyOrder: dependencyOrder,
    dependencies: dependencies,
  );
}

/// Packages in [candidates] that any of [patterns] match, by name or by path
/// glob, without duplicates, in [candidates] order.
List<WorkspacePackage> _select(
  List<WorkspacePackage> candidates,
  List<String> patterns,
) {
  final matchers = [for (final pattern in patterns) _matcher(pattern)];
  return [
    for (final package in candidates)
      if (matchers.any((matches) => matches(package))) package,
  ];
}

bool Function(WorkspacePackage) _matcher(String pattern) {
  var cleaned = pattern.trim();
  if (cleaned.startsWith('./')) {
    cleaned = cleaned.substring(2);
  }
  while (cleaned.length > 1 && cleaned.endsWith('/')) {
    cleaned = cleaned.substring(0, cleaned.length - 1);
  }
  if (cleaned == '.' || cleaned.isEmpty) {
    return (package) => package.relativePath == '.';
  }
  final glob = Glob(cleaned);
  return (package) =>
      package.name == cleaned ||
      (package.relativePath != '.' && glob.matches(package.relativePath));
}

String _available(Workspace workspace) =>
    'Workspace packages: '
    '${workspace.packages.map((p) => '${p.name} (${p.relativePath})').join(', ')}.';

Map<String, Set<String>> _dependenciesWithin(List<WorkspacePackage> packages) {
  final names = {for (final package in packages) package.name};
  return {
    for (final package in packages)
      package.name: package.dependencies.intersection(names)
        ..remove(package.name),
  };
}

void _checkForCycles(Map<String, Set<String>> dependencies) {
  final visiting = <String>{};
  final done = <String>{};

  void visit(String name, List<String> path) {
    if (done.contains(name)) {
      return;
    }
    if (!visiting.add(name)) {
      final cycle = [...path.sublist(path.indexOf(name)), name];
      throw RunPlanException(
        'Workspace packages depend on each other in a cycle: '
        '${cycle.join(' -> ')}. Dependency order needs an acyclic graph.',
      );
    }
    for (final dependency in dependencies[name] ?? const <String>{}) {
      visit(dependency, [...path, name]);
    }
    visiting.remove(name);
    done.add(name);
  }

  for (final name in dependencies.keys) {
    visit(name, const []);
  }
}

extension on WorkspacePackage {
  String get relativePathOrName => relativePath == '.' ? name : relativePath;
}
