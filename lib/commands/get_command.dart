import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpk/config/data/catalog.dart';
import 'package:dpk/config/data/dpk_workspace_environment.dart';
import 'package:dpk/core/mixins/config_mixin.dart';
import 'package:dpk/core/mixins/hook_runner_mixin.dart';
import 'package:dpk/core/mixins/process_handler_mixin.dart';
import 'package:dpk/core/mixins/pub_env_mixin.dart';
import 'package:dpk/utils/catalog_comment_utils.dart';
import 'package:dpk/utils/catalog_utils.dart';
import 'package:dpk/utils/pubspec_sorter.dart';
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

    final targetDirectory =
        options.globalPubOptions.globalOptions.directory ??
        config.workingDirectory;

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
      await _generateDependencyOverrides(targetDirectory);
    }

    final exitCode = await runDartProcess(
      arguments: arguments,
      workingDirectory: targetDirectory,
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

  Future<void> _generateDependencyOverrides(String targetDirectory) async {
    final catalog = config.dpkConfig.catalog;
    final workspaces = config.pubspec.workspace;

    final originalPubspecFile = File(join(targetDirectory, 'pubspec.yaml'));
    final originalPubspecYamlString = originalPubspecFile.readAsStringSync();
    final originalPubspec = pubspec_parse.Pubspec.parse(
      originalPubspecYamlString,
    );
    final editor = YamlEditor(originalPubspecYamlString);

    if (workspaces != null && workspaces.isNotEmpty) {
      editor.update(['workspace'], workspaces);
    }

    if (catalog != null) {
      _applyRootCatalog(editor, originalPubspec, catalog);

      for (final workspace in workspaces ?? <String>[]) {
        _editPubspecOfWorkspace(targetDirectory, workspace, catalog);
      }
    }

    final pubspecYamlString = editor.toString();
    originalPubspecFile.writeAsStringSync(pubspecYamlString);
    _sortPubspecIfEnabled(
      originalPubspecFile,
      catalog?.dependencies?.keys.toSet(),
    );
  }

  void _applyRootCatalog(
    YamlEditor editor,
    pubspec_parse.Pubspec pubspec,
    Catalog catalog,
  ) {
    if (catalog.environment != null) {
      editor.update(
        ['environment'],
        catalog.environment!.map(
          (key, value) => MapEntry(key, value?.toString()),
        ),
      );
    }

    updateExistingDependencies(editor, pubspec, catalog);
  }

  void _editPubspecOfWorkspace(
    String targetDirectory,
    String workspace,
    Catalog catalog,
  ) {
    final pubspecFile = File(join(targetDirectory, workspace, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw StateError('pubspec.yaml not found in $workspace');
    }

    final originalPubspec = pubspec_parse.Pubspec.parse(
      pubspecFile.readAsStringSync(),
    );
    final env = _createDpkEnv(originalPubspec, workspace);
    final editor = YamlEditor(pubspecFile.readAsStringSync());

    if (catalog.environment != null) {
      editor.update(
        ['environment'],
        catalog.environment!.map(
          (key, value) => MapEntry(key, value?.toString()),
        ),
      );
    }

    if (catalog.publishTo != null) {
      editor.update(['publish_to'], catalog.publishTo);
    }

    if (catalog.repository != null) {
      editor.update([
        'repository',
      ], env.replace(catalog.repository!.toString()));
    }

    if (catalog.issueTracker != null) {
      editor.update([
        'issue_tracker',
      ], env.replace(catalog.issueTracker!.toString()));
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

    updateExistingDependencies(editor, originalPubspec, catalog);

    final yamlContent = editor.toString();
    pubspecFile.writeAsStringSync(yamlContent);
    _sortPubspecIfEnabled(pubspecFile, catalog.dependencies?.keys.toSet());
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

  void _sortPubspecIfEnabled(
    File pubspecFile, [
    Set<String>? catalogDependencyNames,
  ]) {
    var content = pubspecFile.readAsStringSync();

    // Add catalog comments first (before sorting)
    if (catalogDependencyNames != null && catalogDependencyNames.isNotEmpty) {
      content = addCatalogCommentsToDependencies(
        content,
        catalogDependencyNames,
      );
    }

    // Then sort if enabled (sorting now properly preserves comments on complex deps)
    if (config.dpkConfig.sortPubspec) {
      content = sortPubspec(content);
    }

    pubspecFile.writeAsStringSync(content);
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
