// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dependency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkDependency _$SdkDependencyFromJson(Map<String, dynamic> json) =>
    SdkDependency(
      json['sdk'] as String,
      version: _constraintFromString(json['version'] as String?),
    );

Map<String, dynamic> _$SdkDependencyToJson(SdkDependency instance) =>
    <String, dynamic>{
      'sdk': instance.sdk,
      'version': _constraintToString(instance.version),
    };

GitDependency _$GitDependencyFromJson(Map<String, dynamic> json) =>
    GitDependency(
      parseGitUri(json['url'] as String),
      ref: json['ref'] as String?,
      path: json['path'] as String?,
    );

Map<String, dynamic> _$GitDependencyToJson(GitDependency instance) =>
    <String, dynamic>{
      'url': instance.url.toString(),
      'ref': instance.ref,
      'path': instance.path,
    };

HostedDependency _$HostedDependencyFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['version', 'hosted'],
    disallowNullValues: const ['hosted'],
  );
  return HostedDependency(
    version: _constraintFromString(json['version'] as String?),
    hosted: json['hosted'] == null
        ? null
        : HostedDetails.fromJson(json['hosted'] as Object),
  );
}

Map<String, dynamic> _$HostedDependencyToJson(HostedDependency instance) =>
    <String, dynamic>{
      'version': _constraintToString(instance.version),
      if (instance.hosted case final value?) 'hosted': value,
    };

HostedDetails _$HostedDetailsFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['name', 'url'],
    disallowNullValues: const ['url'],
  );
  return HostedDetails(
    json['name'] as String?,
    parseGitUriOrNull(json['url'] as String?),
  );
}

Map<String, dynamic> _$HostedDetailsToJson(HostedDetails instance) =>
    <String, dynamic>{
      'name': instance.declaredName,
      if (instance.url?.toString() case final value?) 'url': value,
    };
