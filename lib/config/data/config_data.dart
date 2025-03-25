import 'dart:convert';

import 'package:dpm/config/data/scripts.dart';
import 'package:dpm/utils/collection.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml/yaml.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yaml_edit/yaml_edit.dart';

part 'config_data.freezed.dart';
part 'config_data.g.dart';

@freezed
abstract class ConfigData with _$ConfigData {
  const factory ConfigData({
    // TODO: Remove JsonKey after testing
    @JsonKey(includeFromJson: false, includeToJson: false) Pubspec? pubspec,
    required Scripts scripts,
  }) = _ConfigData;

  factory ConfigData.fromYaml(YamlMap yaml) {
    final pubspec = Pubspec.fromJson(yaml);
    final rawScripts = yaml['scripts'];
    if (rawScripts is! YamlMap) {
      throw StateError('Invalid scripts section');
    }

    final scripts = Scripts.fromYaml(rawScripts);

    return ConfigData(pubspec: pubspec, scripts: scripts);
  }

  factory ConfigData.fromJson(Map<String, dynamic> json) =>
      _$ConfigDataFromJson(json);
}

void main() {
  final yamlString = '''
name: dpm
scripts:
  preget:
    description: 'Preinstall script'
    command: 'echo "Preinstall script"'
  postget: echo 'Postinstall script'
''';
  final anotherYamlString = '''
scripts:
  preget:
    description: 'Changed'
  install: echo 'Install script'
''';
  final yaml = loadYaml(yamlString) as YamlMap;
  final anotherYaml = loadYaml(anotherYamlString) as YamlMap;
  var mergeMaps2 = mergeMaps(yaml, anotherYaml);
  print(jsonEncode(mergeMaps2));
  final mergedYaml = loadYaml(jsonEncode(mergeMaps2)) as YamlMap;
  final editor = YamlEditor(mergedYaml.toString());

  print(editor);

  print(
    const JsonEncoder.withIndent(
      '  ',
    ).convert(ConfigData.fromYaml(yaml).toJson()),
  );
}
