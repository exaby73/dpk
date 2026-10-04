import 'package:dpk/release/conventional_commit.dart';
import 'package:dpk/workspace/workspace.dart';
import 'package:pub_semver/pub_semver.dart';

/// A new version for one package.
final class PackageRelease {
  PackageRelease({
    required this.package,
    required this.from,
    required this.to,
    required this.commits,
  });

  final WorkspacePackage package;
  final Version from;
  final Version to;

  /// The commits since the last release that touch the package.
  final List<ConventionalCommit> commits;

  /// Dependency constraints to raise, by dependency name.
  final Map<String, String> constraintUpdates = {};

  /// The changelog entry for this release.
  String changelogEntry() {
    final lines = [
      for (final commit in commits.where((c) => c.breaking))
        commit.changelogLine,
      for (final commit in commits.where((c) => !c.breaking && c.isNotable))
        commit.changelogLine,
      for (final MapEntry(key: name, value: constraint)
          in constraintUpdates.entries)
        '- Chore: Update $name to $constraint',
    ];
    if (lines.isEmpty) {
      lines.add('- Chore: Release without notable changes');
    }
    return '## $to\n\n${lines.join('\n')}\n';
  }
}

/// Plans new versions from the commits that touch each package.
///
/// - [commits] holds each package's commits since its last release.
/// - [constraints] holds each package's version constraints on other
///   workspace packages, as written in its pubspec.
/// - With [sharedVersion], every package gets one version, raised by the
///   largest bump any package needs (the catalog `version`).
/// - A package whose constraint on a released workspace package no longer
///   allows the new version gets the constraint raised and a patch release.
/// - [forceBump] replaces the bump from commits for every package.
List<PackageRelease> planRelease({
  required List<WorkspacePackage> packages,
  required Map<String, List<ConventionalCommit>> commits,
  Map<String, Map<String, String>> constraints = const {},
  Version? sharedVersion,
  Bump? forceBump,
  String? prerelease,
  bool graduate = false,
}) {
  Bump bumpOf(WorkspacePackage package) =>
      forceBump ??
      (commits[package.name] ?? const [])
          .map((commit) => commit.bump)
          .fold(Bump.none, (a, b) => a.max(b));

  final versioned = [
    for (final package in packages)
      if (package.version != null) package,
  ];

  if (sharedVersion != null) {
    final bump = versioned.map(bumpOf).fold(Bump.none, (a, b) => a.max(b));
    if (bump == Bump.none && !graduate && prerelease == null) {
      return const [];
    }
    final to = nextVersion(
      sharedVersion,
      bump == Bump.none ? Bump.patch : bump,
      prerelease: prerelease,
      graduate: graduate,
    );
    final releases = [
      for (final package in versioned)
        PackageRelease(
          package: package,
          from: Version.parse(package.version!),
          to: to,
          commits: commits[package.name] ?? const [],
        ),
    ];
    _raiseConstraints(releases, releases, constraints);
    return releases;
  }

  final releases = <String, PackageRelease>{};
  for (final package in versioned) {
    final bump = bumpOf(package);
    if (bump == Bump.none && !(graduate && _isPre(package))) {
      continue;
    }
    final from = Version.parse(package.version!);
    releases[package.name] = PackageRelease(
      package: package,
      from: from,
      to: nextVersion(from, bump, prerelease: prerelease, graduate: graduate),
      commits: commits[package.name] ?? const [],
    );
  }

  var changed = true;
  while (changed) {
    changed = false;
    for (final package in versioned) {
      final current = releases[package.name];
      final needed = _constraintUpdates(
        package,
        releases.values.toList(),
        constraints,
      );
      final missing = {
        for (final MapEntry(:key, :value) in needed.entries)
          if (current?.constraintUpdates[key] != value) key: value,
      };
      if (missing.isEmpty) {
        continue;
      }
      changed = true;
      final release =
          current ??
          (releases[package.name] = PackageRelease(
            package: package,
            from: Version.parse(package.version!),
            to: nextVersion(
              Version.parse(package.version!),
              Bump.patch,
              prerelease: prerelease,
            ),
            commits: commits[package.name] ?? const [],
          ));
      release.constraintUpdates.addAll(missing);
    }
  }

  return [
    for (final package in versioned)
      if (releases[package.name] case final release?) release,
  ];
}

bool _isPre(WorkspacePackage package) =>
    Version.parse(package.version!).isPreRelease;

/// The constraints of [package] that no longer allow a released version.
Map<String, String> _constraintUpdates(
  WorkspacePackage package,
  List<PackageRelease> releases,
  Map<String, Map<String, String>> constraints,
) {
  final own = constraints[package.name] ?? const {};
  return {
    for (final release in releases)
      if (own[release.package.name] case final constraint?)
        if (_excludes(constraint, release.to))
          release.package.name: '^${release.to}',
  };
}

void _raiseConstraints(
  List<PackageRelease> targets,
  List<PackageRelease> releases,
  Map<String, Map<String, String>> constraints,
) {
  for (final target in targets) {
    target.constraintUpdates.addAll(
      _constraintUpdates(target.package, releases, constraints),
    );
  }
}

bool _excludes(String constraint, Version version) {
  try {
    return !VersionConstraint.parse(constraint).allows(version);
  } on FormatException {
    return false;
  }
}

/// [existing] changelog text with [entry] added as the newest release. The
/// entry goes after a leading `# ...` title when there is one.
String prependChangelog(String? existing, String entry) {
  if (existing == null || existing.trim().isEmpty) {
    return entry;
  }
  final lines = existing.split('\n');
  if (lines.first.startsWith('# ')) {
    final rest = lines.skip(1).join('\n').trimLeft();
    return '${lines.first}\n\n$entry\n$rest';
  }
  return '$entry\n$existing';
}
