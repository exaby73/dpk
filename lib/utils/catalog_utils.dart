import 'package:dpk/config/data/catalog.dart';
import 'package:logging/logging.dart';
import 'package:pubspec_parse/pubspec_parse.dart' as pubspec_parse;
import 'package:yaml_edit/yaml_edit.dart';

/// Updates existing dependencies in a pubspec with catalog versions.
/// Only updates dependencies that already exist in the pubspec.
/// Warns if a dependency_overrides entry matches a catalog dependency.
void updateExistingDependencies(
  YamlEditor editor,
  pubspec_parse.Pubspec pubspec,
  Catalog catalog,
) {
  final catalogDependencies = catalog.dependencies;
  if (catalogDependencies == null || catalogDependencies.isEmpty) {
    return;
  }

  final dependencySections = [
    ('dependencies', pubspec.dependencies),
    ('dev_dependencies', pubspec.devDependencies),
  ];

  for (final (sectionName, sectionDeps) in dependencySections) {
    if (sectionDeps.isEmpty) {
      continue;
    }

    for (final entry in sectionDeps.entries) {
      final packageName = entry.key;
      if (catalogDependencies.containsKey(packageName)) {
        final catalogDep = catalogDependencies[packageName]!;
        editor.update([sectionName, packageName], catalogDep.toJson());
      }
    }
  }

  for (final entry in pubspec.dependencyOverrides.entries) {
    final packageName = entry.key;
    if (catalogDependencies.containsKey(packageName)) {
      Logger.root.warning(
        'Catalog version for "$packageName" in ${pubspec.name} will be '
        'overridden by dependency_overrides.',
      );
    }
  }
}
