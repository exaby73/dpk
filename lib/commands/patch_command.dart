import 'package:args/command_runner.dart';
import 'package:dpm/commands/patch/init_command.dart';

final class PatchCommand extends Command {
  @override
  String name = 'patch';

  @override
  String get description => 'Patch packages';

  PatchCommand() {
    addSubcommand(PatchInitCommand());
  }
}
