import 'dart:math';

import 'package:collection/collection.dart';
import 'package:yaml/yaml.dart';

/// Top-level keys in sort order, split into groups. Groups are separated by
/// exactly one blank line; keys inside a group are not.
const List<List<String>> _keyGroups = [
  [
    'name',
    'description',
    'version',
    'resolution',
    'publish_to',
    'homepage',
    'repository',
    'issue_tracker',
    'documentation',
    'topics',
    'screenshots',
    'funding',
  ],
  ['platforms', 'false_secrets', 'ignored_advisories'],
  ['environment'],
  ['dependencies'],
  ['dev_dependencies'],
  ['dependency_overrides'],
  ['executables'],
  ['flutter'],
];

final List<String> _keyOrder = [for (final group in _keyGroups) ...group];

final Map<String, int> _keyGroup = {
  for (final (index, group) in _keyGroups.indexed)
    for (final key in group) key: index,
};

/// Sections whose entries are sorted by package name.
const Set<String> _dependencySections = {
  'dependencies',
  'dev_dependencies',
  'dependency_overrides',
};

/// Sorts pubspec.yaml [content] into the standard key order and sorts the
/// packages inside dependency sections alphabetically.
///
/// The sorter works on the source text: it finds where each top-level key and
/// each dependency entry starts from the YAML node spans, then reorders whole
/// blocks of lines. Every line is copied verbatim, so comments, quoting, block
/// scalars, anchors, and null values survive. Only blank lines between
/// top-level groups and between dependency entries change.
///
/// Returns [content] unchanged when it is empty, is not valid YAML, its root
/// is not a block mapping, or the sorted text would not parse to the same
/// data.
String sortPubspec(String content) {
  final usesCrlf = content.contains('\r\n');
  final text = usesCrlf ? content.replaceAll('\r\n', '\n') : content;
  if (text.trim().isEmpty || text.contains('\r')) {
    return content;
  }

  final root = _parseBlockMap(text);
  if (root == null) {
    return content;
  }

  // Sorting dependency entries can move an alias above its anchor. When the
  // result does not parse to the same data, retry with only the top-level
  // keys reordered, and give up if that fails too.
  for (final sortDependencies in [true, false]) {
    final sorted = _sortText(text, root, sortDependencies: sortDependencies);
    if (sorted == null) {
      continue;
    }
    if (sorted == text) {
      return content;
    }
    if (_isSafeRewrite(text, root, sorted)) {
      return usesCrlf ? sorted.replaceAll('\n', '\r\n') : sorted;
    }
  }
  return content;
}

/// Parses [text] and returns its root when it is a non-empty block mapping.
YamlMap? _parseBlockMap(String text) {
  try {
    final node = loadYamlNode(text);
    if (node is YamlMap &&
        node.style == CollectionStyle.BLOCK &&
        node.nodes.isNotEmpty) {
      return node;
    }
  } on Object {
    return null;
  }
  return null;
}

/// Whether [sorted] holds the same data and the same non-blank lines as
/// [original].
bool _isSafeRewrite(String original, YamlMap originalRoot, String sorted) {
  final sortedRoot = _parseBlockMap(sorted);
  if (sortedRoot == null) {
    return false;
  }
  if (!const DeepCollectionEquality().equals(originalRoot, sortedRoot)) {
    return false;
  }
  List<String> contentLines(String text) =>
      text.split('\n').where((line) => line.trim().isNotEmpty).toList()..sort();
  return const ListEquality<String>().equals(
    contentLines(original),
    contentLines(sorted),
  );
}

/// A top-level key and the lines that move with it.
class _Block {
  _Block({
    required this.name,
    required this.value,
    required this.start,
    required this.keyLine,
    required this.end,
    required this.blankBefore,
  });

  /// The key as written, unquoted.
  final String name;

  final YamlNode value;

  /// First line of the block, including comments directly above the key.
  final int start;

  final int keyLine;

  /// Last non-blank line of the block, inclusive.
  final int end;

  /// Whether a blank line separated this block from the previous one.
  final bool blankBefore;

  bool get isKnown => _keyGroup.containsKey(name);

  /// Whether to write a blank line before this block when it follows a block
  /// of [previousGroup] in the sorted output. Known keys get one between
  /// groups and none inside a group; unknown keys keep the spacing they had.
  bool needsBlankLineBefore(int? previousGroup, int group) =>
      isKnown ? group != previousGroup : blankBefore;
}

