import 'package:args/command_runner.dart';
import 'package:dpm/commands/patch_command.dart';
import 'package:dpm/commands/pub_command.dart';

void main(List<String> arguments) {
  final runner =
      CommandRunner('dpm', 'An alternative package manager for Dart')
        ..addCommand(PubCommand())
        ..addCommand(PatchCommand());
  runner.run(arguments);
}
