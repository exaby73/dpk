import 'dart:io';

import 'package:args/args.dart';
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
import 'package:dpk/constants/pubspec.g.dart';
import 'package:dpk/core/injection_container.dart';
import 'package:dpk/utils/globals/global_args.dart';
import 'package:dpk/utils/terminal_title.dart';
import 'package:logging/logging.dart';

final class DpkCommandRunner extends CompletionCommandRunner<int> {
  late final ConfigData config;
  final List<String> args;

  DpkCommandRunner._({
    required String executableName,
    required String description,
    required this.config,
    required this.args,
  }) : super(executableName, description) {
    addGlobalArgs(argParser);
    argParser.addFlag(
      'version',
      negatable: false,
      help: 'Print the version and exit.',
    );
  }

  static Future<DpkCommandRunner> _create({
    required String executableName,
    required String description,
    required List<String> args,
  }) async {
    // Create a temporary arg parser to parse directory flag
    final tempParser = ArgParser();
    final globalRawArgs = [
      for (final arg in args)
        if (tempParser.options.containsKey(arg)) arg,
    ];
    addGlobalArgs(tempParser);
    final argResults = tempParser.parse(globalRawArgs);
    final directoryArg = argResults['directory'] as String?;

    final startDirectory =
        directoryArg != null ? Directory(directoryArg) : Directory.current;

    final dpkYamlDir = await findDpkYamlDirectory(startDirectory);
    final Directory workingDirectory = dpkYamlDir ?? startDirectory;

    final config = await loadConfig(workingDirectory);

    return DpkCommandRunner._(
      executableName: executableName,
      description: description,
      config: config,
      args: args,
    );
  }

  static Future<DpkCommandRunner> init(List<String> arguments) async {
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print(
        '[${record.level.name}] [${record.loggerName}] : ${record.message}',
      );
    });

    final runner = await DpkCommandRunner._create(
      executableName: 'dpk',
      description: 'An alternative package manager for Dart',
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

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults.flag('version')) {
      // ignore: avoid_print
      print('dpk ${Pubspec.version.representation}');
      return 0;
    }

    final commandName = topLevelResults.command?.name;
    if (commandName != null) {
      setTerminalTitle('dpk $commandName');
    } else {
      setTerminalTitle('dpk');
    }

    try {
      return await super.runCommand(topLevelResults);
    } finally {
      restoreTerminalTitle();
    }
  }

  Future<int?> runDpk() {
    return super.run(args);
  }
}
