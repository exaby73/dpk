/// Utilities for adding inline comments to catalog-managed dependencies.

/// Adds "# Configured via catalog" inline comment to all dependencies
/// listed in the catalog.
///
/// This function processes the YAML string line-by-line to add comments
/// to both simple (string) and complex (map) dependencies. Existing inline
/// comments are replaced with the catalog comment.
///
/// Example:
/// ```dart
/// final yaml = '''
/// dependencies:
///   meta: 1.15.0
/// ''';
/// final result = addCatalogCommentsToDependencies(yaml, {'meta'});
/// // Result:
/// // dependencies:
/// //   meta: 1.15.0 # Configured via catalog
/// ```
String addCatalogCommentsToDependencies(
  String yamlContent,
  Set<String> catalogDependencyNames,
) {
  if (catalogDependencyNames.isEmpty) {
    return yamlContent;
  }

  final lines = yamlContent.split('\n');
  final result = <String>[];

  String? currentSection; // 'dependencies' or 'dev_dependencies'
  final depKeyPattern = RegExp(r'^  ([a-zA-Z_][a-zA-Z0-9_-]*):(.*)$');
  final sectionPattern = RegExp(r'^(dependencies|dev_dependencies):');
  final topLevelPattern = RegExp(r'^[a-zA-Z_]'); // Detect end of section

  for (final line in lines) {
    // Track which section we're in
    final sectionMatch = sectionPattern.firstMatch(line);
    if (sectionMatch != null) {
      currentSection = sectionMatch.group(1);
      result.add(line);
      continue;
    }

    // Exit section if we hit a non-indented key
    if (currentSection != null && topLevelPattern.hasMatch(line)) {
      currentSection = null;
    }

    // Process dependency lines (only at 2-space indentation, not nested)
    if (currentSection != null) {
      // Only match lines that start with exactly 2 spaces (not more)
      if (line.startsWith('  ') && !line.startsWith('   ')) {
        final depMatch = depKeyPattern.firstMatch(line);
        if (depMatch != null) {
          final packageName = depMatch.group(1)!;

          if (catalogDependencyNames.contains(packageName)) {
            // Extract any existing comment
            final existingComment = _extractInlineComment(line);

            // Build new line with catalog comment
            final lineWithoutComment = existingComment != null
                ? line.substring(0, line.indexOf('#')).trimRight()
                : line.trimRight();

            result.add('$lineWithoutComment # Configured via catalog');
            continue;
          }
        }
      }
    }

    // Default: keep line as-is
    result.add(line);
  }

  return result.join('\n');
}

/// Extracts inline comment from a line, handling quoted strings.
///
/// This function is quote-aware and will not treat '#' inside quoted strings
/// as comment markers.
///
/// Returns the comment (including the '#') if found, null otherwise.
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
