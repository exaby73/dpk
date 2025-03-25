// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scripts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Scripts _$ScriptsFromJson(Map<String, dynamic> json) => _Scripts(
  scripts: (json['scripts'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, Script.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$ScriptsToJson(_Scripts instance) => <String, dynamic>{
  'scripts': instance.scripts,
};

_Script _$ScriptFromJson(Map<String, dynamic> json) => _Script(
  name: json['name'] as String,
  description: json['description'] as String?,
  command: json['command'] as String,
  hookType: $enumDecode(_$HookTypeEnumMap, json['hookType']),
  runHooksFrom: json['runHooksFrom'] as String?,
);

Map<String, dynamic> _$ScriptToJson(_Script instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'command': instance.command,
  'hookType': _$HookTypeEnumMap[instance.hookType]!,
  'runHooksFrom': instance.runHooksFrom,
};

const _$HookTypeEnumMap = {
  HookType.none: 'none',
  HookType.preget: 'preget',
  HookType.postget: 'postget',
  HookType.prebuild: 'prebuild',
  HookType.postbuild: 'postbuild',
};
