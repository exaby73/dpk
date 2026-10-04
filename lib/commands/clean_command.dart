import 'dart:io';

import 'package:dpk/commands/dpk_command.dart';
import 'package:dpk/core/errors.dart';
import 'package:dpk/scripts/run_plan.dart';
import 'package:dpk/workspace/workspace.dart';
import 'package:path/path.dart' as p;

final class CleanCommand extends DpkCommand {
  CleanCommand(super.context) {
    argParser
      ..addMultiOption(
        'filter',
        valueHelp: 'package',
        help: 'Only clean workspace packages with this name or path glob.',
      )
      ..addFlag('lockfile', negatable: false, help: 'Also remove pubspec.lock.')
      ..addFlag(
        'cache',
        negatable: false,
        help:
            'Also remove the project cache. "dpk get" downloads the packages '
            'and applies the patches again.',
      )
      ..addFlag(
        'dry-run',
        abbr: 'n',
        negatable: false,
        help: 'List what would be removed without removing it.',
      );
  }

  @override
  String get name => 'clean';

  @override
  String get description =>
      'Remove .dart_tool/ and build/ in every workspace package.';

  @override
  String get category => CommandCategory.workspace;

  @override
  Future<int> run() async {
    final project = context.requireProject;
    final dryRun = argResults!.flag('dry-run');
    final removeCache = argResults!.flag('cache');
    if (removeCache && !project.isProjectMode) {
      throw DpkException(
        '--cache removes the project cache, which only exists in project mode.',
      );
    }

    final filters = argResults!.multiOption('filter');
    final List<WorkspacePackage> packages;
    try {
      packages = filters.isEmpty
          ? project.workspace.allPackages
          : planRun(workspace: project.workspace, filters: filters).packages;
    } on RunPlanException catch (e) {
      throw DpkException(e.message);
    }

    return context.withHooks('clean', (stack) async {
      final flutter = _flutterOnPath();
      final paths = <String>[];
      for (final package in packages) {
        final usesFlutter = package.dependencies.contains('flutter');
        if (usesFlutter && flutter != null && !dryRun) {
          final exitCode = await context.processRunner.runInteractive(
            flutter,
            ['clean'],
            workingDirectory: package.path,
            environment: stack.toEnvironment(),
          );
          if (exitCode != 0) {
            return exitCode;
          }
        }
        paths.addAll([
          p.join(package.path, '.dart_tool'),
          p.join(package.path, 'build'),
          if (argResults!.flag('lockfile'))
            p.join(package.path, 'pubspec.lock'),
        ]);
      }
      if (removeCache) {
        paths.add(project.cacheDirectory);
      }

      var removed = 0;
      for (final path in paths) {
        final type = FileSystemEntity.typeSync(path, followLinks: false);
        if (type == FileSystemEntityType.notFound) {
          continue;
        }
        removed++;
        if (dryRun) {
          console.info(
            'Would remove ${p.relative(path, from: project.rootPath)}',
          );
          continue;
        }
        if (type == FileSystemEntityType.directory) {
          Directory(path).deleteSync(recursive: true);
        } else {
          File(path).deleteSync();
        }
        console.info('Removed ${p.relative(path, from: project.rootPath)}');
      }
      if (removed == 0) {
        console.info('Nothing to clean.');
      }
      return 0;
    });
  }

  /// The `flutter` executable on `PATH`, or `null`.
  String? _flutterOnPath() {
    final path = context.environment['PATH'];
    if (path == null) {
      return null;
    }
    final names = Platform.isWindows
        ? ['flutter.bat', 'flutter.exe']
        : ['flutter'];
    for (final directory in path.split(Platform.isWindows ? ';' : ':')) {
      for (final name in names) {
        final candidate = p.join(directory, name);
        if (File(candidate).existsSync()) {
          return candidate;
        }
      }
    }
    return null;
  }
}
