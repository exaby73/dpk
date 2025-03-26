import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dpm/config/config.dart';
import 'package:dpm/config/data/config_data.dart';
import 'package:dpm/utils/globals/global_args.dart';

final class DpmCommandRunner extends CommandRunner {
  late final ConfigData config;
  final List<String> args;

  DpmCommandRunner(
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

  Future<void> runDpm() {
    return super.run(args);
  }
}
