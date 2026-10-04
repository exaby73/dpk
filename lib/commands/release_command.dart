import 'dart:convert';
import 'dart:io';

import 'package:dpk/commands/dpk_command.dart';
import 'package:dpk/config/config_reader.dart';
import 'package:dpk/config/project.dart';
import 'package:dpk/core/errors.dart';
import 'package:dpk/release/conventional_commit.dart';
import 'package:dpk/release/release_plan.dart';
import 'package:dpk/scripts/run_plan.dart';
import 'package:dpk/workspace/workspace.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

final class ReleaseCommand extends DpkCommand {
  ReleaseCommand(super.context) {
    addSubcommand(_ReleaseVersionCommand(context));
    addSubcommand(_ReleasePublishCommand(context));
  }

  @override
  String get name => 'release';

  @override
  String get description =>
      'Version packages from Conventional Commits, and publish them.';

  @override
  String get category => CommandCategory.release;
}

abstract base class _ReleaseSubcommand extends DpkCommand {
  _ReleaseSubcommand(super.context) {
    argParser
      ..addMultiOption(
        'filter',
        valueHelp: 'package',
        help: 'Only release workspace packages with this name or path glob.',
      )
      ..addFlag(
        'dry-run',
        abbr: 'n',
        negatable: false,
        help: 'Show what would happen without changing anything.',
      )
      ..addFlag(
        'yes',
        abbr: 'y',
        negatable: false,
        help: 'Do not ask for confirmation.',
      );
  }

  bool get dryRun => argResults!.flag('dry-run');

  /// The packages selected by `--filter`, or every package in the workspace
  /// (the workspace root included).
  List<WorkspacePackage> selectedPackages(Project project) {
    final filters = argResults!.multiOption('filter');
    if (filters.isEmpty) {
      return project.workspace.allPackages;
    }
    try {
      return planRun(workspace: project.workspace, filters: filters).packages;
    } on RunPlanException catch (e) {
      throw DpkException(e.message);
    }
  }

  /// Asks the user to confirm, unless `--yes` was given.
  bool confirm(String question) {
    if (argResults!.flag('yes')) {
      return true;
    }
    if (!stdin.hasTerminal) {
      throw DpkException(
        'Pass --yes to confirm when dpk is not running in a terminal.',
      );
    }
    console.err.write('$question [y/N] ');
    final answer = stdin.readLineSync()?.trim().toLowerCase();
    return answer == 'y' || answer == 'yes';
  }

  /// Runs git in the user's repository, with the user's own git config.
  Future<String> git(
    List<String> arguments, {
    required String directory,
    bool check = true,
  }) async {
    final ProcessResult result;
    try {
      result = await context.processRunner.run(
        'git',
        arguments,
        workingDirectory: directory,
        environment: context.environment,
      );
    } on ProcessException {
      throw DpkException('git is not installed or not on PATH.');
    }
    if (check && result.exitCode != 0) {
      throw DpkException(
        'git ${arguments.join(' ')} failed:\n'
        '${(result.stderr as String).trim()}',
      );
    }
    return result.stdout as String;
  }
}

final class _ReleaseVersionCommand extends _ReleaseSubcommand {
  _ReleaseVersionCommand(super.context) {
    argParser
      ..addOption(
        'bump',
        allowed: ['major', 'minor', 'patch'],
        help: 'Use this bump for every package instead of reading commits.',
      )
      ..addOption(
        'prerelease',
        valueHelp: 'name',
        help: 'Make pre-release versions, such as 1.2.0-beta.0.',
      )
      ..addFlag(
        'graduate',
        negatable: false,
        help: 'Turn pre-release versions into release versions.',
      )
      ..addFlag('commit', defaultsTo: true, help: 'Commit the changes.')
      ..addFlag('tag', defaultsTo: true, help: 'Tag each released version.')
      ..addFlag(
        'allow-dirty',
        negatable: false,
        help: 'Run even when the git working tree has changes.',
      );
  }

  @override
  String get name => 'version';

  @override
  String get description =>
      'Raise package versions and write changelogs from Conventional Commits.';

  @override
  String get usageFooter =>
      '\nfeat commits raise the minor version, fix and perf commits the patch '
      'version, and breaking changes (type! or BREAKING CHANGE:) the major '
      'version. Below 1.0.0, breaking changes raise the minor version and '
      'features the patch version. Workspace releases are tagged '
      '<package>-v<version>, standalone ones v<version>.';

