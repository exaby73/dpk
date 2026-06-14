import 'dart:io';

String getShell() {
  if (Platform.isWindows) {
    return Platform.environment['COMSPEC'] ?? 'cmd.exe';
  }

  return Platform.environment['SHELL'] ?? '/bin/sh';
}

List<String> getShellCommandArgs(String command) {
  if (Platform.isWindows) {
    return ['/C', command];
  }

  return ['-c', command];
}

String shellQuote(String value) {
  if (value.isEmpty) {
    return "''";
  }

  return "'${value.replaceAll("'", "'\"'\"'")}'";
}
