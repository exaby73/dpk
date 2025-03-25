import 'package:args/command_runner.dart';
import 'package:dpm/commands/subcommands/pub/add_command.dart';
import 'package:dpm/commands/subcommands/pub/downgrade_command.dart';
import 'package:dpm/commands/subcommands/pub/get_command.dart';
import 'package:dpm/commands/subcommands/pub/remove_command.dart';
import 'package:dpm/commands/subcommands/pub/upgrade_command.dart';
import 'package:dpm/config/data/config_data.dart';

final class PubCommand extends Command {
  @override
  String name = 'pub';

  @override
  String get description => 'Manage dependencies';

  final ConfigData config;

  PubCommand(this.config) {
    addSubcommand(PubGetCommand(config));
    addSubcommand(PubAddCommand());
    addSubcommand(PubUpgradeCommand());
    addSubcommand(PubDowngradeCommand());
    addSubcommand(PubRemoveCommand());
  }
}
