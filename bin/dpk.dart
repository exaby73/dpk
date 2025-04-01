import 'package:cli_launcher/cli_launcher.dart';
import 'package:dpk/commands/parent_commands/add_command.dart';
import 'package:dpk/commands/parent_commands/downgrade_command.dart';
import 'package:dpk/commands/parent_commands/get_command.dart';
import 'package:dpk/commands/parent_commands/patch_command.dart';
import 'package:dpk/commands/parent_commands/remove_command.dart';
import 'package:dpk/commands/parent_commands/upgrade_command.dart';
import 'package:dpk/commands/run_command.dart';
import 'package:dpk/config/data/config_data.dart';
import 'package:dpk/core/command_runner.dart';
import 'package:dpk/core/constants.dart';
import 'package:dpk/core/injection_container.dart';
import 'package:logging/logging.dart';

Future<void> main(List<String> arguments) async {
  return launchExecutable(
    arguments,
    LaunchConfig(name: ExecutableName(kExecutableName), entrypoint: _init),
  );
}

Future<void> _init(List<String> arguments, LaunchContext context) async {
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('[${record.level.name}] [${record.loggerName}] : ${record.message}');
  });

  final runner = DpkCommandRunner(
    'dpk',
    'An alternative package manager for Dart',
    args: arguments,
  );

  container.registerSingleton<ConfigData>(runner.config);

  runner
    ..addCommand(AddCommand())
    ..addCommand(DowngradeCommand())
    ..addCommand(GetCommand())
    ..addCommand(RemoveCommand())
    ..addCommand(UpgradeCommand())
    ..addCommand(PatchCommand())
    ..addCommand(RunCommand());

  await runner.runDpk();
}
