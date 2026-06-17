import 'package:dpk/config/data/catalog.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

part 'dpk_config.freezed.dart';

@freezed
abstract class DpkConfig with _$DpkConfig {
  const factory DpkConfig({
    @Default(DpkMode.global) DpkMode mode,
    Catalog? catalog,
    List<String>? workspace,
    @Default(false) bool sortPubspec,
    required VersionConstraint version,
  }) = _DpkConfig;

  factory DpkConfig.fromYaml(YamlMap yaml) {
    final versionString = yaml['version'] as String?;
    if (versionString == null) {
      throw StateError("'version' is required in dpk.yaml");
    }
    final version = VersionConstraint.parse(versionString);

    var map = yaml;
    if (map.containsKey('dpk')) {
      map = map['dpk'] as YamlMap;
    }

    final dpkMode = map['mode'] as String?;
    final catalogYaml = map['catalog'] as YamlMap?;
    final catalog = catalogYaml != null ? Catalog.fromYaml(catalogYaml) : null;
    final workspaceYaml = map['workspace'] as YamlList?;
    final workspace = workspaceYaml?.cast<String>();
    final sortPubspec =
        map['sort_pubspec'] as bool? ?? map['sortPubspec'] as bool? ?? false;

    return DpkConfig(
      mode: DpkMode.values.firstWhere(
        (mode) => mode.name == dpkMode,
        orElse: () => DpkMode.global,
      ),
      catalog: catalog,
      workspace: workspace,
      sortPubspec: sortPubspec,
      version: version,
    );
  }
}

enum DpkMode { global, project }
