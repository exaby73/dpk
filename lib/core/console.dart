import 'dart:io';

/// Writes dpk's own messages.
///
/// Child processes started by dpk write to the terminal directly. Everything
/// dpk prints itself goes through a [Console], so tests can capture it and
/// so colors and verbosity follow one set of rules.
final class Console {
  Console({
    required this.out,
    required this.err,
    this.useColor = false,
    this.isStdio = false,
    this.hasTerminal = false,
    this.terminalColumns = 80,
  });

  /// A console that writes to the process's stdout and stderr.
  ///
  /// Colors are on when stderr is a terminal and `NO_COLOR` is not set,
  /// unless [color] overrides it.
  factory Console.stdio({bool? color}) {
    final hasTerminal = stdout.hasTerminal && stderr.hasTerminal;
    final noColor = Platform.environment.containsKey('NO_COLOR');
    return Console(
      out: stdout,
      err: stderr,
      useColor:
          color ??
          (!noColor && stderr.hasTerminal && stderr.supportsAnsiEscapes),
      isStdio: true,
      hasTerminal: hasTerminal,
      terminalColumns: stdout.hasTerminal ? stdout.terminalColumns : 80,
    );
  }

  /// A console that collects output in memory.
  factory Console.buffered() =>
      Console(out: StringBuffer(), err: StringBuffer());

  final StringSink out;
  final StringSink err;
  final bool useColor;

  /// Whether [out] and [err] are the real stdout and stderr, so child
  /// processes can inherit them.
  final bool isStdio;

  /// Whether stdout and stderr are both attached to a terminal.
  final bool hasTerminal;
  final int terminalColumns;

  /// Prints [detail] messages.
  bool verbose = false;

  /// Hides [step] messages.
  bool quiet = false;

  /// Prints a result line to stdout.
  void info(String message) => out.writeln(message);

  /// Prints an error to stderr.
  void error(String message) => err.writeln('${red('error')}: $message');

  /// Prints a warning to stderr.
  void warning(String message) => err.writeln('${yellow('warning')}: $message');

  /// Prints a progress line, such as the script dpk is about to run, to
  /// stderr so it never mixes into piped script output.
  void step(String message) {
    if (!quiet) {
      err.writeln(dim(message));
    }
  }

  /// Prints a message only in verbose mode.
  void detail(String message) {
    if (verbose) {
      err.writeln(dim(message));
    }
  }

  String bold(String text) => _wrap(text, '1');
  String dim(String text) => _wrap(text, '2');
  String red(String text) => _wrap(text, '31');
  String green(String text) => _wrap(text, '32');
  String yellow(String text) => _wrap(text, '33');
  String cyan(String text) => _wrap(text, '36');

  /// Colors used to tell workspace packages apart in parallel output.
  static const _packageColors = ['36', '35', '34', '33', '32', '96', '95'];

  String packageColor(String text, int index) =>
      _wrap(text, _packageColors[index % _packageColors.length]);

  String _wrap(String text, String code) =>
      useColor ? '\x1b[${code}m$text\x1b[0m' : text;

  /// Text written to a buffered console's stdout.
  String get outText => out.toString();

  /// Text written to a buffered console's stderr.
  String get errText => err.toString();
}
