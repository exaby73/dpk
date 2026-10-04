import 'package:dpk/commands/dpk_command.dart';
import 'package:dpk/core/errors.dart';
import 'package:dpk/patching/project_cache.dart';

final class PatchCommand extends DpkCommand {
  PatchCommand(super.context) {
    addSubcommand(_PatchInitCommand(context));
    addSubcommand(_PatchGenerateCommand(context));
    addSubcommand(_PatchApplyCommand(context));
    addSubcommand(_PatchListCommand(context));
    addSubcommand(_PatchRemoveCommand(context));
  }

  @override
  String get name => 'patch';

  @override
  String get description =>
      'Save and apply your edits to dependencies. Needs mode: project.';

  @override
  String get category => CommandCategory.patching;
}

abstract base class _PatchSubcommand extends DpkCommand {
  _PatchSubcommand(super.context);

  ProjectCache get cache {
    final project = context.requireProject;
    if (!project.isProjectMode) {
      throw DpkException(
        'Patching needs a project cache. Add "mode: project" to '
        '${project.configPath} and run "dpk get".',
      );
    }
    return ProjectCache.forProject(project, context);
  }
}

final class _PatchInitCommand extends _PatchSubcommand {
  _PatchInitCommand(super.context) {
    argParser.addFlag(
      'force',
      negatable: false,
      help:
          'Discard every edit in the project cache and record a fresh '
          'baseline, then apply the patches again.',
    );
  }

  @override
  String get name => 'init';

  @override
  String get description =>
      'Record the project cache baseline. "dpk get" does this for you.';

  @override
  Future<int> run() async {
    final cache = this.cache;
    final force = argResults!.flag('force');
    final hadBaseline = cache.hasBaseline;
    await cache.updateBaseline(rebuild: force);
    if (force) {
      final applied = await cache.apply();
      console.info(
        'Recorded a fresh baseline and applied $applied '
        'patch${applied == 1 ? '' : 'es'}.',
      );
    } else {
      console.info(
        hadBaseline
            ? 'The baseline is up to date.'
            : 'Recorded the project cache baseline.',
      );
    }
    return 0;
  }
}

final class _PatchGenerateCommand extends _PatchSubcommand {
  _PatchGenerateCommand(super.context);

  @override
  String get name => 'generate';

  @override
  String get description =>
      'Save the edits in the project cache as patch files.';

  @override
  String get invocation => 'dpk patch generate [package...]';

  @override
  bool get takesArguments => true;

  @override
  Future<int> run() async {
    final cache = this.cache;
    final result = await cache.generate(packages: argResults!.rest);
    for (final path in result.written) {
      console.info('Wrote ${_patchPath(path)}');
    }
    for (final path in result.removed) {
      console.info('Removed ${_patchPath(path)} (no edits left)');
    }
    if (result.written.isEmpty && result.removed.isEmpty) {
      console.info('The patches already match the project cache.');
    }
    return 0;
  }

  String _patchPath(String relative) =>
      '${context.requireProject.config.patchDir}/$relative';
}

final class _PatchApplyCommand extends _PatchSubcommand {
  _PatchApplyCommand(super.context) {
    argParser.addFlag(
      'force',
      negatable: false,
      help:
          'Reset packages whose edits conflict with their patch before '
          'applying it.',
    );
  }

  @override
  String get name => 'apply';

  @override
  String get description =>
      'Apply the patches to the project cache. "dpk get" does this for you.';

  @override
  Future<int> run() async {
    final cache = this.cache;
    await cache.updateBaseline();
    final applied = await cache.apply(force: argResults!.flag('force'));
    console.info(
      applied == 0
          ? 'Every patch is already applied.'
          : 'Applied $applied patch${applied == 1 ? '' : 'es'}.',
    );
    return 0;
  }
}

final class _PatchListCommand extends _PatchSubcommand {
  _PatchListCommand(super.context);

  @override
  String get name => 'list';

  @override
  String get description => 'List the patches and whether each one applies.';

  @override
  Future<int> run() async {
    final cache = this.cache;
    final patches = cache.patches();
    if (patches.isEmpty) {
      console.info('There are no patches.');
      return 0;
    }
    final width = patches.fold(
      0,
      (w, patch) =>
          patch.relativePath.length > w ? patch.relativePath.length : w,
    );
    var problems = 0;
    for (final patch in patches) {
      final state = cache.hasBaseline
          ? await cache.stateOf(patch)
          : PatchState.missing;
      final label = switch (state) {
        PatchState.applied => console.green('applied'),
        PatchState.notApplied => console.yellow('not applied'),
        PatchState.stale => console.red(
          'stale: the lockfile uses another version',
        ),
        PatchState.missing => console.red('package not in the project cache'),
        PatchState.conflict => console.red('conflicts with edits in the cache'),
      };
      if (state != PatchState.applied && state != PatchState.notApplied) {
        problems++;
      }
      console.info('${patch.relativePath.padRight(width)}  $label');
    }
    return problems == 0 ? 0 : 1;
  }
}

final class _PatchRemoveCommand extends _PatchSubcommand {
  _PatchRemoveCommand(super.context);

  @override
  String get name => 'remove';

  @override
  String get description =>
      'Delete the patches for a package and undo them in the project cache.';

  @override
  String get invocation => 'dpk patch remove <package>';

  @override
  bool get takesArguments => true;

  @override
  Future<int> run() async {
    final packages = argResults!.rest;
    if (packages.isEmpty) {
      usageException('Name the package whose patches to remove.');
    }
    final cache = this.cache;
    for (final package in packages) {
      final removed = await cache.remove(package);
      if (removed.isEmpty) {
        throw DpkException('There is no patch for "$package".');
      }
      for (final path in removed) {
        console.info('Removed $path');
      }
    }
    return 0;
  }
}
