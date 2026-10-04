import 'dart:io';

/// The shell that runs script commands: `/bin/sh` on macOS and Linux, and
/// `cmd.exe` on Windows. Scripts run in the same shell for every teammate,
/// whatever their login shell is.
({String executable, List<String> arguments}) shellCommand(
  String command, {
  bool? windows,
}) {
  if (windows ?? Platform.isWindows) {
    return (
      executable: Platform.environment['COMSPEC'] ?? 'cmd.exe',
      arguments: ['/d', '/s', '/c', command],
    );
  }
  return (executable: '/bin/sh', arguments: ['-c', command]);
}

/// [command] followed by [arguments], each quoted for the shell so it
/// reaches the script as one argument.
String withArguments(String command, List<String> arguments, {bool? windows}) {
  if (arguments.isEmpty) {
    return command;
  }
  final quote = (windows ?? Platform.isWindows) ? _quoteCmd : shellQuote;
  return [command, ...arguments.map(quote)].join(' ');
}

/// Quotes [value] for a POSIX shell, leaving plain words unquoted.
String shellQuote(String value) {
  if (value.isEmpty) {
    return "''";
  }
  if (RegExp(r'^[A-Za-z0-9_@%+=:,./-]+$').hasMatch(value)) {
    return value;
  }
  return "'${value.replaceAll("'", "'\"'\"'")}'";
}

String _quoteCmd(String value) {
  if (value.isEmpty) {
    return '""';
  }
  if (RegExp(r'^[A-Za-z0-9_@+=:,./\\-]+$').hasMatch(value)) {
    return value;
  }
  return '"${value.replaceAll('"', r'\"')}"';
}
