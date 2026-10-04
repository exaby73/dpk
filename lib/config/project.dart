import 'dart:io';

import 'package:dpk/config/config_reader.dart';
import 'package:dpk/config/dpk_config.dart';
import 'package:dpk/constants/pubspec.dart';
import 'package:dpk/core/constants.dart';
import 'package:dpk/workspace/workspace.dart';
import 'package:path/path.dart' as p;

/// A dpk project could not be loaded.
final class ProjectException implements Exception {
  ProjectException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The workspace and config that commands work with.
final class Project {
  Project({
    required this.workspace,
    required this.configPath,
    required this.config,
    required this.scripts,
    required this.warnings,
    this.cacheDirectoryOverride,
  });

  /// Finds the project that contains [start].
  ///
  /// The config is the `dpk.yaml` at the workspace root. When the workspace
  /// root has none, a standalone `dpk.yaml` in the current package is used.
  /// The current package's own `dpk.yaml` can add or override scripts.
  static Project load(String start, {String? cacheDirectoryOverride}) {
    if (!Directory(start).existsSync()) {
      throw ProjectException('Directory "$start" does not exist.');
    }

    final workspace = Workspace.discover(start);
    if (workspace == null) {
      throw ProjectException(
        'No pubspec.yaml found in ${displayPath(canonicalPath(start))} or any '
        'parent directory.',
      );
    }

    final rootConfig = p.join(workspace.root.path, kConfigFileName);
    final currentConfig = p.join(workspace.current.path, kConfigFileName);
    final rootHasConfig = File(rootConfig).existsSync();
    final configPath = rootHasConfig
        ? rootConfig
        : (File(currentConfig).existsSync() ? currentConfig : null);
    if (configPath == null) {
      throw ProjectException(
        'No $kConfigFileName found in ${displayPath(workspace.root.path)}. '
        'Run "dpk init" to create one.',
      );
    }

    final displayConfig = displayPath(configPath);
    final reader = ConfigReader(
      loadConfigMap(File(configPath).readAsStringSync(), file: displayConfig),
      file: displayConfig,
    );
    _checkVersion(reader);
    final config = DpkConfig.parse(reader);

    final scripts = {...config.scripts};
    final warnings = [...config.warnings];
    if (rootHasConfig &&
        workspace.current != workspace.root &&
        File(currentConfig).existsSync()) {
      final displayPackageConfig = displayPath(currentConfig);
      final packageReader = ConfigReader(
        loadConfigMap(
          File(currentConfig).readAsStringSync(),
          file: displayPackageConfig,
        ),
        file: displayPackageConfig,
      );
      if (packageReader.has('version')) {
        _checkVersion(packageReader);
      }
      final package = parsePackageConfig(
        packageReader,
        rootConfigPath: displayConfig,
      );
      scripts.addAll(package.scripts);
      warnings.addAll(package.warnings);
    }

    Script.checkReferences(scripts, file: displayConfig);

    return Project(
      workspace: workspace,
      configPath: configPath,
      config: config,
      scripts: scripts,
      warnings: warnings,
      cacheDirectoryOverride: cacheDirectoryOverride,
    );
  }

  static void _checkVersion(ConfigReader reader) {
    final constraint = DpkConfig.parseVersion(reader);
    if (!constraint.allows(dpkVersion)) {
      throw ProjectException(
        '${reader.file} requires dpk $constraint, but dpk ${pubspec.version} '
        'is installed. Update dpk with "dart install dpk", or change '
        '"version" in ${reader.file}.',
      );
    }
  }

  final Workspace workspace;

  /// Absolute path of the `dpk.yaml` that configures the project.
  final String configPath;
  final DpkConfig config;

  /// The root config's scripts, overridden by the current package's
  /// `dpk.yaml` scripts.
  final Map<String, Script> scripts;
  final List<ConfigWarning> warnings;
  final String? cacheDirectoryOverride;

  /// The directory that holds [configPath].
  String get rootPath => p.dirname(configPath);

  bool get isProjectMode => config.mode == DpkMode.project;

  /// Absolute path of the project cache.
  String get cacheDirectory => p.normalize(
    p.join(
      rootPath,
      cacheDirectoryOverride ?? config.cacheDir ?? 'pub_packages',
    ),
  );

  /// Absolute path of the patch directory.
  String get patchDirectory => p.normalize(p.join(rootPath, config.patchDir));

  /// Environment variables for `dart pub` and for scripts, so pub uses the
  /// project cache in project mode.
  Map<String, String> get pubEnvironment => {
    if (isProjectMode) 'PUB_CACHE': cacheDirectory,
  };
}
