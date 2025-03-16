import 'package:args/command_runner.dart';
import 'package:dpm/commands/pub/add_command.dart';
import 'package:dpm/commands/pub/downgrade_command.dart';
import 'package:dpm/commands/pub/get_command.dart';
import 'package:dpm/commands/pub/remove_command.dart';
import 'package:dpm/commands/pub/upgrade_command.dart';

final class PubCommand extends Command {
  @override
  String name = 'pub';

  @override
  String get description => 'Manage dependencies';

  PubCommand() {
    addSubcommand(PubGetCommand());
    addSubcommand(PubAddCommand());
    addSubcommand(PubUpgradeCommand());
    addSubcommand(PubDowngradeCommand());
    addSubcommand(PubRemoveCommand());
  }
}
