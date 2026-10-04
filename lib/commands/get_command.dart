import 'dart:io';

import 'package:args/args.dart';
import 'package:dpk/catalog/pubspec_updates.dart';
import 'package:dpk/commands/dpk_command.dart';
import 'package:dpk/config/config_migration.dart';
import 'package:dpk/config/config_reader.dart';
import 'package:dpk/core/constants.dart';
import 'package:dpk/patching/project_cache.dart';
import 'package:dpk/scripts/hook_lifecycle.dart';
import 'package:dpk/utils/terminal_title.dart';
import 'package:path/path.dart' as p;

final class GetCommand extends DpkCommand {
  GetCommand(super.context);

  @override
  final ArgParser argParser = ArgParser.allowAnything();

  @override
  String get name => 'get';

  @override
  String get description =>
      'Apply the catalog and sort pubspecs, then get dependencies.';

  @override
  String get category => CommandCategory.dependencies;

  @override
  bool get takesArguments => true;

  @override
  String get invocation => 'dpk get [--check] [pub get options]';

  @override
  void printUsage() => console.info(
    '$description\n\n'
    'Usage: $invocation\n\n'
    '--check    Exit with code 1 if the catalog or sorting would change a '
    'pubspec,\n'
    '           without changing anything or getting dependencies. For CI.\n\n'
    'Every other option is passed to "dart pub get". Run "dart pub get '
    '--help" to see them.',
  );

  @override
  Future<int> run() async {
    final arguments = [...argResults!.rest];
    if (arguments.contains('--help') || arguments.contains('-h')) {
      printUsage();
      return 0;
    }
    final check = arguments.remove('--check');
    final dryRun = arguments.contains('--dry-run') || arguments.contains('-n');

    return withTerminalTitle(
      console,
      'dpk get',
      () => check
          ? Future.value(_check())
          : context.withHooks(
              'get',
              (stack) => _get(arguments, dryRun: dryRun, stack: stack),
              order: HookOrder.beforeAfterTarget,
            ),
    );
  }

  int _check() {
    final project = context.requireProject;
    final stale = [
      for (final update in planPubspecUpdates(project))
        if (update.changed) update.path,
      for (final config in _configFiles())
        if (migrateConfig(File(config).readAsStringSync()) !=
            File(config).readAsStringSync())
          config,
    ];
    if (stale.isEmpty) {
      console.info('Every pubspec and dpk.yaml is up to date.');
      return 0;
    }
    console.error(
      'dpk get would change ${stale.length} file'
      '${stale.length == 1 ? '' : 's'}:\n'
      '${stale.map((path) => '  ${displayPath(path)}').join('\n')}\n'
      'Run "dpk get" and commit the result.',
    );
    return 1;
  }

  Future<int> _get(
    List<String> arguments, {
    required bool dryRun,
    required HookStack stack,
  }) async {
    final project = context.requireProject;

    for (final config in _configFiles()) {
      final before = File(config).readAsStringSync();
      final after = migrateConfig(before);
      if (after != before) {
        if (dryRun) {
          console.step(
            '> Would rename deprecated keys in ${displayPath(config)}',
          );
        } else {
          File(config).writeAsStringSync(after);
          console.step('> Renamed deprecated keys in ${displayPath(config)}');
        }
      }
    }

    final updates = planPubspecUpdates(
      project,
    ).where((update) => update.changed).toList();
    if (updates.isNotEmpty) {
      final verb = dryRun ? 'Would update' : 'Updated';
      if (!dryRun) {
        writePubspecUpdates(updates);
      }
      console.step(
        '> $verb ${updates.map((u) => displayPath(u.path)).join(', ')}',
      );
    }

    final exitCode = await context.runDart([
      'pub',
      ...context.pubFlags,
      'get',
      ...arguments,
    ], environment: stack.toEnvironment());
    if (exitCode != 0 || dryRun || !project.isProjectMode) {
      return exitCode;
    }
    return ProjectCache.forProject(project, context).sync();
  }

  /// The root `dpk.yaml` and the current package's own `dpk.yaml`.
  List<String> _configFiles() {
    final project = context.requireProject;
    return {
      project.configPath,
      p.join(project.workspace.current.path, kConfigFileName),
    }.where((path) => File(path).existsSync()).toList();
  }
}
