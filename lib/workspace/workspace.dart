import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// A package found on disk: the workspace root or a workspace package.
final class WorkspacePackage {
  const WorkspacePackage({
    required this.name,
    required this.path,
    required this.relativePath,
    this.version,
    this.publishTo,
    this.dependencies = const {},
    this.devDependencies = const {},
    this.isWorkspaceMember = false,
  });

  /// Reads the package in [directory], or returns `null` when it has no
  /// readable `pubspec.yaml`.
  static WorkspacePackage? read(String directory, {required String root}) {
    final pubspec = File(p.join(directory, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      return null;
    }

    final Object? yaml;
    try {
      yaml = loadYaml(pubspec.readAsStringSync(), sourceUrl: pubspec.uri);
    } on YamlException {
      return null;
    }
    if (yaml is! YamlMap) {
      return null;
    }

    Set<String> keysOf(Object? section) =>
        section is YamlMap ? {...section.keys.cast<String>()} : const {};

    final name = yaml['name'];
    final publishTo = yaml['publish_to'];
    return WorkspacePackage(
      name: name is String ? name : p.basename(directory),
      path: directory,
      relativePath: toPosixPath(p.relative(directory, from: root)),
      version: yaml['version']?.toString(),
      publishTo: publishTo is String ? publishTo : null,
      dependencies: keysOf(yaml['dependencies']),
      devDependencies: keysOf(yaml['dev_dependencies']),
      isWorkspaceMember: yaml['resolution'] == 'workspace',
    );
  }

  final String name;

  /// Absolute path of the package directory.
  final String path;

  /// Path relative to the workspace root, with `/` separators. `.` for the
  /// workspace root itself.
  final String relativePath;
  final String? version;
  final String? publishTo;
  final Set<String> dependencies;
  final Set<String> devDependencies;

  /// Whether the pubspec has `resolution: workspace`.
  final bool isWorkspaceMember;

  bool get isPublishable => publishTo != 'none';

  @override
  String toString() => '$name ($relativePath)';
}

/// The packages dpk works with, found from a starting directory.
final class Workspace {
  const Workspace({
    required this.root,
    required this.packages,
    required this.current,
  });

  /// The workspace root package. For a standalone package, the package
  /// itself.
  final WorkspacePackage root;

  /// The workspace packages, in the order of the root pubspec's `workspace`
  /// list. Empty for a standalone package.
  final List<WorkspacePackage> packages;

  /// The package that contains the starting directory.
  final WorkspacePackage current;

  bool get isWorkspace => packages.isNotEmpty;

  /// The workspace root followed by every workspace package.
  List<WorkspacePackage> get allPackages => [root, ...packages];

  /// The workspace package or root with the given [name].
  WorkspacePackage? packageNamed(String name) =>
      allPackages.where((package) => package.name == name).firstOrNull;

  /// Finds the workspace that contains [start].
  ///
  /// The current package is the nearest directory at or above [start] with a
  /// `pubspec.yaml`. The workspace root is the nearest directory at or above
  /// that package whose `pubspec.yaml` `workspace` list, or whose `dpk.yaml`
  /// `workspace` globs, include the package. A package that no workspace
  /// includes is its own root.
  ///
  /// Returns `null` when no directory at or above [start] has a
  /// `pubspec.yaml`.
  static Workspace? discover(String start) {
    final startPath = canonicalPath(start);
    final currentPath = _nearestPackageDirectory(startPath);
    if (currentPath == null) {
      return null;
    }

    for (final candidate in _selfAndAncestors(currentPath)) {
      final members = workspaceMemberPaths(candidate);
      if (members == null) {
        continue;
      }
      if (candidate != currentPath && !members.contains(currentPath)) {
        continue;
      }

      final root = WorkspacePackage.read(candidate, root: candidate)!;
      final packages = [
        for (final member in members)
          ?WorkspacePackage.read(member, root: candidate),
      ];
      final current = currentPath == candidate
          ? root
          : packages.firstWhere((package) => package.path == currentPath);
      return Workspace(root: root, packages: packages, current: current);
    }

    final package = WorkspacePackage.read(currentPath, root: currentPath);
    if (package == null) {
      return null;
    }
    return Workspace(root: package, packages: const [], current: package);
  }

