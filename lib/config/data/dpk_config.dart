import 'package:dpk/config/data/catelog.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yaml/yaml.dart';

part 'dpk_config.freezed.dart';

@freezed
abstract class DpkConfig with _$DpkConfig {
  const factory DpkConfig({
    @Default(DpkMode.global) DpkMode mode,
    Catelog? catelog,
  }) = _DpkConfig;

  factory DpkConfig.fromYaml(YamlMap yaml) {
    var map = yaml;
    if (map.containsKey('dpk')) {
      map = map['dpk'] as YamlMap;
    }

    final dpkMode = map['mode'] as String?;
    final catelogYaml = map['catelog'] as YamlMap?;
    final catelog = catelogYaml != null ? Catelog.fromYaml(catelogYaml) : null;

    return DpkConfig(
      mode: DpkMode.values.firstWhere(
        (mode) => mode.name == dpkMode,
        orElse: () => DpkMode.global,
      ),
      catelog: catelog,
    );
  }
}

enum DpkMode { global, project }
