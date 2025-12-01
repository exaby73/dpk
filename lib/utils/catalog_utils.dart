import 'package:dpk/config/data/catalog.dart';
import 'package:dpk/config/data/dependency.dart';
import 'package:pubspec_parse/pubspec_parse.dart' as pubspec_parse;
import 'package:yaml_edit/yaml_edit.dart';

/// Combines all catalog dependencies into a single map.
Map<String, Dependency> combineCatalogDependencies(Catalog catalog) {
  final combined = <String, Dependency>{};

  if (catalog.dependencies != null) {
    combined.addAll(catalog.dependencies!);
  }

  if (catalog.devDependencies != null) {
    combined.addAll(catalog.devDependencies!);
  }

  if (catalog.dependencyOverrides != null) {
    combined.addAll(catalog.dependencyOverrides!);
  }

  return combined;
}

/// Updates existing dependencies in a pubspec with catalog versions.
/// Only updates dependencies that already exist in the pubspec.
void updateExistingDependencies(
  YamlEditor editor,
  pubspec_parse.Pubspec pubspec,
  Catalog catalog,
) {
  final catalogDependencies = combineCatalogDependencies(catalog);

  if (catalogDependencies.isEmpty) {
    return;
  }

  final dependencySections = [
    ('dependencies', pubspec.dependencies),
    ('dev_dependencies', pubspec.devDependencies),
    ('dependency_overrides', pubspec.dependencyOverrides),
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
}
