import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// A problem in a dpk config file, with the position of the offending node.
final class ConfigException implements Exception {
  ConfigException(this.message, {this.span, this.file});

  final String message;
  final SourceSpanLike? span;
  final String? file;

  @override
  String toString() {
    final location = [
      if (file != null) file,
      if (span != null) ...['${span!.line + 1}', '${span!.column + 1}'],
    ].join(':');
    return location.isEmpty ? message : '$location: $message';
  }
}

/// The parts of a YAML span that error messages need.
final class SourceSpanLike {
  const SourceSpanLike(this.line, this.column);

  factory SourceSpanLike.of(YamlNode node) =>
      SourceSpanLike(node.span.start.line, node.span.start.column);

  final int line;
  final int column;
}

/// A deprecation or other non-fatal note about a config file.
final class ConfigWarning {
  const ConfigWarning(this.message, {this.span, this.file});

  final String message;
  final SourceSpanLike? span;
  final String? file;

  @override
  String toString() =>
      ConfigException(message, span: span, file: file).toString();
}

/// Typed access to a YAML mapping, with errors that name the file, the
/// position, and the key path.
final class ConfigReader {
  ConfigReader(this.map, {required this.file, this.path = const []});

  final YamlMap map;

  /// The file name used in messages, relative to the working directory when
  /// possible.
  final String file;

  /// Key path from the document root to [map].
  final List<String> path;

  final List<ConfigWarning> warnings = [];

  String keyPath(String key) => [...path, key].join('.');

  ConfigException error(String message, {Object? key}) {
    final node = key == null ? map : (_keyNode(key) ?? map);
    return ConfigException(message, span: SourceSpanLike.of(node), file: file);
  }

  ConfigException valueError(String key, String message) {
    final node = map.nodes[key] ?? _keyNode(key) ?? map;
    return ConfigException(
      '${keyPath(key)}: $message',
      span: SourceSpanLike.of(node),
      file: file,
    );
  }

  void warn(String message, {Object? key}) {
    final node = key == null ? map : (_keyNode(key) ?? map);
    warnings.add(
      ConfigWarning(message, span: SourceSpanLike.of(node), file: file),
    );
  }

  YamlNode? _keyNode(Object key) {
    for (final node in map.nodes.keys) {
      if (node is YamlNode && node.value == key) {
        return node;
      }
    }
    return null;
  }

  bool has(String key) => map.containsKey(key);

  /// Rejects keys outside [allowed], suggesting the closest key from
  /// [suggestions], which defaults to [allowed].
  void checkKeys(Iterable<String> allowed, {Iterable<String>? suggestions}) {
    final allowedSet = allowed.toSet();
    for (final key in map.keys) {
      if (key is! String) {
        throw error('Keys must be strings.', key: key);
      }
      if (allowedSet.contains(key)) {
        continue;
      }
      final suggestion = closestMatch(key, suggestions ?? allowedSet);
      final where = path.isEmpty ? 'at the top level' : 'in ${path.join('.')}';
      throw error(
        'Unknown key "$key" $where.'
        '${suggestion == null ? '' : ' Did you mean "$suggestion"?'}',
        key: key,
      );
    }
  }

