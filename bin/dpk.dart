import 'dart:io';

import 'package:cli_launcher/cli_launcher.dart';
import 'package:dpk/core/command_runner.dart';
import 'package:dpk/core/constants.dart';

Future<void> main(List<String> arguments) async {
  return launchExecutable(
    arguments,
    LaunchConfig(name: ExecutableName(kExecutableName), entrypoint: _init),
  );
}

Future<void> _init(List<String> arguments, LaunchContext context) async {
  final runner = DpkCommandRunner.init(arguments);
  final exitCode = await runner.runDpk();
  exit(exitCode ?? 1);
}
