import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpk/config/data/catalog.dart';
import 'package:dpk/config/data/dependency.dart';
import 'package:dpk/config/data/dpk_workspace_environment.dart';
import 'package:dpk/core/mixins/config_mixin.dart';
import 'package:dpk/core/mixins/hook_runner_mixin.dart';
import 'package:dpk/core/mixins/process_handler_mixin.dart';
import 'package:dpk/core/mixins/pub_env_mixin.dart';
import 'package:dpk/utils/globals/global_pub_args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:pubspec_parse/pubspec_parse.dart' as pubspec_parse;
import 'package:yaml_edit/yaml_edit.dart';

part 'get_command.freezed.dart';

final class GetCommand extends Command<int>
    with ConfigMixin, PubEnvMixin, ProcessHandlerMixin, HookRunnerMixin {
  @override
  String name = 'get';

  @override
  String get description => 'Get dependencies';

  final logger = Logger('pub.get');

  GetCommand() {
    addGlobalPubArgs(argParser);
    argParser.addFlag(
      'offline',
      help: 'Use cached packages instead of accessing the network',
    );
    argParser.addFlag(
      'dry-run',
      abbr: 'n',
      help: "Report what dependencies would change but don't change any",
    );
    argParser.addFlag(
      'enforce-lockfile',
      help:
          'Enforce pubspec.lock. Fail `pub get` if the current `pubspec.lock` '
          'does not exactly specify a valid resolution of `pubspec.yaml` '
          'or if any content hash of a hosted package has changed. '
          'Useful for CI or deploying to production',
      negatable: false,
    );
    argParser.addFlag(
      'precompile',
      help: 'Build executables in immediate dependencies',
    );
  }

  @override
  Future<int> run() async {
    final options = PubGetOptions.fromArgResults(argResults!);
    final arguments = [
      'pub',
      ...buildGlobalArgs(options.globalPubOptions),
      'get',
      if (options.offline) '--offline',
      if (options.dryRun) '--dry-run',
      if (options.enforceLockfile) '--enforce-lockfile',
      if (options.precompile) '--precompile',
      ...argResults!.rest,
    ];

    final preHookExitCode = await runPreHook(
      commandName: 'get',
      globalOptions: options.globalPubOptions.globalOptions,
    );
    if (preHookExitCode != 0) {
      return preHookExitCode;
    }

    if (options.globalPubOptions.globalOptions.isVerbose) {
      logger.info('Running: dart ${arguments.join(' ')}');
    }

    if (config.pubspec.name == '_') {
      await _generateDependencyOverrides(options, arguments);
    }

    final exitCode = await runDartProcess(
      arguments: arguments,
      workingDirectory: options.globalPubOptions.globalOptions.directory,
      environment: getCacheEnv(options.globalPubOptions.cacheDir),
    );

    if (exitCode != 0) {
      return exitCode;
    }

    final postHookExitCode = await runPostHook(
      commandName: 'get',
      globalOptions: options.globalPubOptions.globalOptions,
    );
    return postHookExitCode;
  }

  Future<void> _generateDependencyOverrides(
    PubGetOptions options,
    List<String> arguments,
  ) async {
    if (config.pubspec.workspace == null) {
      throw StateError('No workspace found in pubspec.yaml');
    }

    final catalog = config.dpkConfig.catalog;
    if (catalog == null) {
      return;
    }

    for (final workspace in config.pubspec.workspace!) {
      _editPubspecOfWorkspace(workspace, catalog);
    }

    final originalPubspecFile = File('pubspec.yaml');
    final originalPubspecYamlString = originalPubspecFile.readAsStringSync();
    final originalPubspec =
        pubspec_parse.Pubspec.parse(originalPubspecYamlString);
    final (:dependencies, :devDependencies, :dependencyOverrides) =
        _generateDependencies(originalPubspec, catalog);

    final pubspecOverridesYamlEditor = YamlEditor(originalPubspecYamlString);

    if (dependencies.isNotEmpty) {
      pubspecOverridesYamlEditor.update(
        ['dependencies'],
        dependencies.map(
          (key, value) {
            return MapEntry(key, value.toJson());
          },
        ),
      );
    } else if (originalPubspec.dependencies.isNotEmpty) {
      pubspecOverridesYamlEditor.remove(['dependencies']);
    }

    if (devDependencies.isNotEmpty) {
      pubspecOverridesYamlEditor.update(
        ['dev_dependencies'],
        devDependencies.map(
          (key, value) {
            return MapEntry(key, value.toJson());
          },
        ),
      );
    } else if (originalPubspec.devDependencies.isNotEmpty) {
      pubspecOverridesYamlEditor.remove(['dev_dependencies']);
    }

    if (dependencyOverrides.isNotEmpty) {
      pubspecOverridesYamlEditor.update(
        ['dependency_overrides'],
        dependencyOverrides.map(
          (key, value) {
            return MapEntry(key, value.toJson());
          },
        ),
      );
    } else if (originalPubspec.dependencyOverrides.isNotEmpty) {
      pubspecOverridesYamlEditor.remove(['dependency_overrides']);
    }

    final pubspecOverridesYamlString = pubspecOverridesYamlEditor.toString();
    originalPubspecFile.writeAsStringSync(pubspecOverridesYamlString);
  }

  void _editPubspecOfWorkspace(String workspace, Catalog catalog) {
    final pubspecFile = File(join(workspace, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw StateError('pubspec.yaml not found in $workspace');
    }

    final originalPubspec =
        pubspec_parse.Pubspec.parse(pubspecFile.readAsStringSync());
    final env = _createDpkEnv(originalPubspec, workspace);
    final editor = YamlEditor(pubspecFile.readAsStringSync());

    if (catalog.environment != null) {
      editor.update(
        ['environment'],
        catalog.environment!.map(
          (key, value) => MapEntry(
            key,
            value?.toString(),
          ),
        ),
      );
    }

    if (catalog.publishTo != null) {
      editor.update(['publish_to'], catalog.publishTo);
    }

    if (catalog.repository != null) {
      editor.update(
        ['repository'],
        env.replace(catalog.repository!.toString()),
      );
    }

    if (catalog.issueTracker != null) {
      editor.update(
        ['issue_tracker'],
        env.replace(
          catalog.issueTracker!.toString(),
        ),
      );
    }

    if (catalog.topics != null) {
      if (originalPubspec.topics != null) {
        final currentTopics = originalPubspec.topics!;
        final topicsToEnsureExists = catalog.topics!;
        for (final topic in topicsToEnsureExists) {
          if (!currentTopics.contains(topic)) {
            currentTopics.add(topic);
          }
        }
        editor.update(['topics'], currentTopics);
      } else {
        editor.update(['topics'], catalog.topics);
      }
    }

    if (catalog.documentation != null) {
      editor.update(['documentation'], env.replace(catalog.documentation!));
    }

    if (catalog.resolution != null) {
      editor.update(['resolution'], catalog.resolution);
    }

    pubspecFile.writeAsStringSync(editor.toString());
  }

  DpkWorkspaceEnvironment _createDpkEnv(
    pubspec_parse.Pubspec pubspec,
    String workspacePath,
  ) {
    final packagePath = workspacePath;
    final packageName = pubspec.name;
    final packageVersion = pubspec.version;

    return DpkWorkspaceEnvironment(
      dpkPackagePath: packagePath,
      dpkPackageName: packageName,
      dpkPackageVersion: packageVersion?.toString(),
    );
  }

  ({
    Map<String, Dependency> dependencies,
    Map<String, Dependency> devDependencies,
    Map<String, Dependency> dependencyOverrides
  }) _generateDependencies(
    pubspec_parse.Pubspec originalPubspec,
    Catalog catalog,
  ) {
    final dependencies = <String, Dependency>{};
    final devDependencies = <String, Dependency>{};
    final dependencyOverrides = <String, Dependency>{};

    final Catalog(
      dependencies: catalogDependencies,
      devDependencies: catalogDevDependencies,
      dependencyOverrides: catalogDependencyOverrides
    ) = catalog;

    if (catalogDependencies != null) {
      for (final dependency in catalogDependencies.entries) {
        dependencies[dependency.key] = dependency.value;
      }
    }

    if (catalogDevDependencies != null) {
      for (final dependency in catalogDevDependencies.entries) {
        devDependencies[dependency.key] = dependency.value;
      }
    }

    if (catalogDependencyOverrides != null) {
      for (final dependency in catalogDependencyOverrides.entries) {
        dependencyOverrides[dependency.key] = dependency.value;
      }
    }

    return (
      dependencies: dependencies,
      devDependencies: devDependencies,
      dependencyOverrides: dependencyOverrides,
    );
  }
}

@freezed
abstract class PubGetOptions with _$PubGetOptions {
  const factory PubGetOptions({
    required GlobalPubOptions globalPubOptions,
    required bool offline,
    required bool dryRun,
    required bool enforceLockfile,
    required bool precompile,
  }) = _PubGetOptions;

  factory PubGetOptions.fromArgResults(ArgResults results) {
    return PubGetOptions(
      globalPubOptions: GlobalPubOptions.fromArgResults(results),
      offline: results.flag('offline'),
      dryRun: results.flag('dry-run'),
      enforceLockfile: results.flag('enforce-lockfile'),
      precompile: results.flag('precompile'),
    );
  }
}
