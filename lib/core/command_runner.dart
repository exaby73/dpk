import 'dart:io';

import 'package:cli_completion/cli_completion.dart';
import 'package:dpk/commands/add_command.dart';
import 'package:dpk/commands/downgrade_command.dart';
import 'package:dpk/commands/get_command.dart';
import 'package:dpk/commands/parent_commands/patch_command.dart';
import 'package:dpk/commands/remove_command.dart';
import 'package:dpk/commands/run_command.dart';
import 'package:dpk/commands/upgrade_command.dart';
import 'package:dpk/config/config.dart';
import 'package:dpk/config/data/config_data.dart';
import 'package:dpk/core/injection_container.dart';
import 'package:dpk/utils/globals/global_args.dart';
import 'package:logging/logging.dart';

final class DpkCommandRunner extends CompletionCommandRunner<int> {
  late final ConfigData config;
  final List<String> args;

  DpkCommandRunner(
    super.executableName,
    super.description, {
    required this.args,
  }) {
    addGlobalArgs(argParser);
    final argResults = parse(args);
    final directory =
        argResults['directory'] as String? ?? Directory.current.path;

    config = loadConfig(Directory(directory));
  }

  factory DpkCommandRunner.init(List<String> arguments) {
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print(
        '[${record.level.name}] [${record.loggerName}] : ${record.message}',
      );
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

    return runner;
  }

  Future<int?> runDpk() {
    return super.run(args);
  }
}