  /// The absolute member directories that the `pubspec.yaml` in [directory]
  /// lists under `workspace`, plus the directories its `dpk.yaml`
  /// `workspace` globs match. Returns `null` when neither file declares a
  /// workspace.
  ///
  /// A `dpk.yaml` glob only matches directories whose `pubspec.yaml` has
  /// `resolution: workspace`, so a stray package or an example app is never
  /// pulled in by accident. Entries in `pubspec.yaml` are taken as written,
  /// because pub already treats them as members.
  static List<String>? workspaceMemberPaths(String directory) {
    final pubspecEntries = _stringList(
      _readYamlMap(p.join(directory, 'pubspec.yaml'))?['workspace'],
    );
    final dpkGlobs = _stringList(
      _readYamlMap(p.join(directory, 'dpk.yaml'))?['workspace'],
    );
    if (pubspecEntries == null && dpkGlobs == null) {
      return null;
    }

    final members = <String>[];
    void addMember(String path) {
      final normalized = p.normalize(path);
      if (!members.contains(normalized) && normalized != directory) {
        members.add(normalized);
      }
    }

    for (final entry in pubspecEntries ?? const <String>[]) {
      for (final path in expandPattern(entry, directory)) {
        if (File(p.join(path, 'pubspec.yaml')).existsSync()) {
          addMember(path);
        }
      }
    }
    for (final glob in dpkGlobs ?? const <String>[]) {
      for (final path in expandPattern(glob, directory)) {
        final package = WorkspacePackage.read(path, root: directory);
        if (package != null && package.isWorkspaceMember) {
          addMember(path);
        }
      }
    }
    return members;
  }

  /// Directories under [root] that [pattern] matches, as canonical paths
  /// sorted by path. A pattern without glob characters matches that
  /// directory if it exists. Glob matches inside hidden directories, `build`,
  /// and `pub_packages` are skipped.
  static List<String> expandPattern(String pattern, String root) {
    final cleaned = pattern.startsWith('./') ? pattern.substring(2) : pattern;
    if (!cleaned.contains(RegExp(r'[*?\[{]'))) {
      final path = p.join(root, cleaned);
      return Directory(path).existsSync() ? [canonicalPath(path)] : const [];
    }

    final matches = <String>[];
    for (final entity in Glob(
      cleaned,
    ).listSync(root: root, followLinks: false)) {
      if (entity is! Directory) {
        continue;
      }
      final relative = p.relative(entity.path, from: root);
      if (p.split(relative).any(_isIgnoredSegment)) {
        continue;
      }
      matches.add(canonicalPath(entity.path));
    }
    return matches..sort();
  }

  static bool _isIgnoredSegment(String segment) =>
      segment.startsWith('.') ||
      segment == 'build' ||
      segment == 'pub_packages';

  static String? _nearestPackageDirectory(String start) {
    for (final directory in _selfAndAncestors(start)) {
      if (File(p.join(directory, 'pubspec.yaml')).existsSync()) {
        return directory;
      }
    }
    return null;
  }

  static Iterable<String> _selfAndAncestors(String start) sync* {
    var current = start;
    while (true) {
      yield current;
      final parent = p.dirname(current);
      if (parent == current) {
        return;
      }
      current = parent;
    }
  }

  static YamlMap? _readYamlMap(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      return null;
    }
    try {
      final yaml = loadYaml(file.readAsStringSync());
      return yaml is YamlMap ? yaml : null;
    } on YamlException {
      return null;
    }
  }

  static List<String>? _stringList(Object? value) {
    if (value is! YamlList) {
      return null;
    }
    return value.whereType<String>().toList();
  }
}

/// [path] made absolute, normalized, and with symbolic links resolved when it
/// exists, so two spellings of one directory compare equal.
String canonicalPath(String path) {
  final absolute = p.normalize(p.absolute(path));
  final directory = Directory(absolute);
  if (directory.existsSync()) {
    return p.normalize(directory.resolveSymbolicLinksSync());
  }
  return absolute;
}

/// [path] with `/` separators, for paths written to YAML files.
String toPosixPath(String path) => p.split(path).join('/');
