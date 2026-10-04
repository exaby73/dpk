import 'package:dpk/config/dpk_config.dart';
import 'package:yaml/yaml.dart';

/// Renames deprecated keys in the text of a `dpk.yaml`, such as
/// `sortPubspec` to `sort_pubspec` and `runInPackages` to `run_in_packages`.
///
/// Only the key text changes, so comments and formatting stay as they are. A
/// deprecated key is left alone when its new name is also present.
String migrateConfig(String content) {
  final YamlNode document;
  try {
    document = loadYamlNode(content);
  } on YamlException {
    return content;
  }
  if (document is! YamlMap) {
    return content;
  }

  final renames = <({int start, int end, String name})>[];
  void collect(YamlMap map, Map<String, String> legacy) {
    for (final key in map.nodes.keys.whereType<YamlScalar>()) {
      final replacement = legacy[key.value];
      if (replacement != null && !map.containsKey(replacement)) {
        renames.add((
          start: key.span.start.offset,
          end: key.span.end.offset,
          name: replacement,
        ));
      }
    }
  }

  collect(document, DpkConfig.legacyKeys);
  final scripts = document.nodes['scripts'];
  if (scripts is YamlMap) {
    for (final script in scripts.nodes.values.whereType<YamlMap>()) {
      collect(script, Script.legacyKeys);
    }
  }

  renames.sort((a, b) => b.start.compareTo(a.start));
  var result = content;
  for (final rename in renames) {
    result = result.replaceRange(rename.start, rename.end, rename.name);
  }
  return result;
}
