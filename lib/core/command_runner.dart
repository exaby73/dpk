import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpm/config/config.dart';
import 'package:dpm/config/data/config_data.dart';

final class DpmCommandRunner extends CommandRunner {
  late final ConfigData config;
  late final List<String> args;

  @override
  final ArgParser argParser =
      ArgParser()..addOption(
        'directory',
        abbr: 'C',
        help: 'The directory to run the command in',
      );

  DpmCommandRunner(
    super.executableName,
    super.description, {
    required this.args,
  }) {
    final argResults = parse(args);
    final directory =
        argResults['directory'] as String? ?? Directory.current.path;

    config = loadConfig(Directory(directory));
  }

  Future<void> runDpm() async {
    return super.run(args);
  }
}
