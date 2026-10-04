import 'dart:io';

import 'package:dpk/config/project.dart';
import 'package:dpk/core/console.dart';
import 'package:dpk/core/context.dart';
import 'package:dpk/core/errors.dart';
import 'package:dpk/patching/git.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Whether a patch applies to the packages the lockfile uses.
enum PatchState {
  /// The project cache already contains the patch's changes.
  applied,

  /// The patch applies cleanly but has not been applied yet.
  notApplied,

  /// The lockfile uses a different version or commit of the package.
  stale,

  /// The package is not in the project cache.
  missing,

  /// The package has edits that conflict with the patch.
  conflict,
}

/// A patch file in the patch directory.
final class PatchFile {
  PatchFile({required this.file, required this.isGit});

  final File file;

  /// Whether the patch is for a git dependency, stored under `git/`.
  final bool isGit;

  /// The package folder name in the cache, such as `http-1.2.0` or
  /// `luthor-<commit>`.
  String get folder => p.basenameWithoutExtension(file.path);

  String get packageName => _splitFolder(folder).name;

  /// The version for a hosted package, or the commit for a git package.
  String get versionOrRef => _splitFolder(folder).version;

  String get relativePath => '${isGit ? 'git' : 'hosted'}/${folder}.patch';
}

/// The project cache and its patches.
///
/// dpk keeps a git baseline of the cache's `hosted/` folder, recorded right
/// after pub downloads packages. Edits to a package show up as differences
/// from that baseline, and `dpk patch generate` saves them as patch files.
/// Git dependencies are their own git checkouts, so their baseline is the
/// checked-out commit.
final class ProjectCache {
  ProjectCache({
    required this.cachePath,
    required this.patchPath,
    required this.lockfilePath,
    required this.git,
    required this.console,
  });

  factory ProjectCache.forProject(Project project, DpkContext context) =>
      ProjectCache(
        cachePath: project.cacheDirectory,
        patchPath: project.patchDirectory,
        lockfilePath: p.join(project.workspace.root.path, 'pubspec.lock'),
        git: Git(context.processRunner),
        console: context.console,
      );

  final String cachePath;
  final String patchPath;
  final String lockfilePath;
  final Git git;
  final Console console;

  static const _baselineMessage = 'dpk baseline';

  bool get exists =>
      Directory(p.join(cachePath, 'hosted')).existsSync() ||
      Directory(p.join(cachePath, 'git')).existsSync();

  bool get hasBaseline => Directory(p.join(cachePath, '.git')).existsSync();

  /// Brings the baseline up to date and applies every patch. Run after pub
  /// changes the resolved packages.
  ///
  /// Throws a [DpkException] when a patch is stale or conflicts with edits.
  Future<int> sync() async {
    if (!exists) {
      return 0;
    }
    await updateBaseline();
    final applied = await apply();
    if (applied > 0) {
      console.step('> Applied $applied patch${applied == 1 ? '' : 'es'}.');
    }
    return 0;
  }

  /// Creates the baseline when there is none, and adds packages that pub
  /// downloaded since the last update. With [rebuild], discards every edit
  /// in the cache and records a fresh baseline.
  Future<void> updateBaseline({bool rebuild = false}) async {
    if (!exists) {
      throw DpkException(
        'The project cache ${_display(cachePath)} is empty. Run "dpk get" '
        'first.',
      );
    }

    if (rebuild && hasBaseline) {
      await git(['checkout', '--', '.'], directory: cachePath);
      await git(['clean', '-fdq', '--', 'hosted'], directory: cachePath);
      for (final checkout in _gitCheckouts()) {
        await git(['checkout', '--', '.'], directory: checkout);
        await git(['clean', '-fdq'], directory: checkout);
      }
      await Directory(p.join(cachePath, '.git')).delete(recursive: true);
    }

    if (!hasBaseline) {
      await git(['init', '--quiet'], directory: cachePath);
      File(p.join(cachePath, '.git', 'info', 'exclude'))
        ..createSync(recursive: true)
        ..writeAsStringSync('/*\n!/hosted/\n');
      await git(['add', '--all', '--', 'hosted'], directory: cachePath);
      await git.commit(_baselineMessage, directory: cachePath);
      return;
    }

    final newPackages = await _newPackageFolders();
    if (newPackages.isEmpty) {
      return;
    }
    await git(['add', '--all', '--', ...newPackages], directory: cachePath);
    await git.commit(_baselineMessage, directory: cachePath);
  }

