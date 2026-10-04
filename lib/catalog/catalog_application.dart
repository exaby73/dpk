import 'package:collection/collection.dart';
import 'package:dpk/config/dpk_config.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// The inline comment that marks a dependency managed by the catalog.
const catalogMarker = '# Configured via catalog';

/// Which pubspec the catalog is applied to.
enum PubspecRole {
  /// The workspace root: receives `environment` and catalog dependencies.
  root,

  /// A workspace package: receives `environment`, catalog dependencies, and
  /// the package metadata.
  package,
}

/// Values for the template variables in catalog metadata.
final class TemplateValues {
  const TemplateValues({
    required this.packagePath,
    required this.packageName,
    this.packageVersion,
  });

  /// The package path relative to the workspace root, with `/` separators.
  final String packagePath;
  final String packageName;
  final String? packageVersion;

  /// Replaces `DPK_PACKAGE_PATH`, `DPK_PACKAGE_NAME`, and
  /// `DPK_PACKAGE_VERSION` in [text], written bare, with `$`, or with `${}`.
  String expand(String text) {
    var result = text;
    for (final (name, value) in [
      ('DPK_PACKAGE_PATH', packagePath),
      ('DPK_PACKAGE_NAME', packageName),
      ('DPK_PACKAGE_VERSION', packageVersion),
    ]) {
      if (value == null) {
        continue;
      }
      result = result
          .replaceAll('\${$name}', value)
          .replaceAll('\$$name', value)
          .replaceAll(name, value);
    }
    return result;
  }
}

/// Applies [catalog] to the text of one pubspec and returns the new text.
///
/// Only values that differ are rewritten, so applying the catalog twice
/// gives the same text. Every dependency the catalog manages gets the
/// [catalogMarker] comment, and dependencies it no longer manages lose it.
String applyCatalog(
  String pubspec, {
  required Catalog catalog,
  required PubspecRole role,
  required TemplateValues values,
}) {
  final usesCrlf = pubspec.contains('\r\n');
  final source = usesCrlf ? pubspec.replaceAll('\r\n', '\n') : pubspec;
  final document = loadYaml(source);
  if (document is! YamlMap) {
    return pubspec;
  }

  final editor = YamlEditor(source);
  void set(List<Object> path, Object? value) {
    final current = _valueAt(document, path);
    if (!_deepEquals(current, value)) {
      editor.update(path, value);
    }
  }

  final environment = catalog.environment;
  if (environment != null) {
    if (document['environment'] is YamlMap) {
      for (final MapEntry(:key, :value) in environment.entries) {
        set(['environment', key], value);
      }
    } else {
      set(['environment'], environment);
    }
  }

  if (role == PubspecRole.package) {
    final templated = values;
    if (catalog.version case final version?) {
      set(['version'], version);
    }
    if (catalog.publishTo case final publishTo?) {
      set(['publish_to'], publishTo);
    }
    for (final (key, value) in [
      ('homepage', catalog.homepage),
      ('repository', catalog.repository),
      ('issue_tracker', catalog.issueTracker),
      ('documentation', catalog.documentation),
    ]) {
      if (value != null) {
        set([key], templated.expand(value));
      }
    }
    if (catalog.topics case final topics?) {
      final existing = document['topics'];
      final merged = [
        if (existing is YamlList) ...existing.map((topic) => '$topic'),
      ];
      for (final topic in topics) {
        if (!merged.contains(topic)) {
          merged.add(topic);
        }
      }
      set(['topics'], merged);
    }
    if (catalog.funding case final funding?) {
      set(['funding'], [for (final url in funding) templated.expand(url)]);
    }
    if (catalog.platforms case final platforms?) {
      set(['platforms'], platforms);
    }
    if (catalog.resolution case final resolution?) {
      set(['resolution'], resolution);
    }
  }

  final dependencies = catalog.dependencies ?? const {};
  for (final section in const ['dependencies', 'dev_dependencies']) {
    final entries = document[section];
    if (entries is! YamlMap) {
      continue;
    }
    for (final name in entries.keys.whereType<String>()) {
      if (!dependencies.containsKey(name)) {
        continue;
      }
      final wanted = dependencies[name] ?? 'any';
      final current = entries[name];
      if (wanted is String &&
          current is YamlMap &&
          current.containsKey('hosted')) {
        set([section, name, 'version'], wanted);
      } else {
        set([section, name], wanted);
      }
    }
  }

  var result = markCatalogDependencies(
    editor.toString(),
    dependencies.keys.toSet(),
  );
  if (usesCrlf) {
    result = result.replaceAll('\n', '\r\n');
  }
  return result;
}

/// Adds [catalogMarker] to every block-style dependency entry whose package
/// is in [managed], and removes it from the others. An existing inline
/// comment on a managed entry is replaced by the marker.
String markCatalogDependencies(String pubspec, Set<String> managed) {
  final YamlNode document;
  try {
    document = loadYamlNode(pubspec);
  } on YamlException {
    return pubspec;
  }
  if (document is! YamlMap) {
    return pubspec;
  }

  final lines = pubspec.split('\n');
  for (final section in const [
    'dependencies',
    'dev_dependencies',
    'dependency_overrides',
  ]) {
    final node = document.nodes[section];
    if (node is! YamlMap || node.style == CollectionStyle.FLOW) {
      continue;
    }
    for (final key in node.nodes.keys.whereType<YamlScalar>()) {
      final name = key.value;
      if (name is! String) {
        continue;
      }
      final lineIndex = key.span.start.line;
      final line = lines[lineIndex];
      final comment = inlineCommentStart(line);
      final withoutComment = comment == null
          ? line.trimRight()
          : line.substring(0, comment).trimRight();
      final hasMarker =
          comment != null && line.substring(comment).trim() == catalogMarker;

      if (managed.contains(name)) {
        lines[lineIndex] = '$withoutComment $catalogMarker';
      } else if (hasMarker) {
        lines[lineIndex] = withoutComment;
      }
    }
  }
  return lines.join('\n');
}

/// The index of the `#` that starts an inline comment in [line], ignoring
/// `#` inside quotes and `#` not preceded by whitespace.
int? inlineCommentStart(String line) {
  var inSingle = false;
  var inDouble = false;
  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == "'" && !inDouble) {
      inSingle = !inSingle;
    } else if (char == '"' && !inSingle) {
      inDouble = !inDouble;
    } else if (char == '#' &&
        !inSingle &&
        !inDouble &&
        (i == 0 || line[i - 1] == ' ' || line[i - 1] == '\t')) {
      return i;
    }
  }
  return null;
}

Object? _valueAt(YamlMap document, List<Object> path) {
  Object? current = document;
  for (final key in path) {
    if (current is! Map) {
      return null;
    }
    current = current[key];
  }
  return current;
}

bool _deepEquals(Object? a, Object? b) {
  if (a is YamlScalar) a = a.value;
  if (b is YamlScalar) b = b.value;
  if (a is num && b is String || a is String && b is num) {
    return a.toString() == b.toString();
  }
  return const DeepCollectionEquality().equals(_plain(a), _plain(b));
}

Object? _plain(Object? value) => switch (value) {
  YamlMap() || Map() => {
    for (final entry in (value as Map).entries)
      '${entry.key}': _plain(entry.value),
  },
  YamlList() || List() => [for (final item in value as List) _plain(item)],
  YamlScalar() => value.value,
  _ => value,
};
