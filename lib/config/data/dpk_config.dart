import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yaml/yaml.dart';

part 'dpk_config.freezed.dart';

@freezed
abstract class DpkConfig with _$DpkConfig {
  const factory DpkConfig({@Default(DpkMode.global) DpkMode mode}) = _DpkConfig;

  factory DpkConfig.fromYaml(YamlMap yaml) {
    var map = yaml;
    if (map.containsKey('dpk')) {
      map = map['dpk'] as YamlMap;
    }

    final dpkMode = map['mode'] as String?;
    return DpkConfig(
      mode: DpkMode.values.firstWhere(
        (mode) => mode.name == dpkMode,
        orElse: () => DpkMode.global,
      ),
    );
  }
}

enum DpkMode { global, project }
