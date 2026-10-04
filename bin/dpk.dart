import 'dart:io';

import 'package:dpk/core/command_runner.dart';

Future<void> main(List<String> arguments) async {
  try {
    exitCode = await runDpk(arguments);
  } catch (error, stackTrace) {
    stderr
      ..writeln('Unexpected error: $error')
      ..writeln(stackTrace)
      ..writeln(
        'This is a bug in dpk. Please report it at '
        'https://github.com/exaby73/dpk/issues',
      );
    exitCode = 70;
  }
  await Future.wait([stdout.flush(), stderr.flush()]);
  exit(exitCode);
}
