import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Key order for pubspec.yaml with null markers for blank lines
const List<String?> _pubspecKeyOrder = [
  'name',
  'description',
  'version',
  'publish_to',
  'homepage',
  'repository',
  'issue_tracker',
  'documentation',
  'topics',
  'screenshots',
  'funding',
  null, // blank line
  'platforms',
  'false_secrets',
  'ignored_advisories',
  null, // blank line
  'environment',
  null, // blank line
  'dependencies',
  null, // blank line
  'dev_dependencies',
  null, // blank line
  'dependency_overrides',
  null, // blank line
  'executables',
  null, // blank line
  'flutter',
];

/// Known keys from the order list (excluding null markers)
final Set<String> _knownKeys = _pubspecKeyOrder.whereType<String>().toSet();

/// Sections that contain package dependencies (to be sorted alphabetically)
const Set<String> _dependencySections = {
  'dependencies',
  'dev_dependencies',
  'dependency_overrides',
};

/// Represents a key entry extracted from the pubspec content
class KeyEntry {
  final String keyName;
  final String leadingComments;
  final String? inlineComment;
  final List<NestedKeyEntry> nestedEntries;

  const KeyEntry({
    required this.keyName,
    required this.leadingComments,
    required this.inlineComment,
    required this.nestedEntries,
  });
}

/// Represents a nested key entry (for dependency sections)
class NestedKeyEntry {
  final String keyName;
  final String leadingComments;
  final String? inlineComment;
  final String?
  rawValueBlock; // For complex values (maps), stores the full raw text

  const NestedKeyEntry({
    required this.keyName,
    required this.leadingComments,
    required this.inlineComment,
    this.rawValueBlock,
  });

  /// Returns true if this entry has a complex value (map/list) that needs raw preservation
  bool get hasComplexValue => rawValueBlock != null;
}

/// Sorts pubspec.yaml content according to standard key order.
/// Preserves comments (inline and standalone).
/// Sorts package names alphabetically within dependency sections ONLY.
/// Other nested maps (flutter, executables, etc.) are preserved as-is.
String sortPubspec(String content) {
  if (content.trim().isEmpty) {
    return content;
  }

  // Parse original YAML to get structure and values
  final yaml = loadYaml(content);
  if (yaml is! YamlMap || yaml.isEmpty) {
    return content;
  }

  final originalValues = <String, dynamic>{};
  for (final MapEntry(:key, :value) in yaml.entries) {
    originalValues[key as String] = value;
  }

  // Extract key entries from raw string
  final entries = _extractKeyEntries(content);
  if (entries.isEmpty) {
    return content;
  }

  // Sort entries according to key order
  final sortedEntries = _sortEntries(entries);

  // Collect packages with complex values (to skip in placeholder filling)
  final complexValuePackages = <(String, String)>{};
  for (final entry in sortedEntries) {
    if (_dependencySections.contains(entry.keyName)) {
      for (final nested in entry.nestedEntries) {
        if (nested.hasComplexValue) {
          complexValuePackages.add((entry.keyName, nested.keyName));
        }
      }
    }
  }

  // Build placeholder skeleton
  final skeleton = _buildPlaceholderSkeleton(sortedEntries);

  // Fill placeholders with yaml_edit
  return _fillPlaceholders(skeleton, originalValues, complexValuePackages);
}

