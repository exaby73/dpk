import 'package:args/command_runner.dart';
import 'package:dpm/commands/pub_command.dart';

void main(List<String> arguments) {
  final runner = CommandRunner(
    'dpm',
    'An alternative package manager for Dart',
  );
  runner.addCommand(PubCommand());
  runner.run(arguments);
}
