import 'dart:convert';
import 'dart:io';

import 'package:dpk/config/data/config_data.dart';
import 'package:dpk/core/constants.dart';
import 'package:dpk/utils/collection.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

Directory? findDpkYamlDirectory(Directory startDirectory) {
  var currentDir = startDirectory;

  while (true) {
    final configFile = File(join(currentDir.path, kConfigFileName));
    if (configFile.existsSync()) {
      return currentDir;
    }

    final parentDir = currentDir.parent;
    if (parentDir.path == currentDir.path) {
      return null;
    }

    currentDir = parentDir;
  }
}

ConfigData loadConfig(Directory directory) {
  final configFile = File(join(directory.path, kConfigFileName));
  final pubspecFile = File(join(directory.path, 'pubspec.yaml'));

  if (!pubspecFile.existsSync()) {
    throw StateError('pubspec.yaml not found in ${directory.path}');
  }

  final pubspecYaml = loadYaml(pubspecFile.readAsStringSync());
  YamlMap? configYaml;

  if (configFile.existsSync()) {
    configYaml = loadYaml(configFile.readAsStringSync()) as YamlMap?;
  }

  final mergedYaml = mergeMaps(pubspecYaml as Map, (configYaml as Map?) ?? {});
  final configData = ConfigData.fromYaml(
    loadYaml(jsonEncode(mergedYaml)) as YamlMap,
    directory.path,
  );

  return configData;
}
