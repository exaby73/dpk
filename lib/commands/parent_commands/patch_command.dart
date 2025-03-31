import 'package:args/command_runner.dart';
import 'package:dpk/commands/subcommands/patch/apply_command.dart';
import 'package:dpk/commands/subcommands/patch/generate_command.dart';
import 'package:dpk/commands/subcommands/patch/init_command.dart';

final class PatchCommand extends Command {
  @override
  String name = 'patch';

  @override
  String get description => 'Patch packages';

  PatchCommand() {
    addSubcommand(PatchInitCommand());
    addSubcommand(PatchGenerateCommand());
    addSubcommand(PatchApplyCommand());
  }
}
