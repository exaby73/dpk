import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpk/config/data/catelog.dart';
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
import 'package:yaml/yaml.dart';
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

    final catelog = config.dpkConfig.catelog;
    if (catelog == null) {
      throw StateError('Catelog not found in pubspec.yaml');
    }

    for (final workspace in config.pubspec.workspace!) {
      _editPubspecOfWorkspace(workspace, catelog);
    }

    await runDartProcess(arguments: ['pub', 'get']);

    return 0;
  }

  void _editPubspecOfWorkspace(String workspace, Catelog catelog) {
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

    if (catelog.environment != null) {
      editor.update(
        ['environment'],
        catelog.environment!.map(
          (key, value) => MapEntry(
            key,
            value?.toString(),
          ),
        ),
      );
    }

    if (catelog.publishTo != null) {
      editor.update(['publish_to'], catelog.publishTo);
    }

    if (catelog.repository != null) {
      editor.update(
        ['repository'],
        env.replace(catelog.repository!.toString()),
      );
    }

    if (catelog.issueTracker != null) {
      editor.update(
        ['issue_tracker'],
        env.replace(
          catelog.issueTracker!.toString(),
        ),
      );
    }

    if (catelog.topics != null) {
      if (originalPubspec.topics != null) {
        final currentTopics = originalPubspec.topics!;
        final topicsToEnsureExists = catelog.topics!;
        for (final topic in topicsToEnsureExists) {
          if (!currentTopics.contains(topic)) {
            currentTopics.add(topic);
          }
        }
        editor.update(['topics'], currentTopics);
      }
    }

    if (catelog.documentation != null) {
      editor.update(['documentation'], env.replace(catelog.documentation!));
    }

    if (catelog.resolution != null) {
      editor.update(['resolution'], catelog.resolution);
    }

    pubspecFile.writeAsStringSync(editor.toString());
  }

  DpkWorkspaceEnvironment _createDpkEnv(
    Pubspec pubspec,
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
