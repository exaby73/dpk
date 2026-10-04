import 'dart:io';

import 'package:dpk/catalog/pubspec_updates.dart';
import 'package:dpk/commands/dpk_command.dart';
import 'package:dpk/config/config_reader.dart';
import 'package:dpk/config/project.dart';
import 'package:dpk/constants/pubspec.dart';
import 'package:dpk/core/shell.dart';
import 'package:dpk/patching/project_cache.dart';
import 'package:path/path.dart' as p;

enum _Status { ok, warning, problem }

final class DoctorCommand extends DpkCommand {
  DoctorCommand(super.context);

  @override
  String get name => 'doctor';

  @override
  String get description =>
      'Check the dpk setup of this project and report problems.';

  @override
  String get category => CommandCategory.setup;

  var _problems = 0;

  @override
  Future<int> run() async {
    _section('dpk');
    _report(_Status.ok, 'dpk ${pubspec.version}');
    _report(_Status.ok, 'Dart ${Platform.version.split(' ').first}');
    _report(_Status.ok, 'Scripts run with ${shellCommand('').executable}');
    await _checkGit();

    _section('Project');
    final Project project;
    try {
      project = Project.load(
        context.targetDirectory,
        cacheDirectoryOverride: context.invocation.cacheDirectory,
      );
    } on Exception catch (e) {
      _report(_Status.problem, '$e');
      return _finish();
    }

    final workspace = project.workspace;
    _report(_Status.ok, 'Config: ${displayPath(project.configPath)}');
    _report(
      _Status.ok,
      workspace.isWorkspace
          ? 'Workspace root ${workspace.root.name} with '
                '${workspace.packages.length} workspace packages'
          : 'Standalone package ${workspace.root.name}',
    );
    if (workspace.current != workspace.root) {
      _report(_Status.ok, 'Current package: ${workspace.current.name}');
    }
    _report(
      _Status.ok,
      '${project.scripts.length} scripts, mode: ${project.config.mode.name}',
    );
    for (final warning in project.warnings) {
      _report(_Status.warning, warning.toString());
    }

    final stale = [
      for (final update in planPubspecUpdates(project))
        if (update.changed) displayPath(update.path),
    ];
    if (stale.isEmpty) {
      _report(_Status.ok, 'Pubspecs match the catalog and sorting rules');
    } else {
      _report(
        _Status.warning,
        'dpk get would update ${stale.join(', ')}. Run "dpk get".',
      );
    }

    final lockfile = File(p.join(workspace.root.path, 'pubspec.lock'));
    if (!lockfile.existsSync()) {
      _report(_Status.warning, 'No pubspec.lock yet. Run "dpk get".');
    }

    if (project.isProjectMode) {
      await _checkProjectMode(project);
    }
    return _finish();
  }

  Future<void> _checkGit() async {
    try {
      final result = await context.processRunner.run('git', ['--version']);
      _report(_Status.ok, (result.stdout as String).trim());
    } on ProcessException {
      _report(_Status.warning, 'git is not on PATH. Patching needs git.');
    }
  }

  Future<void> _checkProjectMode(Project project) async {
    _section('Project cache');
    final root = project.rootPath;
    final cache = ProjectCache.forProject(project, context);
    if (!cache.exists) {
      _report(
        _Status.warning,
        'The project cache ${displayPath(project.cacheDirectory)} is empty. '
        'Run "dpk get".',
      );
    } else if (!cache.hasBaseline) {
      _report(
        _Status.warning,
        'The project cache has no baseline. Run "dpk get" to record it.',
      );
    } else {
      _report(
        _Status.ok,
        'Project cache: ${displayPath(project.cacheDirectory)}',
      );
    }

    final cacheName = p.relative(project.cacheDirectory, from: root);
    final gitignore = File(p.join(root, '.gitignore'));
    if (!gitignore.existsSync() ||
        !gitignore.readAsLinesSync().any(
          (l) => l.trim().startsWith(cacheName),
        )) {
      _report(
        _Status.warning,
        '$cacheName/ is not in .gitignore, so git sees every downloaded '
        'package.',
      );
    }
    final options = File(p.join(root, 'analysis_options.yaml'));
    if (!options.existsSync() ||
        !options.readAsStringSync().contains('$cacheName/**')) {
      _report(
        _Status.warning,
        '$cacheName/** is not excluded in analysis_options.yaml, so the '
        'analyzer reads every downloaded package.',
      );
    }

    if (!cache.hasBaseline) {
      return;
    }
    for (final patch in cache.patches()) {
      final state = await cache.stateOf(patch);
      final status = switch (state) {
        PatchState.applied || PatchState.notApplied => _Status.ok,
        _ => _Status.problem,
      };
      _report(status, '${patch.relativePath}: ${state.name}');
    }
  }

  void _section(String title) => console.info('\n${console.bold(title)}');

  void _report(_Status status, String message) {
    final mark = switch (status) {
      _Status.ok => console.green('✓'),
      _Status.warning => console.yellow('!'),
      _Status.problem => console.red('✗'),
    };
    if (status == _Status.problem) {
      _problems++;
    }
    console.info('  $mark $message');
  }

  int _finish() {
    console.info(
      _problems == 0
          ? '\nNo problems found.'
          : '\n$_problems problem${_problems == 1 ? '' : 's'} found.',
    );
    return _problems == 0 ? 0 : 1;
  }
}
