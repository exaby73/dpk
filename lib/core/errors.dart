/// An expected failure that dpk reports as `error: <message>` and exit code
/// [exitCode], without a stack trace.
final class DpkException implements Exception {
  DpkException(this.message, {this.exitCode = 1});

  final String message;
  final int exitCode;

  @override
  String toString() => message;
}
