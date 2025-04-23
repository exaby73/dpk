// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_command.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PackageConfigItem _$PackageConfigItemFromJson(Map<String, dynamic> json) =>
    _PackageConfigItem(
      name: json['name'] as String,
      rootUri: Uri.parse(json['rootUri'] as String),
      packageUri: json['packageUri'] as String,
      languageVersion: json['languageVersion'] as String,
    );

Map<String, dynamic> _$PackageConfigItemToJson(_PackageConfigItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'rootUri': instance.rootUri.toString(),
      'packageUri': instance.packageUri,
      'languageVersion': instance.languageVersion,
    };
