import 'package:dpk/config/data/dpk_config.dart';
import 'package:dpk/config/data/scripts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml/yaml.dart';

part 'config_data.freezed.dart';

@freezed
abstract class ConfigData with _$ConfigData {
  const factory ConfigData({
    required Pubspec pubspec,
    required DpkConfig dpkConfig,
    required Scripts? scripts,
    required String workingDirectory,
    String? workspaceRoot,
  }) = _ConfigData;

  factory ConfigData.fromYaml({
    required YamlMap pubspecYaml,
    required YamlMap dpkYaml,
    required String workingDirectory,
    String? workspaceRoot,
  }) {
    final pubspec = Pubspec.fromJson(pubspecYaml);
    final rawScripts = dpkYaml['scripts'];
    if (rawScripts is! YamlMap?) {
      throw StateError('Invalid scripts section');
    }

    final dpkConfig = DpkConfig.fromYaml(dpkYaml);
    late final Scripts? scripts;
    if (rawScripts != null) {
      scripts = Scripts.fromYaml(rawScripts);
    } else {
      scripts = null;
    }

    return ConfigData(
      pubspec: pubspec,
      dpkConfig: dpkConfig,
      scripts: scripts,
      workingDirectory: workingDirectory,
      workspaceRoot: workspaceRoot,
    );
  }
}
