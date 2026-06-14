import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dpk/commands/run_command.dart';
import 'package:dpk/config/data/config_data.dart';
import 'package:dpk/config/data/scripts.dart';
import 'package:dpk/utils/globals/global_args.dart';

base mixin HookRunnerMixin on Command<int> {
  ConfigData get config;

  /// Runs the shared before-hook for the given command name if it applies.
  /// Returns the exit code from the hook, or 0 if no hook exists.
  Future<int> runBeforeHook({
    required String commandName,
    required GlobalOptions globalOptions,
  }) {
    return _runHookIfApplies(
      hookName: 'before',
      commandName: commandName,
      globalOptions: globalOptions,
    );
  }

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

  /// Runs the shared after-hook for the given command name if it applies.
  /// Returns the exit code from the hook, or 0 if no hook exists.
  Future<int> runAfterHook({
    required String commandName,
    required GlobalOptions globalOptions,
  }) {
    return _runHookIfApplies(
      hookName: 'after',
      commandName: commandName,
      globalOptions: globalOptions,
    );
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

  Future<int> _runHookIfApplies({
    required String hookName,
    required String commandName,
    required GlobalOptions globalOptions,
  }) {
    final hook = config.scripts?.scriptsMap[hookName];
    if (hook == null || !_hookAppliesTo(hook, commandName)) {
      return Future.value(0);
    }

    return _runHook(hookName: hookName, globalOptions: globalOptions);
  }

  bool _hookAppliesTo(Script hook, String commandName) {
    if (hook.all) {
      return true;
    }

    return hook.scripts?.contains(commandName) == true;
  }
}
