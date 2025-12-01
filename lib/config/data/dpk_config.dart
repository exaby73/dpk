import 'package:dpk/config/data/catalog.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yaml/yaml.dart';

part 'dpk_config.freezed.dart';

@freezed
abstract class DpkConfig with _$DpkConfig {
  const factory DpkConfig({
    @Default(DpkMode.global) DpkMode mode,
    Catalog? catalog,
    List<String>? workspace,
  }) = _DpkConfig;

  factory DpkConfig.fromYaml(YamlMap yaml) {
    var map = yaml;
    if (map.containsKey('dpk')) {
      map = map['dpk'] as YamlMap;
    }

    final dpkMode = map['mode'] as String?;
    final catalogYaml = map['catalog'] as YamlMap?;
    final catalog = catalogYaml != null ? Catalog.fromYaml(catalogYaml) : null;
    final workspaceYaml = map['workspace'] as YamlList?;
    final workspace = workspaceYaml?.cast<String>();

    return DpkConfig(
      mode: DpkMode.values.firstWhere(
        (mode) => mode.name == dpkMode,
        orElse: () => DpkMode.global,
      ),
      catalog: catalog,
      workspace: workspace,
    );
  }
}

enum DpkMode { global, project }