  String? string(String key) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    if (value is num || value is bool) {
      return value.toString();
    }
    throw valueError(key, 'expected text, found ${describe(value)}.');
  }

  String requiredString(String key) {
    final value = string(key);
    if (value == null || value.trim().isEmpty) {
      throw error(
        '${keyPath(key)} is required.',
        key: map.containsKey(key) ? key : null,
      );
    }
    return value;
  }

  bool? boolean(String key) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    if (value is bool) {
      return value;
    }
    throw valueError(key, 'expected true or false, found ${describe(value)}.');
  }

  int? integer(String key, {int min = 1}) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    if (value is int && value >= min) {
      return value;
    }
    throw valueError(
      key,
      'expected a whole number of at least $min, found ${describe(value)}.',
    );
  }

  List<String>? stringList(String key) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    if (value is! YamlList) {
      throw valueError(
        key,
        'expected a list, found ${describe(value)}. '
        'Write each item on its own line starting with "- ".',
      );
    }
    final result = <String>[];
    for (final item in value.nodes) {
      final itemValue = item.value;
      if (itemValue is String) {
        result.add(itemValue);
      } else if (itemValue is num || itemValue is bool) {
        result.add(itemValue.toString());
      } else {
        throw ConfigException(
          '${keyPath(key)}: list items must be text, found '
          '${describe(itemValue)}.',
          span: SourceSpanLike.of(item),
          file: file,
        );
      }
    }
    return result;
  }

  /// A mapping of text keys to scalar values, converted to text.
  Map<String, String>? stringMap(String key) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    if (value is! YamlMap) {
      throw valueError(key, 'expected a mapping, found ${describe(value)}.');
    }
    final result = <String, String>{};
    for (final MapEntry(key: entryKey, value: node) in value.nodes.entries) {
      final name = (entryKey as YamlNode).value;
      final entryValue = node.value;
      if (name is! String) {
        throw ConfigException(
          '${keyPath(key)}: keys must be text.',
          span: SourceSpanLike.of(entryKey),
          file: file,
        );
      }
      if (entryValue is String || entryValue is num || entryValue is bool) {
        result[name] = entryValue.toString();
      } else {
        throw ConfigException(
          '${keyPath(key)}.$name: expected text, found '
          '${describe(entryValue)}.',
          span: SourceSpanLike.of(node),
          file: file,
        );
      }
    }
    return result;
  }

  ConfigReader? child(String key) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    if (value is! YamlMap) {
      throw valueError(key, 'expected a mapping, found ${describe(value)}.');
    }
    return ConfigReader(value, file: file, path: [...path, key]);
  }

  /// Merges warnings from [child] readers into this one.
  void adoptWarnings(ConfigReader child) => warnings.addAll(child.warnings);
}

/// Loads [content] as a YAML mapping for config parsing.
YamlMap loadConfigMap(String content, {required String file}) {
  final Object? document;
  try {
    document = loadYaml(content, sourceUrl: Uri.file(file));
  } on YamlException catch (e) {
    throw ConfigException(
      e.message,
      span: e.span == null
          ? null
          : SourceSpanLike(e.span!.start.line, e.span!.start.column),
      file: file,
    );
  }
  if (document == null) {
    throw ConfigException(
      'The file is empty. It needs at least a "version" key.',
      file: file,
    );
  }
  if (document is! YamlMap) {
    throw ConfigException(
      'Expected a mapping of keys to values at the top level.',
      file: file,
    );
  }
  return document;
}

/// A short description of a YAML value's type for error messages.
String describe(Object? value) => switch (value) {
  null => 'nothing',
  String() => 'text',
  bool() => 'true or false',
  int() || double() => 'a number',
  YamlList() || List() => 'a list',
  YamlMap() || Map() => 'a mapping',
  _ => 'an unsupported value',
};

/// Converts a YAML value into plain Dart maps, lists, and scalars, so it can
/// be written back with `yaml_edit`.
Object? toPlain(Object? value) => switch (value) {
  YamlMap() => {
    for (final entry in value.entries)
      entry.key as Object: toPlain(entry.value),
  },
  YamlList() => [for (final item in value) toPlain(item)],
  YamlScalar() => value.value,
  _ => value,
};

/// [path] relative to the current directory when that is shorter.
String displayPath(String path) {
  final relative = p.relative(path);
  return relative.length < path.length && !relative.startsWith('../..')
      ? relative
      : path;
}

/// The candidate in [options] closest to [input], when close enough to be a
/// likely typo.
String? closestMatch(String input, Iterable<String> options) {
  String? best;
  var bestDistance = 1 << 30;
  for (final option in options) {
    final distance = _editDistance(input.toLowerCase(), option.toLowerCase());
    if (distance < bestDistance) {
      best = option;
      bestDistance = distance;
    }
  }
  final limit = input.length <= 4 ? 1 : (input.length <= 8 ? 2 : 3);
  return bestDistance <= limit ? best : null;
}

int _editDistance(String a, String b) {
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      current[j] = [
        previous[j] + 1,
        current[j - 1] + 1,
        previous[j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y);
    }
    previous = current;
  }
  return previous[b.length];
}