/// Extracts key entries from the raw pubspec content
List<KeyEntry> _extractKeyEntries(String content) {
  final lines = content.split('\n');
  final entries = <KeyEntry>[];
  final topLevelKeyPattern = RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]*):');
  final nestedKeyPattern = RegExp(r'^  ([a-zA-Z_][a-zA-Z0-9_-]*):');

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    final match = topLevelKeyPattern.firstMatch(line);

    if (match != null) {
      final keyName = match.group(1)!;

      // Collect leading comments (look back)
      final leadingComments = _collectLeadingComments(lines, i, entries);

      // Extract inline comment from the key line
      final inlineComment = _extractInlineComment(line);

      // Collect nested entries if this is a dependency section
      final nestedEntries = <NestedKeyEntry>[];
      if (_dependencySections.contains(keyName)) {
        i++;
        while (i < lines.length) {
          final nestedLine = lines[i];

          // Check if we've hit the next top-level key
          if (topLevelKeyPattern.hasMatch(nestedLine)) {
            break;
          }

          final nestedMatch = nestedKeyPattern.firstMatch(nestedLine);
          if (nestedMatch != null) {
            final nestedKeyName = nestedMatch.group(1)!;
            final nestedLeadingComments = _collectNestedLeadingComments(
              lines,
              i,
              nestedEntries,
            );
            final nestedInlineComment = _extractInlineComment(nestedLine);

            // Check if this is a complex value (line ends with just ":" after removing comment)
            final lineWithoutComment = nestedInlineComment != null
                ? nestedLine.substring(0, nestedLine.indexOf('#')).trimRight()
                : nestedLine.trimRight();
            final isComplexValue = lineWithoutComment.endsWith(':');
            String? rawValueBlock;

            if (isComplexValue) {
              // Capture all lines that belong to this complex value
              // Strip inline comment from first line since it's stored separately
              final firstLine = nestedInlineComment != null
                  ? lineWithoutComment
                  : nestedLine;
              final valueLines = <String>[firstLine];
              final keyIndent = nestedLine.indexOf(nestedKeyName);
              i++;

              while (i < lines.length) {
                final valueLine = lines[i];
                // Check if this line is more indented than the key or is a comment/blank
                if (valueLine.isEmpty ||
                    (valueLine.startsWith(' ') &&
                        _getIndentLevel(valueLine) > keyIndent)) {
                  valueLines.add(valueLine);
                  i++;
                } else {
                  break;
                }
              }

              rawValueBlock = valueLines.join('\n');
              // Don't increment i here as we've already moved past the value
            } else {
              i++;
            }

            nestedEntries.add(
              NestedKeyEntry(
                keyName: nestedKeyName,
                leadingComments: nestedLeadingComments,
                inlineComment: nestedInlineComment,
                rawValueBlock: rawValueBlock,
              ),
            );
          } else {
            i++;
          }
        }
      } else {
        // Skip to next top-level key
        i++;
        while (i < lines.length && !topLevelKeyPattern.hasMatch(lines[i])) {
          i++;
        }
      }

      entries.add(
        KeyEntry(
          keyName: keyName,
          leadingComments: leadingComments,
          inlineComment: inlineComment,
          nestedEntries: nestedEntries,
        ),
      );
    } else {
      i++;
    }
  }

  return entries;
}

/// Collects leading comments for a top-level key
String _collectLeadingComments(
  List<String> lines,
  int keyIndex,
  List<KeyEntry> existingEntries,
) {
  final comments = <String>[];

  // Find the end of the previous entry (or start of file)
  var startIndex = 0;
  if (existingEntries.isNotEmpty) {
    // Find where the previous entry ends
    final prevKey = existingEntries.last.keyName;
    final topLevelKeyPattern = RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]*):');

    for (var j = keyIndex - 1; j >= 0; j--) {
      final match = topLevelKeyPattern.firstMatch(lines[j]);
      if (match != null && match.group(1) == prevKey) {
        startIndex = j + 1;
        // Skip past the content of the previous key
        while (startIndex < keyIndex) {
          final line = lines[startIndex];
          if (line.trim().isEmpty ||
              line.trim().startsWith('#') ||
              topLevelKeyPattern.hasMatch(line)) {
            break;
          }
          startIndex++;
        }
        break;
      }
    }
  }

  // Collect comments and blank lines before this key
  for (var j = keyIndex - 1; j >= startIndex; j--) {
    final line = lines[j];
    if (line.trim().isEmpty || line.trim().startsWith('#')) {
      comments.insert(0, line);
    } else {
      break;
    }
  }

  // Remove leading blank lines but keep trailing ones before the key
  while (comments.isNotEmpty && comments.first.trim().isEmpty) {
    comments.removeAt(0);
  }

  return comments.join('\n');
}

/// Collects leading comments for a nested key
String _collectNestedLeadingComments(
  List<String> lines,
  int keyIndex,
  List<NestedKeyEntry> existingEntries,
) {
  final comments = <String>[];

  for (var j = keyIndex - 1; j >= 0; j--) {
    final line = lines[j];
    // Stop if we hit a non-comment, non-empty line or a key
    if (line.trim().isNotEmpty && !line.trim().startsWith('#')) {
      break;
    }
    if (line.trim().startsWith('#')) {
      comments.insert(0, line);
    }
  }

  return comments.join('\n');
}

/// Extracts inline comment from a line, handling quoted strings
String? _extractInlineComment(String line) {
  var inSingleQuote = false;
  var inDoubleQuote = false;

  for (var i = 0; i < line.length; i++) {
    final char = line[i];

    if (char == "'" && !inDoubleQuote) inSingleQuote = !inSingleQuote;
    if (char == '"' && !inSingleQuote) inDoubleQuote = !inDoubleQuote;

    if (char == '#' && !inSingleQuote && !inDoubleQuote) {
      return line.substring(i).trim();
    }
  }
  return null;
}

