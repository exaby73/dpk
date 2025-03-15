extension StringExtensions on String {
  String trimIndents() {
    final lines = trim().split('\n');

    final nonEmptyLines =
        lines.where((line) => line.trim().isNotEmpty).toList();
    if (nonEmptyLines.isEmpty) return '';

    int minIndent = nonEmptyLines.fold(double.maxFinite.toInt(), (min, line) {
      final leadingSpaces = line.length - line.trimLeft().length;
      return leadingSpaces < min ? leadingSpaces : min;
    });

    return lines
        .map((line) {
          if (line.trim().isEmpty) return '';
          return line.length > minIndent ? line.substring(minIndent) : line;
        })
        .join('\n');
  }
}