  /// Untracked folders under `hosted/` that pub downloaded as a whole: a new
  /// package version, or a new hosted server.
  Future<List<String>> _newPackageFolders() async {
    final output = await git.output([
      'ls-files',
      '--others',
      '--exclude-standard',
      '--directory',
      '-z',
      '--',
      'hosted',
    ], directory: cachePath);
    return [
      for (final entry in output.split('\x00'))
        if (entry.endsWith('/') && p.posix.split(entry).length <= 3) entry,
    ];
  }

  List<String> _gitCheckouts() {
    final gitDirectory = Directory(p.join(cachePath, 'git'));
    if (!gitDirectory.existsSync()) {
      return const [];
    }
    return [
      for (final entity in gitDirectory.listSync())
        if (entity is Directory &&
            p.basename(entity.path) != 'cache' &&
            Directory(p.join(entity.path, '.git')).existsSync())
          entity.path,
    ]..sort();
  }

  /// The patch files in the patch directory.
  List<PatchFile> patches() {
    List<PatchFile> under(String folder, {required bool isGit}) {
      final directory = Directory(p.join(patchPath, folder));
      if (!directory.existsSync()) {
        return const [];
      }
      return [
        for (final entity in directory.listSync())
          if (entity is File && entity.path.endsWith('.patch'))
            PatchFile(file: entity, isGit: isGit),
      ]..sort((a, b) => a.folder.compareTo(b.folder));
    }

    return [...under('hosted', isGit: false), ...under('git', isGit: true)];
  }

  /// The state of [patch] against the lockfile and the project cache.
  Future<PatchState> stateOf(PatchFile patch) async {
    final locked = _lockedVersions()[patch.packageName];
    if (locked != null && locked != patch.versionOrRef) {
      return PatchState.stale;
    }
    final directory = _applyDirectory(patch);
    if (directory == null) {
      return locked == null ? PatchState.stale : PatchState.missing;
    }
    final path = patch.file.absolute.path;
    if (await git.succeeds([
      'apply',
      '--reverse',
      '--check',
      path,
    ], directory: directory)) {
      return PatchState.applied;
    }
    if (await git.succeeds(['apply', '--check', path], directory: directory)) {
      return PatchState.notApplied;
    }
    return PatchState.conflict;
  }

  /// Applies every patch that is not applied yet, and returns how many were.
  ///
  /// With [force], a package whose edits conflict with its patch is reset to
  /// the baseline first. Throws a [DpkException] for stale or conflicting
  /// patches.
  Future<int> apply({bool force = false}) async {
    var count = 0;
    final problems = <String>[];
    for (final patch in patches()) {
      var state = await stateOf(patch);
      if (state == PatchState.conflict && force) {
        await _reset(patch);
        state = await stateOf(patch);
      }
      switch (state) {
        case PatchState.applied:
          continue;
        case PatchState.notApplied:
          await git([
            'apply',
            '--whitespace=nowarn',
            patch.file.absolute.path,
          ], directory: _applyDirectory(patch)!);
          count++;
        case PatchState.stale:
          problems.add(_staleMessage(patch));
        case PatchState.missing:
          problems.add(
            '${patch.relativePath}: ${patch.packageName} '
            '${patch.versionOrRef} is not in the project cache. Run "dpk get".',
          );
        case PatchState.conflict:
          problems.add(
            '${patch.relativePath} does not apply: ${patch.folder} has edits '
            'that are not in the patch. Run "dpk patch generate" to save '
            'them, or "dpk patch apply --force" to discard them.',
          );
      }
    }
    if (problems.isNotEmpty) {
      throw DpkException(problems.join('\n'));
    }
    return count;
  }

