// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scripts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Scripts _$ScriptsFromJson(Map<String, dynamic> json) => _Scripts(
  scriptsMap: (json['scriptsMap'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, Script.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$ScriptsToJson(_Scripts instance) => <String, dynamic>{
  'scriptsMap': instance.scriptsMap,
};

_Script _$ScriptFromJson(Map<String, dynamic> json) => _Script(
  name: json['name'] as String,
  command: json['command'] as String,
  description: json['description'] as String?,
  runInPackages: (json['runInPackages'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  runHooksFrom: json['runHooksFrom'] as String?,
  scripts: (json['scripts'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  all: json['all'] as bool? ?? false,
  env: (json['env'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$ScriptToJson(_Script instance) => <String, dynamic>{
  'name': instance.name,
  'command': instance.command,
  'description': instance.description,
  'runInPackages': instance.runInPackages,
  'runHooksFrom': instance.runHooksFrom,
  'scripts': instance.scripts,
  'all': instance.all,
  'env': instance.env,
};
