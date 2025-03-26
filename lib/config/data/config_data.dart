import 'package:dpm/config/data/dpm_config.dart';
import 'package:dpm/config/data/scripts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml/yaml.dart';

part 'config_data.freezed.dart';

@freezed
abstract class ConfigData with _$ConfigData {
  const factory ConfigData({
    @Default(null) Pubspec? pubspec,
    required DpmConfig dpmConfig,
    required Scripts scripts,
  }) = _ConfigData;

  factory ConfigData.fromYaml(YamlMap yaml) {
    final pubspec = Pubspec.fromJson(yaml);
    final rawScripts = yaml['scripts'];
    if (rawScripts is! YamlMap) {
      throw StateError('Invalid scripts section');
    }

    final dpmConfig = DpmConfig.fromYaml(yaml);
    final scripts = Scripts.fromYaml(rawScripts);

    return ConfigData(pubspec: pubspec, dpmConfig: dpmConfig, scripts: scripts);
  }
}
