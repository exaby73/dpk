import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dpk/config/data/config_data.dart';
import 'package:dpk/core/mixins/config_mixin.dart';
import 'package:dpk/core/shell.dart';
import 'package:dpk/core/types.dart';
import 'package:dpk/utils/globals/global_args.dart';
import 'package:dpk/utils/terminal_title.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;
import 'package:prompts/prompts.dart' as prompts;

part 'run_command.freezed.dart';

final class RunCommand extends Command<int> with ConfigMixin {
  @override
  String get name => 'run';

  @override
  String get description => 'Run a script';

  RunCommand() {
    addGlobalArgs(argParser);
    _registerScriptSubcommands();
  }

  void _registerScriptSubcommands() {
    final scripts = config.scripts?.scriptsMap;
    if (scripts != null) {
      for (final scriptName in scripts.keys) {
        addSubcommand(ScriptSubCommand(scriptName: scriptName, config: config));
      }
    }
  }

  @override
  Future<int> run() async {
    // If a sub-command was called, it will be handled by the ScriptSubCommand
    // This method only handles the fallback case for backward compatibility
    final options = RunOptions.fromArgResults(argResults!);
    options.script ??= _promptForScript();

    final runner = DpkScriptRunner(
      config: config,
      options: options,
      arguments: argResults!.rest.skip(1).toList(),
    );

    return await runner.run();
  }

  String _promptForScript() {
    final scriptNames = config.scripts?.scriptsMap.keys.toList();
    if (scriptNames == null) {
      throw StateError('No scripts found');
    }

    final scriptName = prompts.choose(
      'Which script do you want to run?',
      scriptNames,
      chevron: false,
      interactive: false,
    );

    if (scriptName == null) {
      throw StateError('Script name is required');
    }

    return scriptName;
  }
}

@unfreezed
abstract class RunOptions with _$RunOptions {
  factory RunOptions({
    required GlobalOptions globalOptions,
    required String? script,
  }) = _RunOptions;

  factory RunOptions.fromArgResults(ArgResults results) {
    return RunOptions(
      globalOptions: GlobalOptions.fromArgResults(results),
      script: results.rest.firstOrNull,
    );
  }
}

final class ScriptSubCommand extends Command<int> {
  final String scriptName;
  final ConfigData config;

  ScriptSubCommand({required this.scriptName, required this.config});

  @override
  String get name => scriptName;

  @override
  String get description {
    final script = config.scripts?.scriptsMap[scriptName];
    return script?.command ?? 'Run $scriptName script';
  }

  @override
  Future<int> run() async {
    final options = RunOptions(
      globalOptions: GlobalOptions.fromArgResults(globalResults!),
      script: scriptName,
    );

    final runner = DpkScriptRunner(
      config: config,
      options: options,
      arguments: argResults!.rest,
    );

    return await runner.run();
  }
}

final class DpkScriptRunner {
  final ConfigData config;
  final RunOptions options;
  final List<String> arguments;

  DpkScriptRunner({
    required this.config,
    required this.options,
    required this.arguments,
  });

  Future<int> run({
    /// If true, the script will be skipped if it is not found in the config.
    bool skipIfMissing = false,
  }) async {
    assert(options.script != null, 'Script name is required');

    final scriptExists =
        config.scripts?.scriptsMap.containsKey(options.script) == true;

    if (!scriptExists && skipIfMissing) {
      return 0;
    }

    final targetDirectory =
        options.globalOptions.directory ?? config.workingDirectory;
    Directory.current = targetDirectory;

    IntCallback? preHook;
    IntCallback? postHook;

    if (scriptExists) {
      (preHook, postHook) = _getHooks(
        config: config,
        options: options,
        arguments: arguments,
      );
    }

    final preHookExitCode = await preHook?.call();
    if (preHookExitCode != null && preHookExitCode != 0) {
      return preHookExitCode;
    }

    final exitCode = await _runScript(
      config: config,
      options: options,
      arguments: arguments,
      skipIfMissing: skipIfMissing,
    );
    if (exitCode != 0) {
      return exitCode;
    }

    final postHookExitCode = await postHook?.call();
    return postHookExitCode ?? 0;
  }

  List<String> _wrapCommandForPty(String command) {
    return ['-c', command];
  }

