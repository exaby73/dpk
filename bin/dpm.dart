import 'package:args/command_runner.dart';
import 'package:dpm/commands/parent_commands/patch_command.dart';
import 'package:dpm/commands/parent_commands/pub_command.dart';
import 'package:dpm/commands/run_command.dart';

Future<void> main(List<String> arguments) async {
  final runner =
      CommandRunner('dpm', 'An alternative package manager for Dart')
        ..addCommand(PubCommand())
        ..addCommand(PatchCommand())
        ..addCommand(RunCommand());

  await runner.run(arguments);
}
