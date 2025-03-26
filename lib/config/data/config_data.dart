import 'package:dpm/config/data/scripts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml/yaml.dart';

part 'config_data.freezed.dart';

@freezed
abstract class ConfigData with _$ConfigData {
  const factory ConfigData({Pubspec? pubspec, required Scripts scripts}) =
      _ConfigData;

  factory ConfigData.fromYaml(YamlMap yaml) {
    final pubspec = Pubspec.fromJson(yaml);
    final rawScripts = yaml['scripts'];
    if (rawScripts is! YamlMap) {
      throw StateError('Invalid scripts section');
    }

    final scripts = Scripts.fromYaml(rawScripts);

    return ConfigData(pubspec: pubspec, scripts: scripts);
  }
}
