import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpk/config/data/catalog.dart';
import 'package:dpk/config/data/dependency.dart';
import 'package:dpk/config/data/dpk_workspace_environment.dart';
import 'package:dpk/core/mixins/config_mixin.dart';
import 'package:dpk/core/mixins/process_handler_mixin.dart';
import 'package:dpk/core/mixins/pub_env_mixin.dart';
import 'package:dpk/utils/globals/global_args.dart';
import 'package:dpk/utils/globals/global_pub_args.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:pubspec_parse/pubspec_parse.dart'
    hide Dependency, PathDependency;
import 'package:yaml_edit/yaml_edit.dart';

part 'link_command.freezed.dart';
part 'link_command.g.dart';

final class LinkCommand extends Command<int>
    with ConfigMixin, PubEnvMixin, ProcessHandlerMixin {
  static final logger = Logger('dpk.link');

  @override
  String get name => 'link';

  @override
  String get description => 'Link packages in a monorepo';

  LinkCommand() {
    addGlobalPubArgs(argParser);
  }

  @override
  Future<int> run() {
    final options = LinkOptions.fromArgResults(argResults!);
    if (config.pubspec.name != '_') {
      throw StateError('Link command can only be used in a pub workspace');
    }

    return _generateDependencyOverrides(options);
  }

  Future<int> _generateDependencyOverrides(LinkOptions options) async {
    if (config.pubspec.workspace == null) {
      throw StateError('Link command can only be used in a pub workspace');
    }

    final catalog = config.dpkConfig.catalog;
    if (catalog == null) {
      throw StateError('Catalog not found in your configuration');
    }

    for (final workspace in config.pubspec.workspace!) {
      _editPubspecOfWorkspace(workspace, catalog);
    }

    final originalPubspecFile = File('pubspec.yaml');
    final originalPubspecYamlString = originalPubspecFile.readAsStringSync();
    final originalPubspec = Pubspec.parse(originalPubspecYamlString);
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

    await runDartProcess(arguments: ['pub', 'get']);

    return 0;
  }

  void _editPubspecOfWorkspace(String workspace, Catalog catalog) {
    final pubspecFile = File(join(workspace, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw StateError('pubspec.yaml not found in $workspace');
    }

    // TODO: Remove this after testing
    final bakFile = File(join(workspace, 'pubspec.bak.yaml'));
    if (!bakFile.existsSync()) {
      bakFile.writeAsStringSync(pubspecFile.readAsStringSync());
    } else {
      pubspecFile.writeAsStringSync(bakFile.readAsStringSync());
    }

    final originalPubspec = Pubspec.parse(pubspecFile.readAsStringSync());
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

  DpkWorkspaceEnvironment _createDpkEnv(Pubspec pubspec, String workspacePath) {
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
    Pubspec originalPubspec,
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
abstract class LinkOptions with _$LinkOptions {
  const factory LinkOptions({
    required GlobalOptions globalOptions,
    required GlobalPubOptions globalPubOptions,
  }) = _LinkOptions;

  factory LinkOptions.fromArgResults(ArgResults results) {
    return LinkOptions(
      globalOptions: GlobalOptions.fromArgResults(results),
      globalPubOptions: GlobalPubOptions.fromArgResults(results),
    );
  }
}

@freezed
abstract class PackageConfigItem with _$PackageConfigItem {
  const factory PackageConfigItem({
    required String name,
    required Uri rootUri,
    required String packageUri,
    required String languageVersion,
  }) = _PackageConfigItem;

  factory PackageConfigItem.fromJson(Map<String, dynamic> json) =>
      _$PackageConfigItemFromJson(json);
}