  List<List<int>> _wrapLineWithAnsi(
    List<int> lineBytes,
    int maxWidth,
    List<int> indentBytes,
  ) {
    if (maxWidth <= 0) {
      return [
        <int>[...indentBytes, ...lineBytes],
      ];
    }

    final wrapped = <List<int>>[];
    var currentLine = <int>[...indentBytes];
    var visibleLength = indentBytes.length;
    var inAnsi = false;
    var ansiBuffer = <int>[];
    var lastWhitespacePos = -1;
    var lastWhitespaceVisibleLength = 0;

    for (var i = 0; i < lineBytes.length; i++) {
      final byte = lineBytes[i];

      if (byte == 0x1B) {
        inAnsi = true;
        ansiBuffer = [byte];
        currentLine.add(byte);
        continue;
      }

      if (inAnsi) {
        ansiBuffer.add(byte);
        currentLine.add(byte);
        if (byte >= 0x40 && byte <= 0x7E) {
          inAnsi = false;
          ansiBuffer = [];
        }
        continue;
      }

      final isWhitespace = byte == 0x20 || byte == 0x09;
      if (isWhitespace) {
        lastWhitespacePos = currentLine.length;
        lastWhitespaceVisibleLength = visibleLength;
      }

      if (visibleLength >= maxWidth &&
          currentLine.length > indentBytes.length) {
        if (lastWhitespacePos > indentBytes.length &&
            lastWhitespaceVisibleLength > indentBytes.length) {
          final wrappedLine = currentLine.sublist(0, lastWhitespacePos);
          final remainingBytes = currentLine.sublist(lastWhitespacePos + 1);
          wrapped.add(wrappedLine);

          currentLine = <int>[...indentBytes];
          if (ansiBuffer.isNotEmpty) {
            currentLine.addAll(ansiBuffer);
          }
          currentLine.addAll(remainingBytes);
          visibleLength =
              indentBytes.length +
              (visibleLength - lastWhitespaceVisibleLength - 1);
          lastWhitespacePos = -1;
        } else {
          wrapped.add(currentLine);
          currentLine = <int>[...indentBytes];
          if (ansiBuffer.isNotEmpty) {
            currentLine.addAll(ansiBuffer);
          }
          visibleLength = indentBytes.length;
          lastWhitespacePos = -1;
        }
      }

      currentLine.add(byte);
      if (byte == 0x09) {
        visibleLength = ((visibleLength ~/ 8) + 1) * 8;
      } else if (byte >= 0x20) {
        visibleLength++;
      }
    }

    if (currentLine.isNotEmpty) {
      wrapped.add(currentLine);
    }

    return wrapped.isEmpty
        ? [
            <int>[...indentBytes, ...lineBytes],
          ]
        : wrapped;
  }