  @override
  Future<int> run() async {
    final project = context.requireProject;
    final workspace = project.workspace;
    final root = workspace.root.path;
    await git(['rev-parse', '--show-toplevel'], directory: root);
    if (!dryRun && !argResults!.flag('allow-dirty')) {
      final status = await git(['status', '--porcelain'], directory: root);
      if (status.trim().isNotEmpty) {
        throw DpkException(
          'The git working tree has changes. Commit or stash them first, or '
          'pass --allow-dirty.',
        );
      }
    }

    final packages = selectedPackages(project);
    final commits = <String, List<ConventionalCommit>>{
      for (final package in packages)
        if (package.version != null)
          package.name: await _commitsSinceRelease(package, workspace),
    };
    final forced = argResults!.option('bump');
    final sharedVersion = project.config.catalog?.version;
    final releases = planRelease(
      packages: packages,
      commits: commits,
      constraints: _workspaceConstraints(workspace),
      sharedVersion: sharedVersion == null
          ? null
          : Version.parse(sharedVersion),
      forceBump: forced == null ? null : Bump.values.byName(forced),
      prerelease: argResults!.option('prerelease'),
      graduate: argResults!.flag('graduate'),
    );

    if (releases.isEmpty) {
      console.info(
        'Nothing to release: no feat, fix, perf, or breaking commits since the '
        'last release.',
      );
      return 0;
    }

    for (final release in releases) {
      console.info(
        '${console.bold(release.package.name)} ${release.from} -> '
        '${console.green('${release.to}')} '
        '${console.dim('(${release.commits.length} commits)')}',
      );
    }
    if (dryRun) {
      console.info('');
      for (final release in releases) {
        console.info('${release.package.relativePath}/CHANGELOG.md:');
        console.info(release.changelogEntry());
      }
      return 0;
    }
    if (!confirm('Release ${releases.length} package(s)?')) {
      return 1;
    }

    return context.withHooks('version', (stack) async {
      final changed = _apply(project, releases, sharedVersion != null);
      if (!argResults!.flag('commit')) {
        console.info('Updated ${changed.length} files. Nothing was committed.');
        return 0;
      }
      await git(['add', '--', ...changed], directory: root);
      final single = !workspace.isWorkspace;
      final subject = single
          ? 'chore: Release ${releases.single.to}'
          : 'chore: Release packages';
      final body = [
        for (final release in releases)
          '- ${release.package.name} ${release.to}',
      ].join('\n');
      await git([
        'commit',
        '-m',
        subject,
        if (!single) ...['-m', body],
      ], directory: root);
      if (argResults!.flag('tag')) {
        for (final release in releases) {
          final tag = _tag(release.package, release.to.toString(), workspace);
          await git(['tag', tag], directory: root);
          console.info('Tagged $tag');
        }
      }
      console.info('Push the release with "git push --follow-tags".');
      return 0;
    });
  }

  /// The commits since the package's last release tag that touch its files.
  Future<List<ConventionalCommit>> _commitsSinceRelease(
    WorkspacePackage package,
    Workspace workspace,
  ) async {
    final root = workspace.root.path;
    final tag = _tag(package, package.version!, workspace);
    final tagged = (await git(
      ['rev-parse', '--quiet', '--verify', 'refs/tags/$tag'],
      directory: root,
      check: false,
    )).trim().isNotEmpty;
    final pathspecs = [
      if (package.relativePath == '.') ...[
        '.',
        for (final member in workspace.packages)
          ':(exclude)${member.relativePath}',
      ] else
        package.relativePath,
    ];
    final log = await git([
      'log',
      '--format=%H%x1f%s%x1f%b%x1e',
      if (tagged) '$tag..HEAD',
      '--',
      ...pathspecs,
    ], directory: root);
    return [
      for (final record in log.split('\x1e'))
        if (record.trim().isNotEmpty)
          if (_parse(record.trim()) case final commit?) commit,
    ];
  }

  ConventionalCommit? _parse(String record) {
    final fields = record.split('\x1f');
    return ConventionalCommit.parse(
      fields[0],
      fields.length > 1 ? fields[1] : '',
      fields.length > 2 ? fields[2] : '',
    );
  }

  /// Each package's text constraints on other workspace packages.
  Map<String, Map<String, String>> _workspaceConstraints(Workspace workspace) {
    final names = {for (final package in workspace.allPackages) package.name};
    return {
      for (final package in workspace.allPackages)
        package.name: {
          for (final section in _sections(package).values)
            for (final MapEntry(:key, :value) in section.entries)
              if (names.contains(key) && value is String) key as String: value,
        },
    };
  }

  Map<String, YamlMap> _sections(WorkspacePackage package) {
    final yaml = loadYaml(
      File(p.join(package.path, 'pubspec.yaml')).readAsStringSync(),
    );
    if (yaml is! YamlMap) {
      return const {};
    }
    return {
      for (final section in ['dependencies', 'dev_dependencies'])
        if (yaml[section] case final YamlMap entries) section: entries,
    };
  }

