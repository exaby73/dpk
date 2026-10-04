import 'dart:io';

import 'package:dpk/core/console.dart';

/// Shows [title] in the terminal while [body] runs, then restores the
/// previous title.
///
/// Uses the xterm title stack (`CSI 22;0t` saves, `CSI 23;0t` restores), so
/// the user's own title comes back instead of a guess. Does nothing when the
/// console is not an interactive terminal.
Future<T> withTerminalTitle<T>(
  Console console,
  String title,
  Future<T> Function() body,
) async {
  final enabled =
      console.isStdio &&
      console.hasTerminal &&
      Platform.environment['TERM'] != 'dumb' &&
      !Platform.isWindows;
  if (!enabled) {
    return body();
  }

  stdout.write('\x1b[22;0t\x1b]0;$title\x07');
  try {
    return await body();
  } finally {
    stdout.write('\x1b[23;0t');
  }
}
