import 'dart:convert';

import 'package:dpk/commands/dpk_command.dart';
import 'package:dpk/workspace/workspace.dart';

final class ListCommand extends DpkCommand {
  ListCommand(super.context) {
    argParser
      ..addFlag(
        'graph',
        negatable: false,
        help: 'Show which workspace packages each package depends on.',
      )
      ..addFlag('json', negatable: false, help: 'Print JSON.');
  }

  @override
  String get name => 'list';

  @override
  List<String> get aliases => const ['ls'];

  @override
  String get description => 'List the workspace packages.';

  @override
  String get category => CommandCategory.workspace;

  @override
  Future<int> run() async {
    final workspace = context.requireProject.workspace;
    final names = {for (final package in workspace.allPackages) package.name};

    Set<String> workspaceDependencies(WorkspacePackage package) => {
      ...package.dependencies,
      ...package.devDependencies,
    }.intersection(names)..remove(package.name);

    if (argResults!.flag('json')) {
      console.info(
        const JsonEncoder.withIndent('  ').convert([
          for (final package in workspace.allPackages)
            {
              'name': package.name,
              'version': package.version,
              'path': package.relativePath,
              'root': identical(package, workspace.root),
              'publishable': package.isPublishable,
              'dependencies': [
                ...package.dependencies.intersection(names)
                  ..remove(package.name),
              ]..sort(),
              'dev_dependencies': [
                ...package.devDependencies.intersection(names)
                  ..remove(package.name),
              ]..sort(),
            },
        ]),
      );
      return 0;
    }

    final packages = workspace.allPackages;
    final nameWidth = packages.fold(
      0,
      (w, p) => p.name.length > w ? p.name.length : w,
    );
    final versionWidth = packages.fold(
      0,
      (w, p) => (p.version ?? '-').length > w ? (p.version ?? '-').length : w,
    );
    for (final package in packages) {
      final marker = identical(package, workspace.root) && workspace.isWorkspace
          ? console.dim(' (root)')
          : '';
      console.info(
        '${console.bold(package.name.padRight(nameWidth))}  '
        '${(package.version ?? '-').padRight(versionWidth)}  '
        '${console.dim(package.relativePath)}$marker',
      );
      if (argResults!.flag('graph')) {
        final dependencies = workspaceDependencies(package).toList()..sort();
        for (final dependency in dependencies) {
          final dev = package.dependencies.contains(dependency) ? '' : ' (dev)';
          console.info('  └─ $dependency$dev');
        }
      }
    }
    return 0;
  }
}
