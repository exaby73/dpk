import 'dart:io';

import 'package:path/path.dart' as p;

/// The command line that starts the dpk that is running now.
///
/// For a compiled binary, such as one from `dart install dpk`, it is the
/// binary. For dpk running on the Dart VM, as with `dart run bin/dpk.dart` or
/// a snapshot, it is the `dart` executable, its VM options, and the script.
/// A relative `--packages` path is made absolute against [workingDirectory],
/// so the command works from any directory.
List<String> currentDpkCommand({String? workingDirectory}) {
  final executable = Platform.resolvedExecutable;
  final script = Platform.script.toFilePath();
  if (p.equals(executable, script)) {
    return [executable];
  }

  final base = workingDirectory ?? Directory.current.path;
  return [
    executable,
    for (final option in Platform.executableArguments)
      if (option.startsWith('--packages='))
        '--packages=${p.normalize(p.join(base, option.substring('--packages='.length)))}'
      else if (!option.startsWith('--resolved_executable_name=') &&
          !option.startsWith('--executable_name='))
        option,
    script,
  ];
}

/// Writes a `dpk` launcher for [command] and returns the directory that holds
/// it, ready to put first on `PATH`.
///
/// Scripts that call `dpk` then run the same dpk that started them, instead
/// of whichever dpk is installed. The directory lives in the system temp
/// directory and is named after a hash of [command], so every run of the same
/// dpk reuses it.
String writeDpkLauncher(List<String> command, {bool? windows}) {
  final isWindows = windows ?? Platform.isWindows;
  final directory = Directory(
    p.join(
      Directory.systemTemp.path,
      'dpk-launchers',
      _hash(command.join('\x00')),
    ),
  );
  final launcher = File(p.join(directory.path, isWindows ? 'dpk.cmd' : 'dpk'));
  final content = isWindows
      ? '@echo off\r\n${command.map(_quoteCmd).join(' ')} %*\r\n'
      : '#!/bin/sh\nexec ${command.map(_quoteSh).join(' ')} "\$@"\n';

  if (launcher.existsSync() && launcher.readAsStringSync() == content) {
    return directory.path;
  }

  directory.createSync(recursive: true);
  final temporary = File('${launcher.path}.$pid.tmp')
    ..writeAsStringSync(content);
  if (!isWindows) {
    Process.runSync('chmod', ['755', temporary.path]);
  }
  temporary.renameSync(launcher.path);
  return directory.path;
}

/// [path] with [directory] in front, using the platform's separator.
String prependToPath(String directory, String? path, {bool? windows}) {
  final separator = (windows ?? Platform.isWindows) ? ';' : ':';
  return path == null || path.isEmpty ? directory : '$directory$separator$path';
}

String _quoteSh(String value) => "'${value.replaceAll("'", "'\"'\"'")}'";

String _quoteCmd(String value) => '"${value.replaceAll('"', '""')}"';

/// A 64-bit FNV-1a hash of [text], as hex.
String _hash(String text) {
  var hash = 0xcbf29ce484222325;
  for (final unit in text.codeUnits) {
    hash ^= unit;
    hash *= 0x100000001b3;
  }
  return hash.toUnsigned(64).toRadixString(16).padLeft(16, '0');
}
