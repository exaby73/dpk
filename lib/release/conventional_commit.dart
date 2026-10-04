import 'package:pub_semver/pub_semver.dart';

/// How much a release raises a version.
enum Bump {
  none,
  patch,
  minor,
  major;

  Bump max(Bump other) => index >= other.index ? this : other;
}

/// A commit message in the Conventional Commits format:
/// `type(scope)!: description`.
final class ConventionalCommit {
  const ConventionalCommit({
    required this.hash,
    required this.type,
    required this.description,
    this.scope,
    this.breaking = false,
  });

  static final _header = RegExp(r'^(\w+)(?:\(([^)]*)\))?(!)?:\s+(.+)$');

  /// Parses a commit, or returns `null` when its subject does not follow the
  /// format.
  static ConventionalCommit? parse(String hash, String subject, String body) {
    final match = _header.firstMatch(subject.trim());
    if (match == null) {
      return null;
    }
    return ConventionalCommit(
      hash: hash,
      type: match.group(1)!.toLowerCase(),
      scope: match.group(2),
      breaking:
          match.group(3) != null ||
          RegExp(r'^BREAKING[ -]CHANGE:', multiLine: true).hasMatch(body),
      description: match.group(4)!.trim(),
    );
  }

  final String hash;
  final String type;
  final String? scope;
  final bool breaking;
  final String description;

  /// The bump this commit asks for: breaking changes are major, features
  /// minor, and fixes, performance changes, and reverts patch.
  Bump get bump {
    if (breaking) {
      return Bump.major;
    }
    return switch (type) {
      'feat' => Bump.minor,
      'fix' || 'perf' || 'revert' => Bump.patch,
      _ => Bump.none,
    };
  }

  /// Whether the commit belongs in a changelog.
  bool get isNotable =>
      breaking ||
      const {
        'feat',
        'fix',
        'perf',
        'revert',
        'refactor',
        'docs',
      }.contains(type);

  /// The changelog line, such as `- Feat: Add dpk exec`.
  String get changelogLine {
    final label = '${type[0].toUpperCase()}${type.substring(1)}';
    final text = description[0].toUpperCase() + description.substring(1);
    return '- ${breaking ? '[BREAKING] ' : ''}$label: $text';
  }
}

/// The version after applying [bump] to [version].
///
/// Below 1.0.0, Dart treats a minor release as breaking, so a breaking change
/// raises the minor version and a feature raises the patch version.
///
/// With [prerelease], the result is a pre-release such as `1.2.0-beta.0`, or
/// the next number of an existing pre-release with the same name. With
/// [graduate], a pre-release becomes its release version.
Version nextVersion(
  Version version,
  Bump bump, {
  String? prerelease,
  bool graduate = false,
}) {
  if (graduate && version.isPreRelease) {
    return Version(version.major, version.minor, version.patch);
  }

  if (prerelease != null && version.isPreRelease) {
    final parts = version.preRelease;
    if (parts.length == 2 && parts[0] == prerelease && parts[1] is int) {
      return Version(
        version.major,
        version.minor,
        version.patch,
        pre: '$prerelease.${(parts[1] as int) + 1}',
      );
    }
  }

  final base = version.isPreRelease
      ? Version(version.major, version.minor, version.patch)
      : _bumped(version, bump);
  if (prerelease == null) {
    return base;
  }
  return Version(base.major, base.minor, base.patch, pre: '$prerelease.0');
}

Version _bumped(Version version, Bump bump) {
  final effective = version.major == 0
      ? switch (bump) {
          Bump.major => Bump.minor,
          Bump.minor => Bump.patch,
          _ => bump,
        }
      : bump;
  return switch (effective) {
    Bump.major => version.nextMajor,
    Bump.minor => version.nextMinor,
    Bump.patch => version.nextPatch,
    Bump.none => version,
  };
}
