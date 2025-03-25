import 'package:dpm/commands/parent_commands/patch_command.dart';
import 'package:dpm/commands/parent_commands/pub_command.dart';
import 'package:dpm/commands/run_command.dart';
import 'package:dpm/core/command_runner.dart';

Future<void> main(List<String> arguments) async {
  final runner = DpmCommandRunner(
    'dpm',
    'An alternative package manager for Dart',
    args: arguments,
  );
  runner
    ..addCommand(PubCommand(runner.config))
    ..addCommand(PatchCommand())
    ..addCommand(RunCommand(runner.config));

  await runner.runDpm();
}
