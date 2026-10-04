import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dpk/catalog/catalog_application.dart';
import 'package:dpk/config/project.dart';
import 'package:dpk/core/errors.dart';
import 'package:dpk/utils/pubspec_sorter.dart';
import 'package:dpk/workspace/workspace.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// A planned change to one pubspec.
final class PubspecUpdate {
  const PubspecUpdate({
    required this.path,
    required this.before,
    required this.after,
  });

  /// Absolute path of the `pubspec.yaml`.
  final String path;
  final String before;
  final String after;

  bool get changed => before != after;
}

/// Plans the pubspec changes `dpk get` makes, without writing anything:
///
/// - the root pubspec's `workspace` list, from the `dpk.yaml` `workspace`
///   globs;
/// - the catalog, for the root and every workspace package;
/// - sorting, when `sort_pubspec` is on.
///
/// Returns one update per pubspec that dpk manages, changed or not.
List<PubspecUpdate> planPubspecUpdates(Project project) {
  final workspace = project.workspace;
  final config = project.config;
  final updates = <PubspecUpdate>[];

  String read(String directory) {
    final file = File(p.join(directory, 'pubspec.yaml'));
    if (!file.existsSync()) {
      throw DpkException('No pubspec.yaml in $directory.');
    }
    return file.readAsStringSync();
  }

  String finish(String content) =>
      config.sortPubspec ? sortPubspec(content) : content;

  final rootBefore = read(workspace.root.path);
  var root = rootBefore;
  final globs = config.workspace;
  if (globs != null) {
    root = _withWorkspaceList(
      root,
      workspaceGlobMembers(workspace.root.path, globs),
    );
  }
  final catalog = config.catalog;
  if (catalog != null) {
    root = applyCatalog(
      root,
      catalog: catalog,
      role: PubspecRole.root,
      values: TemplateValues(
        packagePath: '.',
        packageName: workspace.root.name,
        packageVersion: catalog.version ?? workspace.root.version,
      ),
    );
  }
  updates.add(
    PubspecUpdate(
      path: p.join(workspace.root.path, 'pubspec.yaml'),
      before: rootBefore,
      after: finish(root),
    ),
  );

  for (final package in _members(workspace, globs)) {
    final before = read(package.path);
    var after = before;
    if (catalog != null) {
      after = applyCatalog(
        after,
        catalog: catalog,
        role: PubspecRole.package,
        values: TemplateValues(
          packagePath: package.relativePath,
          packageName: package.name,
          packageVersion: catalog.version ?? package.version,
        ),
      );
    }
    updates.add(
      PubspecUpdate(
        path: p.join(package.path, 'pubspec.yaml'),
        before: before,
        after: finish(after),
      ),
    );
  }
  return updates;
}

/// The workspace packages, including those the `dpk.yaml` globs add that the
/// root pubspec does not list yet.
List<WorkspacePackage> _members(Workspace workspace, List<String>? globs) {
  final members = [...workspace.packages];
  if (globs == null) {
    return members;
  }
  for (final relative in workspaceGlobMembers(workspace.root.path, globs)) {
    final path = p.normalize(p.join(workspace.root.path, relative));
    if (members.none((member) => member.path == path)) {
      final package = WorkspacePackage.read(path, root: workspace.root.path);
      if (package != null) {
        members.add(package);
      }
    }
  }
  return members;
}

/// The member paths, relative to [root] with `/` separators, that [globs]
/// match: directories with a pubspec that has `resolution: workspace`.
List<String> workspaceGlobMembers(String root, List<String> globs) {
  final canonicalRoot = canonicalPath(root);
  final members = <String>{
    for (final pattern in globs)
      for (final path in Workspace.expandPattern(pattern, canonicalRoot))
        if (WorkspacePackage.read(
              path,
              root: canonicalRoot,
            )?.isWorkspaceMember ??
            false)
          toPosixPath(p.relative(path, from: canonicalRoot)),
  };
  return members.toList()..sort();
}

String _withWorkspaceList(String pubspec, List<String> members) {
  if (members.isEmpty) {
    return pubspec;
  }
  final document = loadYaml(pubspec);
  final current = document is YamlMap ? document['workspace'] : null;
  if (current is YamlList &&
      const ListEquality<Object?>().equals(current.toList(), members)) {
    return pubspec;
  }
  final usesCrlf = pubspec.contains('\r\n');
  final editor = YamlEditor(
    usesCrlf ? pubspec.replaceAll('\r\n', '\n') : pubspec,
  )..update(['workspace'], members);
  final result = editor.toString();
  return usesCrlf ? result.replaceAll('\n', '\r\n') : result;
}

/// Writes every changed update. Each file is written to a temporary file
/// first and then renamed, so an error never leaves a half-written pubspec.
void writePubspecUpdates(Iterable<PubspecUpdate> updates) {
  final changed = updates.where((update) => update.changed).toList();
  final temporary = <String, File>{};
  try {
    for (final update in changed) {
      temporary[update.path] = File('${update.path}.dpk-tmp')
        ..writeAsStringSync(update.after);
    }
    for (final MapEntry(key: path, value: file) in temporary.entries) {
      file.renameSync(path);
    }
  } finally {
    for (final file in temporary.values) {
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }
}
