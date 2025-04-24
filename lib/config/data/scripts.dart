import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yaml/yaml.dart';

part 'scripts.freezed.dart';
part 'scripts.g.dart';

@freezed
abstract class Scripts with _$Scripts {
  const factory Scripts({required Map<String, Script> scriptsMap}) = _Scripts;

  factory Scripts.fromYaml(YamlMap yaml) {
    final scripts = <String, Script>{};

    for (final MapEntry(:key, :value) in yaml.entries) {
      final script = Script.fromYaml(key as String, value);
      scripts[key] = script;
    }

    return Scripts(scriptsMap: scripts);
  }

  factory Scripts.fromJson(Map<String, dynamic> json) =>
      _$ScriptsFromJson(json);
}

@freezed
abstract class Script with _$Script {
  factory Script({
    required String name,
    required String command,
    List<String>? runInPackages,
    required String? runHooksFrom,
  }) {
    final type = HookType.values.firstWhere(
      (type) => type.name == name,
      orElse: () => HookType.none,
    );

    return Script._(
      name: name,
      command: command,
      runInPackages: runInPackages,
      hookType: type,
      runHooksFrom: runHooksFrom,
    );
  }

  const factory Script._({
    required String name,
    required String command,
    List<String>? runInPackages,
    required HookType hookType,
    required String? runHooksFrom,
  }) = _Script;

  factory Script.fromYaml(String name, dynamic yaml) {
    if (yaml is String) {
      return Script(
        name: name,
        command: yaml,
        runHooksFrom: null,
      );
    }

    if (yaml is! YamlMap) {
      throw StateError('Invalid script: $yaml');
    }

    final command = yaml['command'] as String;
    final runHooksFrom = yaml['runHooksFrom'] as String?;
    final runInPackages = (yaml['runInPackages'] as YamlList?)?.cast<String>();

    return Script(
      name: name,
      command: command,
      runInPackages: runInPackages,
      runHooksFrom: runHooksFrom,
    );
  }

  factory Script.fromJson(Map<String, dynamic> json) => _$ScriptFromJson(json);
}

enum HookType { none, preget, postget, prebuild, postbuild }
