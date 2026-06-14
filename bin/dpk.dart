import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dpk/constants/pubspec.g.dart';
import 'package:dpk/core/command_runner.dart';

Future<void> main(List<String> arguments) async {
  try {
    if (arguments.contains('--version')) {
      // ignore: avoid_print
      print('dpk ${Pubspec.version.representation}');
      exit(0);
    }

    final exitCode = await _init(arguments);
    exit(exitCode ?? 0);
  } on UsageException catch (error) {
    stderr.writeln(error);
    exit(64);
  } on StateError catch (error) {
    stderr.writeln('Error: ${error.message}');
    exit(1);
  } catch (error) {
    stderr.writeln('Unexpected error: $error');
    exit(1);
  }
}

Future<int?> _init(List<String> arguments) async {
  final runner = await DpkCommandRunner.init(arguments);
  return runner.runDpk();
}
