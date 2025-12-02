import 'dart:io';

import 'package:dpk/constants/pubspec.g.dart';
import 'package:dpk/core/command_runner.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.contains('--version')) {
    // ignore: avoid_print
    print('dpk ${Pubspec.version.representation}');
    exit(0);
  }
  _init(arguments);
}

Future<void> _init(List<String> arguments) async {
  final runner = await DpkCommandRunner.init(arguments);
  final exitCode = await runner.runDpk();
  exit(exitCode ?? 1);
}
