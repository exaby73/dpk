import 'dart:convert';
import 'dart:io';

import 'package:dpk/config/data/config_data.dart';
import 'package:dpk/core/constants.dart';
import 'package:dpk/utils/collection.dart';
import 'package:dpk/utils/workspace.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

Future<Directory?> findDpkYamlDirectory(Directory startDirectory) async {
  // Get workspace info to determine boundaries
  final workspaceInfo = await getWorkspaceInfo(startDirectory);
  final stopDirectory = workspaceInfo.workspaceRoot;

  var currentDir = startDirectory;

  while (true) {
    final configFile = File(join(currentDir.path, kConfigFileName));
    if (configFile.existsSync()) {
      return currentDir;
    }

    // Stop at workspace root (don't search parent directories outside workspace)
    if (stopDirectory != null && currentDir.path == stopDirectory.path) {
      return null;
    }

    final parentDir = currentDir.parent;
    if (parentDir.path == currentDir.path) {
      return null; // Reached filesystem root
    }

    currentDir = parentDir;
  }
}

/// Loads a dpk.yaml file from the given directory and returns it as a raw YAML object.
/// Returns null if the file doesn't exist.
/// The return type is dynamic because loadYaml returns YamlMap, which implements Map.
dynamic loadDpkYamlRaw(Directory directory) {
  final configFile = File(join(directory.path, kConfigFileName));

  if (!configFile.existsSync()) {
    return null;
  }

  return loadYaml(configFile.readAsStringSync());
}

/// Validates that a workspace package's dpk.yaml doesn't contain forbidden fields.
/// Throws a StateError if any forbidden fields are found.
void validatePackageDpkYaml(Map yaml) {
  const forbiddenFields = ['catalog', 'mode', 'dependency_overrides'];

  for (final field in forbiddenFields) {
    if (yaml.containsKey(field)) {
      throw StateError(
        "'$field' not allowed in workspace package dpk.yaml - must be defined in workspace root pubspec.yaml",
      );
    }
  }
}

/// Expands glob patterns from dpk.yaml workspace field into actual directory paths.
/// Only includes directories that contain a pubspec.yaml file.
List<String>? expandWorkspaceGlobs(List<dynamic>? patterns, Directory root) {
  if (patterns == null || patterns.isEmpty) {
    return null;
  }

  final expandedPaths = <String>{};

  for (final pattern in patterns) {
    if (pattern == null || pattern is! String || pattern.isEmpty) {
      continue;
    }

    final glob = Glob(pattern);
    final matches = glob.listSync(root: root.path);

    for (final match in matches) {
      if (match is Directory) {
        final pubspecFile = File(join(match.path, 'pubspec.yaml'));
        if (pubspecFile.existsSync()) {
          expandedPaths.add(relative(match.path, from: root.path));
        }
      }
    }
  }

  if (expandedPaths.isEmpty) {
    return null;
  }

  final sortedPaths = expandedPaths.toList()..sort();
  return sortedPaths;
}

Future<ConfigData> loadConfig(Directory directory) async {
  final pubspecFile = File(join(directory.path, 'pubspec.yaml'));

  if (!pubspecFile.existsSync()) {
    throw StateError('pubspec.yaml not found in ${directory.path}');
  }

  // Get workspace information
  final workspaceInfo = await getWorkspaceInfo(directory);

  // Load and merge dpk.yaml files
  Map dpkYaml = {};
  Map? workspaceRootPubspec;

  if (workspaceInfo.isWorkspacePackage) {
    // In a workspace package (not at root)

    // Load workspace root pubspec to get workspace field
    if (workspaceInfo.workspaceRoot != null) {
      final rootPubspecFile = File(
        join(workspaceInfo.workspaceRoot!.path, 'pubspec.yaml'),
      );
      if (rootPubspecFile.existsSync()) {
        // Load workspace root dpk.yaml first to check for workspace globs
        final rootDpk = loadDpkYamlRaw(workspaceInfo.workspaceRoot!);
        if (rootDpk != null) {
          dpkYaml = rootDpk as Map;

          // Expand workspace globs and write to root pubspec
          final dpkWorkspace = dpkYaml['workspace'] as List?;
          if (dpkWorkspace != null) {
            final expandedWorkspace = expandWorkspaceGlobs(
              dpkWorkspace,
              workspaceInfo.workspaceRoot!,
            );
            if (expandedWorkspace != null) {
              _writeWorkspaceToPubspec(rootPubspecFile, expandedWorkspace);
            }
          }
        }

        workspaceRootPubspec =
            loadYaml(rootPubspecFile.readAsStringSync()) as Map;
      }
    }

    // Load package dpk.yaml if it exists
    final packageDpk = loadDpkYamlRaw(directory);
    if (packageDpk != null) {
      final packageDpkMap = packageDpk as Map;

      // Validate that package dpk.yaml doesn't contain forbidden fields
      validatePackageDpkYaml(packageDpkMap);

      // Merge scripts only (package scripts override root scripts)
      if (packageDpkMap.containsKey('scripts')) {
        final rootScripts = dpkYaml['scripts'] as Map? ?? {};
        final packageScripts = packageDpkMap['scripts'] as Map;
        // Create merged scripts map
        final mergedScripts = {...rootScripts, ...packageScripts};
        dpkYaml = {...dpkYaml, 'scripts': mergedScripts};
      }
    }
  } else {
    // Not in a workspace or at workspace root: load single dpk.yaml
    final localDpk = loadDpkYamlRaw(directory);
    if (localDpk != null) {
      dpkYaml = localDpk as Map;

      // Expand workspace globs and write to pubspec
      final dpkWorkspace = dpkYaml['workspace'] as List?;
      if (dpkWorkspace != null) {
        final expandedWorkspace = expandWorkspaceGlobs(dpkWorkspace, directory);
        if (expandedWorkspace != null) {
          _writeWorkspaceToPubspec(pubspecFile, expandedWorkspace);
        }
      }
    }
  }

  // Re-read pubspec after potential workspace expansion
  Map pubspecYaml = loadYaml(pubspecFile.readAsStringSync()) as Map;

  // Remove workspace from dpkYaml since it's already been expanded and written to pubspec
  final dpkYamlWithoutWorkspace = Map.from(dpkYaml)..remove('workspace');

  // Merge dpk.yaml with pubspec.yaml
  Map mergedYaml = mergeMaps(pubspecYaml, dpkYamlWithoutWorkspace);

  // If in a workspace package, also merge the workspace field from root pubspec
  if (workspaceInfo.isWorkspacePackage && workspaceRootPubspec != null) {
    if (workspaceRootPubspec.containsKey('workspace')) {
      mergedYaml = {
        ...mergedYaml,
        'workspace': workspaceRootPubspec['workspace'],
      };
    }
  }

  // Parse into ConfigData
  final configData = ConfigData.fromYaml(
    loadYaml(jsonEncode(mergedYaml)) as YamlMap,
    directory.path,
    workspaceInfo.workspaceRoot?.path,
  );

  return configData;
}

void _writeWorkspaceToPubspec(File pubspecFile, List<String> workspace) {
  final content = pubspecFile.readAsStringSync();
  final editor = YamlEditor(content);
  editor.update(['workspace'], workspace);
  pubspecFile.writeAsStringSync(editor.toString());
}
