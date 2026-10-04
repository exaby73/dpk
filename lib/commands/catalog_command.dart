import 'dart:convert';
import 'dart:io';

import 'package:dpk/commands/dpk_command.dart';
import 'package:dpk/commands/get_command.dart';
import 'package:dpk/config/config_reader.dart';
import 'package:dpk/config/project.dart';
import 'package:dpk/core/errors.dart';
import 'package:dpk/scripts/hook_lifecycle.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml_edit/yaml_edit.dart';

final class CatalogCommand extends DpkCommand {
  CatalogCommand(super.context) {
    addSubcommand(_CatalogOutdatedCommand(context));
    addSubcommand(_CatalogUpgradeCommand(context));
  }

  @override
  String get name => 'catalog';

  @override
  String get description => 'Check and upgrade the catalog dependencies.';

  @override
  String get category => CommandCategory.dependencies;
}

/// Versions of one package from `dart pub outdated --json`.
final class _Versions {
  const _Versions({
    this.current,
    this.upgradable,
    this.resolvable,
    this.latest,
  });

  final String? current;
  final String? upgradable;
  final String? resolvable;
  final String? latest;
}

abstract base class _CatalogSubcommand extends DpkCommand {
  _CatalogSubcommand(super.context);

  /// The catalog dependencies whose value is a version constraint.
  Map<String, String> catalogConstraints(Project project) {
    final dependencies = project.config.catalog?.dependencies;
    if (dependencies == null || dependencies.isEmpty) {
      throw DpkException(
        'There are no catalog dependencies in ${displayPath(project.configPath)}.',
      );
    }
    return {
      for (final MapEntry(:key, :value) in dependencies.entries)
        if (value is String) key: value,
    };
  }

  /// Runs `dart pub outdated --json` at the workspace root.
  Future<Map<String, _Versions>> outdated(Project project) async {
    final result = await context.processRunner.run(
      'dart',
      ['pub', 'outdated', '--json', '--show-all'],
      workingDirectory: project.workspace.root.path,
      environment: project.pubEnvironment,
    );
    if (result.exitCode != 0) {
      throw DpkException(
        'dart pub outdated failed. Run "dpk get" first.\n'
        '${(result.stderr as String).trim()}',
      );
    }
    final json = jsonDecode(result.stdout as String) as Map<String, Object?>;
    String? version(Object? entry) =>
        entry is Map<String, Object?> ? entry['version'] as String? : null;
    return {
      for (final package
          in (json['packages'] as List).cast<Map<String, Object?>>())
        package['package']! as String: _Versions(
          current: version(package['current']),
          upgradable: version(package['upgradable']),
          resolvable: version(package['resolvable']),
          latest: version(package['latest']),
        ),
    };
  }
}

final class _CatalogOutdatedCommand extends _CatalogSubcommand {
  _CatalogOutdatedCommand(super.context);

  @override
  String get name => 'outdated';

  @override
  String get description =>
      'Show catalog dependencies whose constraint excludes the latest version.';

  @override
  Future<int> run() async {
    final project = context.requireProject;
    final constraints = catalogConstraints(project);
    final versions = await outdated(project);

    final rows = <List<String>>[
      ['Package', 'Catalog', 'Current', 'Latest'],
    ];
    var behind = 0;
    for (final MapEntry(key: name, value: constraint) in constraints.entries) {
      final info = versions[name];
      final latest = info?.latest;
      final allowsLatest =
          latest != null &&
          VersionConstraint.parse(constraint).allows(Version.parse(latest));
      if (!allowsLatest) {
        behind++;
      }
      rows.add([
        name,
        constraint,
        info?.current ?? '-',
        latest == null ? '-' : (allowsLatest ? latest : console.yellow(latest)),
      ]);
    }
    _printTable(rows);
    console.info(
      behind == 0
          ? '\nEvery catalog constraint allows the latest version.'
          : '\n$behind catalog '
                '${behind == 1 ? 'constraint excludes' : 'constraints exclude'} '
                'the latest version. Run "dpk catalog upgrade --major-versions" '
                'to raise ${behind == 1 ? 'it' : 'them'}.',
    );
    return 0;
  }

  void _printTable(List<List<String>> rows) {
    final widths = [
      for (var column = 0; column < rows.first.length; column++)
        rows
            .map((row) => _visibleLength(row[column]))
            .reduce((a, b) => a > b ? a : b),
    ];
    for (final (index, row) in rows.indexed) {
      final cells = [
        for (final (column, cell) in row.indexed)
          cell + ' ' * (widths[column] - _visibleLength(cell)),
      ];
      final line = cells.join('  ').trimRight();
      console.info(index == 0 ? console.bold(line) : line);
    }
  }

  int _visibleLength(String text) =>
      text.replaceAll(RegExp('\x1b\\[[0-9;]*m'), '').length;
}

final class _CatalogUpgradeCommand extends _CatalogSubcommand {
  _CatalogUpgradeCommand(super.context) {
    argParser
      ..addFlag(
        'major-versions',
        negatable: false,
        help: 'Allow new major versions, which may break your code.',
      )
      ..addFlag(
        'dry-run',
        abbr: 'n',
        negatable: false,
        help: 'Show the new constraints without changing anything.',
      );
  }

  @override
  String get name => 'upgrade';

  @override
  String get description =>
      'Raise catalog constraints to the newest versions, then run dpk get.';

  @override
  String get invocation => 'dpk catalog upgrade [options] [package...]';

  @override
  bool get takesArguments => true;

  @override
  Future<int> run() async {
    final project = context.requireProject;
    final constraints = catalogConstraints(project);
    final only = argResults!.rest;
    for (final name in only) {
      if (!constraints.containsKey(name)) {
        throw DpkException(
          '"$name" is not a catalog dependency with a version.',
        );
      }
    }
    final majorVersions = argResults!.flag('major-versions');
    final versions = await outdated(project);

    final changes = <String, String>{};
    for (final MapEntry(key: name, value: constraint) in constraints.entries) {
      if (only.isNotEmpty && !only.contains(name)) {
        continue;
      }
      final info = versions[name];
      final target = majorVersions ? info?.resolvable : info?.upgradable;
      if (target == null) {
        continue;
      }
      final updated = _isExactVersion(constraint) ? target : '^$target';
      if (updated != constraint) {
        changes[name] = updated;
      }
    }

    if (changes.isEmpty) {
      console.info('The catalog constraints are already up to date.');
      return 0;
    }
    for (final MapEntry(key: name, value: updated) in changes.entries) {
      console.info('$name: ${constraints[name]} -> $updated');
    }
    if (argResults!.flag('dry-run')) {
      return 0;
    }

    final configFile = File(project.configPath);
    final editor = YamlEditor(configFile.readAsStringSync());
    for (final MapEntry(key: name, value: updated) in changes.entries) {
      editor.update(['catalog', 'dependencies', name], updated);
    }
    configFile.writeAsStringSync(editor.toString());
    console.step('> Updated ${displayPath(project.configPath)}');

    final reloaded = Project.load(
      project.workspace.current.path,
      cacheDirectoryOverride: project.cacheDirectoryOverride,
    );
    return context.withHooks(
      'get',
      (stack) => getDependencies(context, reloaded, stack: stack),
      order: HookOrder.beforeAfterTarget,
    );
  }

  bool _isExactVersion(String constraint) {
    try {
      Version.parse(constraint);
      return true;
    } on FormatException {
      return false;
    }
  }
}
