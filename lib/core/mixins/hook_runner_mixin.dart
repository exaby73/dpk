import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dpk/commands/run_command.dart';
import 'package:dpk/config/data/config_data.dart';
import 'package:dpk/utils/globals/global_args.dart';

base mixin HookRunnerMixin on Command<int> {
  ConfigData get config;

  /// Runs the pre-hook for the given command name if it exists.
  /// Returns the exit code from the hook, or 0 if no hook exists.
  Future<int> runPreHook({
    required String commandName,
    required GlobalOptions globalOptions,
  }) {
    final hookName = 'pre:$commandName';
    return _runHook(hookName: hookName, globalOptions: globalOptions);
  }

  /// Runs the post-hook for the given command name if it exists.
  /// Returns the exit code from the hook, or 0 if no hook exists.
  Future<int> runPostHook({
    required String commandName,
    required GlobalOptions globalOptions,
  }) {
    final hookName = 'post:$commandName';
    return _runHook(hookName: hookName, globalOptions: globalOptions);
  }

  Future<int> _runHook({
    required String hookName,
    required GlobalOptions globalOptions,
  }) async {
    final hookRunner = DpkScriptRunner(
      config: config,
      arguments: [],
      options: RunOptions(globalOptions: globalOptions, script: hookName),
    );

    final originalDirectory = Directory.current;
    try {
      return await hookRunner.run(skipIfMissing: true);
    } finally {
      Directory.current = originalDirectory;
    }
  }
}
