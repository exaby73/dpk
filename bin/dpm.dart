
import 'package:cli_launcher/cli_launcher.dart';
import 'package:dpm/commands/parent_commands/patch_command.dart';
import 'package:dpm/commands/parent_commands/pub_command.dart';
import 'package:dpm/commands/run_command.dart';
import 'package:dpm/config/data/config_data.dart';
import 'package:dpm/core/command_runner.dart';
import 'package:dpm/core/constants.dart';
import 'package:dpm/core/injection_container.dart';
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

  final runner = DpmCommandRunner(
    'dpm',
    'An alternative package manager for Dart',
    args: arguments,
  );

  container.registerSingleton<ConfigData>(runner.config);

  runner
    ..addCommand(PubCommand())
    ..addCommand(PatchCommand())
    ..addCommand(RunCommand());

  await runner.runDpm();
}