  /// Writes the new versions, constraints, and changelogs, and returns the
  /// changed paths.
  List<String> _apply(
    Project project,
    List<PackageRelease> releases,
    bool shared,
  ) {
    final changed = <String>[];
    for (final release in releases) {
      final pubspecFile = File(p.join(release.package.path, 'pubspec.yaml'));
      final editor = YamlEditor(pubspecFile.readAsStringSync())
        ..update(['version'], release.to.toString());
      final sections = _sections(release.package);
      for (final MapEntry(key: name, value: constraint)
          in release.constraintUpdates.entries) {
        for (final MapEntry(key: section, value: entries) in sections.entries) {
          if (entries.containsKey(name)) {
            editor.update([section, name], constraint);
          }
        }
      }
      pubspecFile.writeAsStringSync(editor.toString());
      changed.add(pubspecFile.path);

      final changelog = File(p.join(release.package.path, 'CHANGELOG.md'));
      changelog.writeAsStringSync(
        prependChangelog(
          changelog.existsSync() ? changelog.readAsStringSync() : null,
          release.changelogEntry(),
        ),
      );
      changed.add(changelog.path);
    }

    if (shared) {
      final config = File(project.configPath);
      final editor = YamlEditor(config.readAsStringSync())
        ..update(['catalog', 'version'], releases.first.to.toString());
      config.writeAsStringSync(editor.toString());
      changed.add(config.path);
    }
    for (final path in changed) {
      console.step('> Updated ${displayPath(path)}');
    }
    return changed;
  }

  String _tag(WorkspacePackage package, String version, Workspace workspace) =>
      workspace.isWorkspace ? '${package.name}-v$version' : 'v$version';
}

final class _ReleasePublishCommand extends _ReleaseSubcommand {
  _ReleasePublishCommand(super.context);

  @override
  String get name => 'publish';

  @override
  String get description =>
      'Publish every package whose version is not on its pub server yet, '
      'dependencies first.';

  @override
  Future<int> run() async {
    final project = context.requireProject;
    final candidates = [
      for (final package in selectedPackages(project))
        if (package.isPublishable && package.version != null) package,
    ];
    if (candidates.isEmpty) {
      console.info(
        'No publishable packages. Packages with publish_to: none are skipped.',
      );
      return 0;
    }

    final pending = <WorkspacePackage>[];
    for (final package in _dependencyOrder(candidates)) {
      final published = await _publishedVersions(package);
      if (published.contains(package.version)) {
        console.info(
          '${package.name} ${package.version} ${console.dim('is already published')}',
        );
      } else {
        console.info(
          '${console.bold(package.name)} ${console.green(package.version!)} ${console.dim('will be published')}',
        );
        pending.add(package);
      }
    }
    if (pending.isEmpty) {
      console.info('Every package is already published.');
      return 0;
    }
    if (!dryRun && !confirm('Publish ${pending.length} package(s)?')) {
      return 1;
    }

    return context.withHooks('release', (stack) async {
      for (final package in pending) {
        final exitCode = await context.runDart(
          ['pub', 'publish', if (dryRun) '--dry-run' else '--force'],
          workingDirectory: package.path,
          environment: stack.toEnvironment(),
        );
        if (exitCode != 0) {
          console.error('Publishing ${package.name} failed. Stopped here.');
          return exitCode;
        }
      }
      return 0;
    });
  }

  /// Orders [packages] so each comes after the workspace packages it
  /// depends on.
  List<WorkspacePackage> _dependencyOrder(List<WorkspacePackage> packages) {
    final byName = {for (final package in packages) package.name: package};
    final ordered = <WorkspacePackage>[];
    final visiting = <String>{};
    void visit(WorkspacePackage package) {
      if (ordered.contains(package) || !visiting.add(package.name)) {
        return;
      }
      for (final dependency in package.dependencies) {
        if (byName[dependency] case final other?) {
          visit(other);
        }
      }
      ordered.add(package);
    }

    packages.forEach(visit);
    return ordered;
  }

  /// The versions of [package] on its pub server. Empty when the package has
  /// never been published.
  Future<Set<String>> _publishedVersions(WorkspacePackage package) async {
    final host =
        package.publishTo ??
        context.environment['PUB_HOSTED_URL'] ??
        'https://pub.dev';
    final uri = Uri.parse(
      '${host.endsWith('/') ? host.substring(0, host.length - 1) : host}'
      '/api/packages/${package.name}',
    );
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/vnd.pub.v2+json',
      );
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode == HttpStatus.notFound) {
        return const {};
      }
      if (response.statusCode != HttpStatus.ok) {
        throw DpkException(
          'Could not check ${package.name} on $host: HTTP ${response.statusCode}.',
        );
      }
      final json = jsonDecode(body) as Map<String, Object?>;
      return {
        for (final version
            in (json['versions'] as List? ?? const [])
                .cast<Map<String, Object?>>())
          version['version']! as String,
      };
    } on SocketException catch (e) {
      throw DpkException(
        'Could not reach $host to check ${package.name}: ${e.message}',
      );
    } finally {
      client.close();
    }
  }
}
