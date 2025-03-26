import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yaml/yaml.dart';

part 'dpm_config.freezed.dart';

@freezed
abstract class DpmConfig with _$DpmConfig {
  const factory DpmConfig({@Default(DpmMode.global) DpmMode mode}) = _DpmConfig;

  factory DpmConfig.fromYaml(YamlMap yaml) {
    var map = yaml;
    if (map.containsKey('dpm')) {
      map = map['dpm'] as YamlMap;
    }

    final dpmMode = map['mode'] as String?;
    return DpmConfig(
      mode: DpmMode.values.firstWhere(
        (mode) => mode.name == dpmMode,
        orElse: () => DpmMode.global,
      ),
    );
  }
}

enum DpmMode { global, project }