  String _staleMessage(PatchFile patch) {
    final locked = _lockedVersions()[patch.packageName];
    if (locked == null) {
      return '${patch.relativePath}: ${patch.packageName} is no longer a '
          'dependency. Run "dpk patch remove ${patch.packageName}".';
    }
    return '${patch.relativePath} was made for ${patch.packageName} '
        '${patch.versionOrRef}, but the lockfile uses $locked. Edit the new '
        'version in the project cache and run "dpk patch generate", or run '
        '"dpk patch remove ${patch.packageName}".';
  }

  /// Saves the edits in the project cache as patch files, and returns the
  /// patch paths written and removed, relative to the patch directory.
  ///
  /// Only `*.patch` files under `hosted/` and `git/` in the patch directory
  /// are written or removed. With [packages], only those packages' patches
  /// are touched.
  Future<({List<String> written, List<String> removed})> generate({
    List<String> packages = const [],
  }) async {
    if (!hasBaseline) {
      throw DpkException(
        'The project cache has no baseline yet. Run "dpk get" in project '
        'mode first.',
      );
    }
    await updateBaseline();

    final diffs = <String, String>{};
    diffs.addAll(await _hostedDiffs());
    for (final checkout in _gitCheckouts()) {
      final diff = await _diff(checkout, const ['.']);
      if (diff.isNotEmpty) {
        diffs['git/${p.basename(checkout)}.patch'] = diff;
      }
    }

    bool selected(String relativePath) {
      if (packages.isEmpty) {
        return true;
      }
      final folder = p.basenameWithoutExtension(relativePath);
      final name = _splitFolder(folder).name;
      return packages.contains(name) || packages.contains(folder);
    }

    final written = <String>[];
    for (final MapEntry(key: relativePath, value: diff) in diffs.entries) {
      if (!selected(relativePath)) {
        continue;
      }
      final file = File(p.join(patchPath, relativePath));
      if (file.existsSync() && file.readAsStringSync() == diff) {
        continue;
      }
      file
        ..createSync(recursive: true)
        ..writeAsStringSync(diff);
      written.add(relativePath);
    }

    final removed = <String>[];
    for (final patch in patches()) {
      if (selected(patch.relativePath) &&
          !diffs.containsKey(patch.relativePath)) {
        patch.file.deleteSync();
        removed.add(patch.relativePath);
      }
    }
    return (written: written, removed: removed);
  }

  /// Diffs for every edited hosted package, keyed by patch path.
  Future<Map<String, String>> _hostedDiffs() async {
    final changed = await _changedPaths(cachePath, const ['hosted']);
    final byPackage = <String, String>{};
    for (final path in changed) {
      final segments = p.posix.split(path);
      if (segments.length < 4) {
        continue;
      }
      byPackage[segments[2]] = p.posix.joinAll(segments.take(3));
    }

    final diffs = <String, String>{};
    for (final MapEntry(key: folder, value: packagePath) in byPackage.entries) {
      final diff = await _diff(cachePath, [packagePath]);
      if (diff.isNotEmpty) {
        diffs['hosted/$folder.patch'] = diff;
      }
    }
    return diffs;
  }

  /// Paths that differ from the baseline in [directory], including new and
  /// deleted files.
  Future<List<String>> _changedPaths(
    String directory,
    List<String> paths,
  ) async {
    final output = await _withStaged(directory, paths, () {
      return git.output([
        'diff',
        '--cached',
        '--name-only',
        '--no-renames',
        '-z',
        '--',
        ...paths,
      ], directory: directory);
    });
    return output.split('\x00').where((path) => path.isNotEmpty).toList();
  }

  /// The binary-safe diff of [paths] against the baseline, including new and
  /// deleted files, with `a/` and `b/` path prefixes whatever the user's git
  /// config says.
  Future<String> _diff(String directory, List<String> paths) =>
      _withStaged(directory, paths, () {
        return git.output([
          'diff',
          '--cached',
          '--binary',
          '--full-index',
          '--no-ext-diff',
          '--no-color',
          '--no-renames',
          '--src-prefix=a/',
          '--dst-prefix=b/',
          '--',
          ...paths,
        ], directory: directory);
      });