  Future<int> _runScript({
    required ConfigData config,
    required RunOptions options,
    required List<String> arguments,
    bool skipIfMissing = false,
  }) async {
    final script = config.scripts?.scriptsMap[options.script];
    final scriptExists = script != null;

    if (scriptExists && options.script != null) {
      setTerminalTitle('dpk run ${options.script}');
    }

    if (!scriptExists && skipIfMissing) {
      return 0;
    }

    if (scriptExists) {
      final packagesToRunInGlobs = script.runInPackages;
      late final bool hasToRunMultiple;
      final packagesToRunIn = <String>[];

      final workspace = config.pubspec.workspace;
      if (packagesToRunInGlobs != null && workspace == null) {
        throw StateError(
          'No workspace packages configured, '
          'but you have runInPackages configured',
        );
      }

      if (packagesToRunInGlobs == null) {
        hasToRunMultiple = false;
      } else if (packagesToRunInGlobs.isEmpty) {
        hasToRunMultiple = false;
      } else {
        for (final pattern in packagesToRunInGlobs) {
          final glob = Glob(pattern);
          for (final package in workspace!) {
            if (glob.matches(package)) {
              packagesToRunIn.add(package);
            }
          }
        }
        hasToRunMultiple = packagesToRunIn.length > 1;
      }

      if (script.command.isEmpty) {
        throw StateError('Script command is empty');
      }

      final command = script.command.trim();

      final finalScript = [command, if (arguments.isNotEmpty) ...arguments];

      if (hasToRunMultiple) {
        final processExitCodesFutures = <Future<int>>[];
        final newlineByte = 0x0A;
        final indentLength = 4;
        final terminalWidth = stdout.hasTerminal ? stdout.terminalColumns : 80;
        final maxLineWidth = terminalWidth - indentLength;

        // Resolve package paths relative to workspace root if available
        final workspaceRoot = config.workspaceRoot ?? config.workingDirectory;

        for (final package in packagesToRunIn) {
          // Resolve package path relative to workspace root
          final packagePath = path.join(workspaceRoot, package);

          final process = await Process.start(
            getShell(),
            _wrapCommandForPty(finalScript.join(' ')),
            runInShell: true,
            workingDirectory: packagePath,
            environment: script.env,
          );

          final headerBytes = '[$package]\n'.codeUnits;
          final indentBytes = '    '.codeUnits;
          var buffer = <int>[];
          var headerPrinted = false;

          process.stdout.listen(
            (event) {
              if (event.isEmpty) return;

              buffer.addAll(event);
              var start = 0;

              for (var i = 0; i < buffer.length; i++) {
                if (buffer[i] == newlineByte) {
                  final lineBytes = buffer.sublist(start, i);
                  final wrappedLines = _wrapLineWithAnsi(
                    lineBytes,
                    maxLineWidth,
                    indentBytes,
                  );

                  for (var j = 0; j < wrappedLines.length; j++) {
                    final output = <int>[];
                    if (j == 0 && !headerPrinted) {
                      output.addAll(headerBytes);
                      headerPrinted = true;
                    }
                    output.addAll(wrappedLines[j]);
                    output.add(newlineByte);
                    stdout.add(output);
                  }

                  start = i + 1;
                }
              }

              buffer = buffer.sublist(start);
            },
            onDone: () {
              if (buffer.isNotEmpty) {
                final wrappedLines = _wrapLineWithAnsi(
                  buffer,
                  maxLineWidth,
                  indentBytes,
                );
                for (var j = 0; j < wrappedLines.length; j++) {
                  final output = <int>[];
                  if (j == 0 && !headerPrinted) {
                    output.addAll(headerBytes);
                    headerPrinted = true;
                  }
                  output.addAll(wrappedLines[j]);
                  output.add(newlineByte);
                  stdout.add(output);
                }
              }
            },
          );

          var stderrBuffer = <int>[];

          process.stderr.listen(
            (event) {
              if (event.isEmpty) return;

              stderrBuffer.addAll(event);
              var start = 0;

              for (var i = 0; i < stderrBuffer.length; i++) {
                if (stderrBuffer[i] == newlineByte) {
                  final lineBytes = stderrBuffer.sublist(start, i);
                  final wrappedLines = _wrapLineWithAnsi(
                    lineBytes,
                    maxLineWidth,
                    indentBytes,
                  );

                  for (var j = 0; j < wrappedLines.length; j++) {
                    final output = <int>[];
                    if (j == 0 && !headerPrinted) {
                      output.addAll(headerBytes);
                      headerPrinted = true;
                    }
                    output.addAll(wrappedLines[j]);
                    output.add(newlineByte);
                    stderr.add(output);
                  }

                  start = i + 1;
                }
              }

              stderrBuffer = stderrBuffer.sublist(start);
            },
            onDone: () {
              if (stderrBuffer.isNotEmpty) {
                final wrappedLines = _wrapLineWithAnsi(
                  stderrBuffer,
                  maxLineWidth,
                  indentBytes,
                );
                for (var j = 0; j < wrappedLines.length; j++) {
                  final output = <int>[];
                  if (j == 0 && !headerPrinted) {
                    output.addAll(headerBytes);
                    headerPrinted = true;
                  }
                  output.addAll(wrappedLines[j]);
                  output.add(newlineByte);
                  stderr.add(output);
                }
              }
            },
          );

          processExitCodesFutures.add(process.exitCode);
        }

        final processExitCodes = await Future.wait(processExitCodesFutures);
        return processExitCodes.fold(0, (previousValue, element) {
          return previousValue == 0 ? element : previousValue;
        });
      }

      final process = await Process.start(
        getShell(),
        ['-c', finalScript.join(' ')],
        runInShell: true,
        workingDirectory: packagesToRunIn.isNotEmpty
            ? packagesToRunIn.first
            : options.globalOptions.directory,
        environment: script.env,
        mode: ProcessStartMode.inheritStdio,
      );

      return process.exitCode;
    }

    // If we get here, the script doesn't exist in dpk.yaml
    final availableScripts = config.scripts?.scriptsMap.keys.toList() ?? [];
    throw StateError(
      'Script "${options.script}" not found in dpk.yaml.\n'
      'Available scripts: ${availableScripts.isEmpty ? 'none' : availableScripts.join(', ')}',
    );
  }

  (IntCallback?, IntCallback?) _getHooks({
    required ConfigData config,
    required RunOptions options,
    required List<String> arguments,
  }) {
    final script = config.scripts?.scriptsMap[options.script];
    final commandName = script?.runHooksFrom ?? options.script;

    if (commandName == null) {
      return (null, null);
    }

    final preHookName = 'pre:$commandName';
    final postHookName = 'post:$commandName';

    IntCallback? preHookCallback;
    IntCallback? postHookCallback;

    if (config.scripts?.scriptsMap.containsKey(preHookName) == true) {
      preHookCallback = () => _runScript(
        config: config,
        options: options.copyWith(script: preHookName),
        arguments: [],
      );
    }

    if (config.scripts?.scriptsMap.containsKey(postHookName) == true) {
      postHookCallback = () => _runScript(
        config: config,
        options: options.copyWith(script: postHookName),
        arguments: [],
      );
    }

    return (preHookCallback, postHookCallback);
  }
}
