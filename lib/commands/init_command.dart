import 'dart:io';

import 'package:dpk/commands/dpk_command.dart';
import 'package:dpk/config/config_reader.dart';
import 'package:dpk/constants/pubspec.dart';
import 'package:dpk/core/constants.dart';
import 'package:dpk/core/errors.dart';
import 'package:dpk/workspace/workspace.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// The JSON schema URL that `dpk init` points editors at.
const schemaUrl =
    'https://raw.githubusercontent.com/exaby73/dpk/main/schema/dpk.schema.json';

final class InitCommand extends DpkCommand {
  InitCommand(super.context) {
    argParser
      ..addOption(
        'mode',
        allowed: ['global', 'project'],
        defaultsTo: 'global',
        help:
            'Where pub stores packages. Use "project" only to patch '
            'dependencies.',
      )
      ..addOption(
        'version-constraint',
        help: 'The dpk versions this project accepts.',
        defaultsTo: defaultVersionConstraint,
      )
      ..addFlag(
        'force',
        abbr: 'f',
        negatable: false,
        help: 'Overwrite an existing dpk.yaml.',
      );
  }

  @override
  String get name => 'init';

  @override
  String get description => 'Create a dpk.yaml for this package or workspace.';

  @override
  String get category => CommandCategory.setup;

  /// A constraint that the running dpk satisfies, including pre-releases.
  static String get defaultVersionConstraint => dpkVersion.isPreRelease
      ? '^$dpkVersion'
      : '^${dpkVersion.major}.${dpkVersion.minor}.0';

  @override
  Future<int> run() async {
    final directory = context.targetDirectory;
    if (!File(p.join(directory, 'pubspec.yaml')).existsSync()) {
      throw DpkException(
        'No pubspec.yaml in ${displayPath(directory)}. Run dpk init in a '
        'Dart package or workspace root.',
      );
    }

    final workspace = Workspace.discover(directory);
    if (workspace != null && workspace.current != workspace.root) {
      throw DpkException(
        '${displayPath(directory)} is a workspace package. Run dpk init at '
        'the workspace root, ${displayPath(workspace.root.path)}. A workspace '
        "package's own dpk.yaml may only add scripts.",
      );
    }

    final constraintText = argResults!.option('version-constraint')!;
    try {
      VersionConstraint.parse(constraintText);
    } on FormatException {
      throw DpkException(
        '"$constraintText" is not a version constraint. Use one like ^1.0.0.',
      );
    }

    final configFile = File(p.join(directory, kConfigFileName));
    if (configFile.existsSync() && !argResults!.flag('force')) {
      throw DpkException(
        '${displayPath(configFile.path)} already exists. Run with --force to '
        'overwrite it.',
      );
    }

    final projectMode = argResults!.option('mode') == 'project';
    configFile.writeAsStringSync(
      [
        '# yaml-language-server: \$schema=$schemaUrl',
        'version: $constraintText',
        if (projectMode) ...['', 'mode: project'],
        '',
        'scripts:',
        '  analyze:',
        '    command: dart analyze',
        '    description: Analyze the code.',
        '  test:',
        '    command: dart test',
        '    description: Run the tests.',
        '',
      ].join('\n'),
    );
    console.info('Created ${displayPath(configFile.path)}');

    if (projectMode) {
      _ignoreProjectCache(directory);
    }

    console.info(
      '\nNext steps:\n'
      '  dpk get       Get dependencies.\n'
      '  dpk run       List the scripts.\n'
      '  dpk run test  Run a script.',
    );
    return 0;
  }

  /// Keeps the project cache out of git and out of the analyzer.
  void _ignoreProjectCache(String directory) {
    final gitignore = File(p.join(directory, '.gitignore'));
    final ignoreLines = gitignore.existsSync()
        ? gitignore.readAsLinesSync()
        : const <String>[];
    if (!ignoreLines.any((line) => line.trim().startsWith('pub_packages'))) {
      final prefix =
          gitignore.existsSync() &&
              !gitignore.readAsStringSync().endsWith('\n') &&
              gitignore.lengthSync() > 0
          ? '\n'
          : '';
      gitignore.writeAsStringSync(
        '${prefix}pub_packages/\n',
        mode: FileMode.append,
      );
      console.info('Added pub_packages/ to .gitignore');
    }

    final options = File(p.join(directory, 'analysis_options.yaml'));
    final content = options.existsSync() ? options.readAsStringSync() : '';
    if (content.trim().isEmpty) {
      options.writeAsStringSync(
        'analyzer:\n  exclude:\n    - pub_packages/**\n',
      );
      console.info(
        'Excluded pub_packages/ from analysis in analysis_options.yaml',
      );
      return;
    }
    final yaml = loadYaml(content);
    final editor = YamlEditor(content);
    final analyzer = yaml is YamlMap ? yaml['analyzer'] : null;
    final exclude = analyzer is YamlMap ? analyzer['exclude'] : null;
    if (exclude is YamlList && exclude.contains('pub_packages/**')) {
      return;
    }
    if (exclude is YamlList) {
      editor.appendToList(['analyzer', 'exclude'], 'pub_packages/**');
    } else if (analyzer is YamlMap) {
      editor.update(['analyzer', 'exclude'], ['pub_packages/**']);
    } else {
      editor.update(
        ['analyzer'],
        {
          'exclude': ['pub_packages/**'],
        },
      );
    }
    options.writeAsStringSync('${editor.toString().trimRight()}\n');
    console.info(
      'Excluded pub_packages/ from analysis in analysis_options.yaml',
    );
  }
}