/// Reorders the top-level blocks of [text]. Returns `null` when the layout is
/// not one the sorter understands.
String? _sortText(String text, YamlMap root, {required bool sortDependencies}) {
  final lines = text.split('\n');
  var lineCount = lines.length;
  while (lineCount > 0 && _isBlank(lines[lineCount - 1])) {
    lineCount--;
  }

  final keyNodes = root.nodes.keys.cast<YamlNode>().toList();
  final keyLines = <int>[];
  for (final key in keyNodes) {
    final start = key.span.start;
    if (key is! YamlScalar ||
        start.column != 0 ||
        (keyLines.isNotEmpty && start.line <= keyLines.last)) {
      return null;
    }
    keyLines.add(start.line);
  }

  final ends = <int>[];
  for (final (i, key) in keyNodes.indexed) {
    final limit = i + 1 < keyLines.length ? keyLines[i + 1] : lineCount;
    ends.add(
      _blockEnd(lines, key, root.nodes[key]!, keyLines[i], limit, column: 0),
    );
  }

  // Comment lines directly above a key belong to that key. Anything left in
  // the gap before them stays with the previous block.
  final starts = <int>[];
  for (final (i, keyLine) in keyLines.indexed) {
    final floor = i == 0 ? -1 : ends[i - 1];
    var start = keyLine;
    while (start - 1 > floor && _isTopLevelComment(lines[start - 1])) {
      start--;
    }
    starts.add(start);
    if (i > 0) {
      ends[i - 1] = _lastNonBlank(lines, ends[i - 1], start - 1);
    }
  }

  final blocks = <_Block>[
    for (final (i, key) in keyNodes.indexed)
      _Block(
        name: (key as YamlScalar).value.toString(),
        value: root.nodes[key]!,
        start: starts[i],
        keyLine: keyLines[i],
        end: ends[i],
        blankBefore: i > 0 && starts[i] - 1 > ends[i - 1],
      ),
  ];

  final headerEnd = _lastNonBlank(lines, -1, blocks.first.start - 1);
  final trailerStart = _firstNonBlank(lines, blocks.last.end + 1, lineCount);

  final output = <String>[];
  if (headerEnd >= 0) {
    output.addAll(lines.sublist(0, headerEnd + 1));
    if (blocks.first.start - 1 > headerEnd) {
      output.add('');
    }
  }

  int? previousGroup;
  for (final (index, entry) in _orderBlocks(blocks).indexed) {
    final (block, group) = entry;
    if (index > 0) {
      if (block.needsBlankLineBefore(previousGroup, group)) {
        output.add('');
      }
    }
    previousGroup = group;

    final sortedLines =
        sortDependencies && _dependencySections.contains(block.name)
        ? _sortDependencyBlock(lines, block)
        : null;
    output.addAll(sortedLines ?? lines.sublist(block.start, block.end + 1));
  }

  if (trailerStart < lineCount) {
    if (trailerStart - 1 > blocks.last.end) {
      output.add('');
    }
    output.addAll(lines.sublist(trailerStart, lineCount));
  }

  final result = output.join('\n');
  return text.endsWith('\n') ? '$result\n' : result;
}

/// Orders [blocks] by the standard key order. Each unknown key follows the
/// nearest known key above it in the original file, or goes first when no
/// known key precedes it. Returns each block with its group index; unknown
/// keys take the group of the key they follow, or `-1` at the start.
List<(_Block, int)> _orderBlocks(List<_Block> blocks) {
  final leading = <_Block>[];
  final followers = <String, List<_Block>>{};
  final known = <String, _Block>{};
  String? lastKnown;
  for (final block in blocks) {
    if (block.isKnown) {
      known[block.name] = block;
      lastKnown = block.name;
    } else if (lastKnown == null) {
      leading.add(block);
    } else {
      followers.putIfAbsent(lastKnown, () => []).add(block);
    }
  }

  return [
    for (final block in leading) (block, -1),
    for (final name in _keyOrder)
      if (known[name] case final block?) ...[
        (block, _keyGroup[name]!),
        for (final follower in followers[name] ?? const <_Block>[])
          (follower, _keyGroup[name]!),
      ],
  ];
}

