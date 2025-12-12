import 'dart:io';

final class TerminalLogUtil {
  static const int newlineByte = 0x0A;
  static const int indentLength = 4;

  static int getTerminalWidth(IOSink sink) {
    if (sink is Stdout && sink.hasTerminal) {
      return sink.terminalColumns;
    }
    return 80;
  }

  static List<List<int>> wrapLineWithAnsi(
    List<int> lineBytes,
    int maxWidth,
    List<int> indentBytes,
  ) {
    if (maxWidth <= 0) {
      return [
        <int>[...indentBytes, ...lineBytes],
      ];
    }

    final wrapped = <List<int>>[];
    var currentLine = <int>[...indentBytes];
    var visibleLength = indentBytes.length;
    var inAnsi = false;
    var ansiBuffer = <int>[];
    var lastWhitespacePos = -1;
    var lastWhitespaceVisibleLength = 0;

    for (var i = 0; i < lineBytes.length; i++) {
      final byte = lineBytes[i];

      if (byte == 0x1B) {
        inAnsi = true;
        ansiBuffer = [byte];
        currentLine.add(byte);
        continue;
      }

      if (inAnsi) {
        ansiBuffer.add(byte);
        currentLine.add(byte);
        if (byte >= 0x40 && byte <= 0x7E) {
          inAnsi = false;
          ansiBuffer = [];
        }
        continue;
      }

      final isWhitespace = byte == 0x20 || byte == 0x09;
      if (isWhitespace) {
        lastWhitespacePos = currentLine.length;
        lastWhitespaceVisibleLength = visibleLength;
      }

      if (visibleLength >= maxWidth &&
          currentLine.length > indentBytes.length) {
        if (lastWhitespacePos > indentBytes.length &&
            lastWhitespaceVisibleLength > indentBytes.length) {
          final wrappedLine = currentLine.sublist(0, lastWhitespacePos);
          final remainingBytes = currentLine.length > lastWhitespacePos + 1
              ? currentLine.sublist(lastWhitespacePos + 1)
              : <int>[];
          wrapped.add(wrappedLine);

          currentLine = <int>[...indentBytes];
          if (ansiBuffer.isNotEmpty) {
            currentLine.addAll(ansiBuffer);
          }
          currentLine.addAll(remainingBytes);
          visibleLength =
              indentBytes.length +
              (visibleLength - lastWhitespaceVisibleLength - 1);
          lastWhitespacePos = -1;
        } else {
          wrapped.add(currentLine);
          currentLine = <int>[...indentBytes];
          if (ansiBuffer.isNotEmpty) {
            currentLine.addAll(ansiBuffer);
          }
          visibleLength = indentBytes.length;
          lastWhitespacePos = -1;
        }
      }

      currentLine.add(byte);
      if (byte == 0x09) {
        visibleLength = ((visibleLength ~/ 8) + 1) * 8;
      } else if (byte >= 0x20) {
        visibleLength++;
      }
    }

    if (currentLine.isNotEmpty) {
      wrapped.add(currentLine);
    }

    return wrapped.isEmpty
        ? [
            <int>[...indentBytes, ...lineBytes],
          ]
        : wrapped;
  }

  static void setupStreamHandlers({
    required Stream<List<int>> stream,
    required String packageName,
    required IOSink outputSink,
    required int maxLineWidth,
    required List<int> indentBytes,
  }) {
    final headerBytes = '[$packageName]\n'.codeUnits;
    var buffer = <int>[];
    var hasPendingHeader = false;

    stream.listen(
      (event) {
        if (event.isEmpty) return;

        buffer.addAll(event);
        var start = 0;
        var printedHeader = false;

        for (var i = 0; i < buffer.length; i++) {
          if (buffer[i] == newlineByte) {
            final lineBytes = buffer.sublist(start, i);
            final isEmpty =
                lineBytes.isEmpty ||
                (lineBytes.length == 1 && lineBytes[0] == 0x0D);

            if (!isEmpty) {
              if (!printedHeader) {
                outputSink.add(headerBytes);
                printedHeader = true;
                hasPendingHeader = false;
              }

              final wrappedLines = wrapLineWithAnsi(
                lineBytes,
                maxLineWidth,
                indentBytes,
              );

              for (final wrappedLine in wrappedLines) {
                outputSink.add(wrappedLine);
                outputSink.add(const [newlineByte]);
              }
            } else {
              if (printedHeader) {
                outputSink.add(const [newlineByte]);
              } else {
                hasPendingHeader = true;
              }
            }

            start = i + 1;
          }
        }

        buffer = buffer.sublist(start);
      },
      onDone: () {
        if (buffer.isNotEmpty) {
          if (!hasPendingHeader) {
            outputSink.add(headerBytes);
          }
          final wrappedLines = wrapLineWithAnsi(
            buffer,
            maxLineWidth,
            indentBytes,
          );
          for (final wrappedLine in wrappedLines) {
            outputSink.add(wrappedLine);
            outputSink.add(const [newlineByte]);
          }
        }
      },
    );
  }
}
