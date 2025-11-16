import 'dart:io';

import 'package:dpk/core/command_runner.dart';

Future<void> main(List<String> arguments) async {
  _init(arguments);
}

Future<void> _init(List<String> arguments) async {
  final runner = await DpkCommandRunner.init(arguments);
  final exitCode = await runner.runDpk();
  exit(exitCode ?? 1);
}