/// Returns the lines of a dependency [block] with its entries sorted by
/// package name, or `null` to keep the block as written.
List<String>? _sortDependencyBlock(List<String> lines, _Block block) {
  final value = block.value;
  if (value is! YamlMap ||
      value.style != CollectionStyle.BLOCK ||
      value.nodes.isEmpty) {
    return null;
  }

  final keyNodes = value.nodes.keys.cast<YamlNode>().toList();
  final column = keyNodes.first.span.start.column;
  final keyLines = <int>[];
  for (final key in keyNodes) {
    final start = key.span.start;
    if (key is! YamlScalar ||
        start.column != column ||
        column == 0 ||
        start.line <= (keyLines.isEmpty ? block.keyLine : keyLines.last) ||
        start.line > block.end) {
      return null;
    }
    keyLines.add(start.line);
  }

  final ends = <int>[];
  for (final (i, key) in keyNodes.indexed) {
    final limit = i + 1 < keyLines.length ? keyLines[i + 1] : block.end + 1;
    ends.add(
      _blockEnd(
        lines,
        key,
        value.nodes[key]!,
        keyLines[i],
        limit,
        column: column,
      ),
    );
  }

  // Comment lines directly above an entry move with it. Other comments in
  // the gap stay with the previous entry; blank lines between entries go.
  final entries = <(String, List<String>)>[];
  final starts = <int>[];
  for (final (i, keyLine) in keyLines.indexed) {
    final floor = i == 0 ? block.keyLine : ends[i - 1];
    var start = keyLine;
    while (start - 1 > floor && _isComment(lines[start - 1])) {
      start--;
    }
    starts.add(start);
  }
  for (final (i, key) in keyNodes.indexed) {
    final gapEnd = i + 1 < keyLines.length ? starts[i + 1] : ends[i] + 1;
    entries.add((
      (key as YamlScalar).value.toString(),
      [
        ...lines.sublist(starts[i], ends[i] + 1),
        ...lines.sublist(ends[i] + 1, gapEnd).where((l) => !_isBlank(l)),
      ],
    ));
  }

  final sorted = entries.sortedBy<String>((entry) => entry.$1);
  return [
    ...lines.sublist(block.start, block.keyLine + 1),
    ...lines.sublist(block.keyLine + 1, starts.first),
    for (final (_, entryLines) in sorted) ...entryLines,
    ...lines.sublist(ends.last + 1, block.end + 1),
  ];
}

/// Returns the last line of the entry whose key is on [keyLine]: the last
/// line of its value, extended over following lines indented deeper than
/// [column] (blank lines count only when such a line follows them). Never
/// reaches [limit].
int _blockEnd(
  List<String> lines,
  YamlNode key,
  YamlNode value,
  int keyLine,
  int limit, {
  required int column,
}) {
  var end = max(keyLine, min(_lastContentLine(value), limit - 1));
  end = max(end, min(_lastContentLine(key), limit - 1));
  for (var line = end + 1; line < limit; line++) {
    final text = lines[line];
    if (_isBlank(text)) {
      continue;
    }
    if (_indentOf(text) <= column) {
      break;
    }
    end = line;
  }
  return end;
}

/// Returns the last line holding content of [node]. Block collection spans
/// run on to the next token, past trailing comments, so they are measured by
/// their last child instead.
int _lastContentLine(YamlNode node) {
  final children = switch (node) {
    YamlMap(style: CollectionStyle.BLOCK, :final nodes) => [
      for (final MapEntry(:key, :value) in nodes.entries) ...[
        key as YamlNode,
        value,
      ],
    ],
    YamlList(style: CollectionStyle.BLOCK, :final nodes) => nodes,
    _ => const <YamlNode>[],
  };
  if (children.isNotEmpty) {
    return children.map(_lastContentLine).reduce(max);
  }
  final span = node.span;
  final end = span.end;
  return end.column == 0 && end.line > span.start.line
      ? end.line - 1
      : end.line;
}

/// Returns the last non-blank line in `(floor, to]`, or [floor] if none.
int _lastNonBlank(List<String> lines, int floor, int to) {
  for (var line = to; line > floor; line--) {
    if (!_isBlank(lines[line])) {
      return line;
    }
  }
  return floor;
}

/// Returns the first non-blank line in `[from, limit)`, or [limit] if none.
int _firstNonBlank(List<String> lines, int from, int limit) {
  for (var line = from; line < limit; line++) {
    if (!_isBlank(lines[line])) {
      return line;
    }
  }
  return limit;
}

bool _isBlank(String line) => line.trim().isEmpty;

bool _isComment(String line) => line.trimLeft().startsWith('#');

bool _isTopLevelComment(String line) => line.startsWith('#');

int _indentOf(String line) => line.length - line.trimLeft().length;