  /// Stages every change under [paths], runs [body], and unstages again.
  /// dpk owns the baseline repository, so its index is free to use.
  Future<T> _withStaged<T>(
    String directory,
    List<String> paths,
    Future<T> Function() body,
  ) async {
    await git(['add', '--all', '--', ...paths], directory: directory);
    try {
      return await body();
    } finally {
      await git(['reset', '--quiet', '--', ...paths], directory: directory);
    }
  }

  /// Deletes the patches for [package] (a name or a cache folder name) and
  /// resets that package in the project cache. Returns the removed paths.
  Future<List<String>> remove(String package) async {
    final matching = [
      for (final patch in patches())
        if (patch.packageName == package || patch.folder == package) patch,
    ];
    for (final patch in matching) {
      if (_applyDirectory(patch) != null) {
        await _reset(patch);
      }
      patch.file.deleteSync();
    }
    return [for (final patch in matching) patch.relativePath];
  }

  Future<void> _reset(PatchFile patch) async {
    final directory = _applyDirectory(patch)!;
    if (patch.isGit) {
      await git(['checkout', '--', '.'], directory: directory);
      await git(['clean', '-fdq'], directory: directory);
      return;
    }
    final packagePath = _hostedPackagePath(patch.folder)!;
    await git(['checkout', '--', packagePath], directory: cachePath);
    await git(['clean', '-fdq', '--', packagePath], directory: cachePath);
  }

  /// The directory to run `git apply` in for [patch], or `null` when the
  /// package is not in the cache.
  String? _applyDirectory(PatchFile patch) {
    if (patch.isGit) {
      final checkout = p.join(cachePath, 'git', patch.folder);
      return Directory(checkout).existsSync() ? checkout : null;
    }
    return _hostedPackagePath(patch.folder) == null ? null : cachePath;
  }

  /// The path of a hosted package folder relative to the cache, such as
  /// `hosted/pub.dev/http-1.2.0`.
  String? _hostedPackagePath(String folder) {
    final hosted = Directory(p.join(cachePath, 'hosted'));
    if (!hosted.existsSync()) {
      return null;
    }
    for (final server in hosted.listSync().whereType<Directory>()) {
      if (Directory(p.join(server.path, folder)).existsSync()) {
        return p.posix.join('hosted', p.basename(server.path), folder);
      }
    }
    return null;
  }

  /// The version of each hosted package, and the commit of each git
  /// package, in the lockfile.
  Map<String, String> _lockedVersions() {
    final file = File(lockfilePath);
    if (!file.existsSync()) {
      return const {};
    }
    final Object? yaml;
    try {
      yaml = loadYaml(file.readAsStringSync());
    } on YamlException {
      return const {};
    }
    final packages = yaml is YamlMap ? yaml['packages'] : null;
    if (packages is! YamlMap) {
      return const {};
    }
    final result = <String, String>{};
    for (final MapEntry(:key, :value) in packages.entries) {
      if (value is! YamlMap) {
        continue;
      }
      final description = value['description'];
      final resolvedRef = description is YamlMap
          ? description['resolved-ref']
          : null;
      if (value['source'] == 'git' && resolvedRef is String) {
        result[key as String] = resolvedRef;
      } else if (value['version'] is String) {
        result[key as String] = value['version'] as String;
      }
    }
    return result;
  }

  String _display(String path) => p.relative(path);
}

/// Splits a cache folder name such as `http-1.2.0` or `luthor-<commit>` into
/// the package name and the version or commit. Package names never contain
/// `-`, but versions can.
({String name, String version}) _splitFolder(String folder) {
  final index = folder.indexOf('-');
  if (index == -1) {
    return (name: folder, version: '');
  }
  return (
    name: folder.substring(0, index),
    version: folder.substring(index + 1),
  );
}