/// Sorts entries according to the key order, handling unknown keys
List<KeyEntry> _sortEntries(List<KeyEntry> entries) {
  // Build map: unknownKey -> predecessorKey
  final predecessors = <String, String?>{};
  for (var i = 0; i < entries.length; i++) {
    if (!_knownKeys.contains(entries[i].keyName)) {
      predecessors[entries[i].keyName] = i > 0 ? entries[i - 1].keyName : null;
    }
  }

  // Sort known keys, then insert unknown keys after their predecessors
  final result = <KeyEntry>[];
  for (final knownKey in _pubspecKeyOrder.whereType<String>()) {
    final entry = entries.where((e) => e.keyName == knownKey).firstOrNull;
    if (entry != null) {
      result.add(entry);
      // Add any unknown keys that follow this one
      for (final MapEntry(:key, :value) in predecessors.entries) {
        if (value == knownKey) {
          result.add(entries.firstWhere((e) => e.keyName == key));
        }
      }
    }
  }

  // Handle unknown keys at start (no predecessor)
  for (final MapEntry(:key, :value) in predecessors.entries) {
    if (value == null && !result.any((e) => e.keyName == key)) {
      result.insert(0, entries.firstWhere((e) => e.keyName == key));
    }
  }

  return result;
}

/// Gets the indentation level of a line (number of leading spaces)
int _getIndentLevel(String line) {
  var count = 0;
  for (final char in line.codeUnits) {
    if (char == 32) {
      // space
      count++;
    } else {
      break;
    }
  }
  return count;
}

/// Gets the group index for a key (groups are separated by null in the order)
int _getGroupIndex(String keyName) {
  var groupIndex = 0;
  for (final item in _pubspecKeyOrder) {
    if (item == null) {
      groupIndex++;
    } else if (item == keyName) {
      return groupIndex;
    }
  }
  // Unknown key - return -1
  return -1;
}

/// Builds a placeholder skeleton with sorted keys
String _buildPlaceholderSkeleton(List<KeyEntry> sortedEntries) {
  final buffer = StringBuffer();
  var lastGroupIndex = -1;

  for (var i = 0; i < sortedEntries.length; i++) {
    final entry = sortedEntries[i];
    final currentGroupIndex = _getGroupIndex(entry.keyName);

    // Add blank line when transitioning to a new group (except for first entry)
    // Unknown keys (group -1) inherit their predecessor's group
    if (i > 0 &&
        currentGroupIndex != -1 &&
        currentGroupIndex != lastGroupIndex) {
      buffer.writeln();
    }

    if (currentGroupIndex != -1) {
      lastGroupIndex = currentGroupIndex;
    }

    // Add leading comments
    if (entry.leadingComments.isNotEmpty) {
      buffer.writeln(entry.leadingComments);
    }

    // Add key with PLACEHOLDER
    if (_dependencySections.contains(entry.keyName)) {
      // ONLY dependency sections get nested key sorting
      buffer.writeln('${entry.keyName}:');

      // Sort nested entries alphabetically
      final sortedNested = entry.nestedEntries.toList()
        ..sort((a, b) => a.keyName.compareTo(b.keyName));

      for (final nestedEntry in sortedNested) {
        // Add nested leading comments
        if (nestedEntry.leadingComments.isNotEmpty) {
          buffer.writeln(nestedEntry.leadingComments);
        }

        if (nestedEntry.hasComplexValue) {
          // Use the raw value block to preserve internal comments
          // Add inline comment to the first line if present
          if (nestedEntry.inlineComment != null) {
            final lines = nestedEntry.rawValueBlock!.split('\n');
            lines[0] = '${lines[0].trimRight()} ${nestedEntry.inlineComment}';
            buffer.writeln(lines.join('\n'));
          } else {
            buffer.writeln(nestedEntry.rawValueBlock);
          }
        } else {
          final comment = nestedEntry.inlineComment != null
              ? ' ${nestedEntry.inlineComment}'
              : '';
          buffer.writeln('  ${nestedEntry.keyName}: PLACEHOLDER$comment');
        }
      }
    } else {
      // All other keys get a single PLACEHOLDER
      final comment = entry.inlineComment != null
          ? ' ${entry.inlineComment}'
          : '';
      buffer.writeln('${entry.keyName}: PLACEHOLDER$comment');
    }
  }

  return buffer.toString();
}

/// Fills placeholders with actual values from the original YAML
String _fillPlaceholders(
  String skeleton,
  Map<String, dynamic> originalValues,
  Set<(String, String)> complexValuePackages,
) {
  final editor = YamlEditor(skeleton);

  for (final MapEntry(:key, :value) in originalValues.entries) {
    if (_dependencySections.contains(key) && value is YamlMap) {
      // Update each package individually
      for (final MapEntry(key: package, value: depValue) in value.entries) {
        // Skip packages with complex values (already in skeleton)
        if (complexValuePackages.contains((key, package))) {
          continue;
        }
        editor.update([key, package], depValue);
      }
    } else {
      editor.update([key], value);
    }
  }

  return editor.toString();
}
