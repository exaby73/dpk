// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scripts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Scripts {

 Map<String, Script> get scripts;
/// Create a copy of Scripts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScriptsCopyWith<Scripts> get copyWith => _$ScriptsCopyWithImpl<Scripts>(this as Scripts, _$identity);

  /// Serializes this Scripts to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Scripts&&const DeepCollectionEquality().equals(other.scripts, scripts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(scripts));

@override
String toString() {
  return 'Scripts(scripts: $scripts)';
}


}

/// @nodoc
abstract mixin class $ScriptsCopyWith<$Res>  {
  factory $ScriptsCopyWith(Scripts value, $Res Function(Scripts) _then) = _$ScriptsCopyWithImpl;
@useResult
$Res call({
 Map<String, Script> scripts
});




}
/// @nodoc
class _$ScriptsCopyWithImpl<$Res>
    implements $ScriptsCopyWith<$Res> {
  _$ScriptsCopyWithImpl(this._self, this._then);

  final Scripts _self;
  final $Res Function(Scripts) _then;

/// Create a copy of Scripts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scripts = null,}) {
  return _then(_self.copyWith(
scripts: null == scripts ? _self.scripts : scripts // ignore: cast_nullable_to_non_nullable
as Map<String, Script>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Scripts implements Scripts {
  const _Scripts({required final  Map<String, Script> scripts}): _scripts = scripts;
  factory _Scripts.fromJson(Map<String, dynamic> json) => _$ScriptsFromJson(json);

 final  Map<String, Script> _scripts;
@override Map<String, Script> get scripts {
  if (_scripts is EqualUnmodifiableMapView) return _scripts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_scripts);
}


/// Create a copy of Scripts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScriptsCopyWith<_Scripts> get copyWith => __$ScriptsCopyWithImpl<_Scripts>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScriptsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Scripts&&const DeepCollectionEquality().equals(other._scripts, _scripts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_scripts));

@override
String toString() {
  return 'Scripts(scripts: $scripts)';
}


}

/// @nodoc
abstract mixin class _$ScriptsCopyWith<$Res> implements $ScriptsCopyWith<$Res> {
  factory _$ScriptsCopyWith(_Scripts value, $Res Function(_Scripts) _then) = __$ScriptsCopyWithImpl;
@override @useResult
$Res call({
 Map<String, Script> scripts
});




}
/// @nodoc
class __$ScriptsCopyWithImpl<$Res>
    implements _$ScriptsCopyWith<$Res> {
  __$ScriptsCopyWithImpl(this._self, this._then);

  final _Scripts _self;
  final $Res Function(_Scripts) _then;

/// Create a copy of Scripts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scripts = null,}) {
  return _then(_Scripts(
scripts: null == scripts ? _self._scripts : scripts // ignore: cast_nullable_to_non_nullable
as Map<String, Script>,
  ));
}


}


/// @nodoc
mixin _$Script {

 String get name; String? get description; String get command; HookType get hookType;
/// Create a copy of Script
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScriptCopyWith<Script> get copyWith => _$ScriptCopyWithImpl<Script>(this as Script, _$identity);

  /// Serializes this Script to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Script&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.command, command) || other.command == command)&&(identical(other.hookType, hookType) || other.hookType == hookType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,command,hookType);

@override
String toString() {
  return 'Script(name: $name, description: $description, command: $command, hookType: $hookType)';
}


}

/// @nodoc
abstract mixin class $ScriptCopyWith<$Res>  {
  factory $ScriptCopyWith(Script value, $Res Function(Script) _then) = _$ScriptCopyWithImpl;
@useResult
$Res call({
 String name, String? description, String command, HookType hookType
});




}
/// @nodoc
class _$ScriptCopyWithImpl<$Res>
    implements $ScriptCopyWith<$Res> {
  _$ScriptCopyWithImpl(this._self, this._then);

  final Script _self;
  final $Res Function(Script) _then;

/// Create a copy of Script
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = freezed,Object? command = null,Object? hookType = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,command: null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String,hookType: null == hookType ? _self.hookType : hookType // ignore: cast_nullable_to_non_nullable
as HookType,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Script implements Script {
  const _Script({required this.name, required this.description, required this.command, required this.hookType});
  factory _Script.fromJson(Map<String, dynamic> json) => _$ScriptFromJson(json);

@override final  String name;
@override final  String? description;
@override final  String command;
@override final  HookType hookType;

/// Create a copy of Script
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScriptCopyWith<_Script> get copyWith => __$ScriptCopyWithImpl<_Script>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScriptToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Script&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.command, command) || other.command == command)&&(identical(other.hookType, hookType) || other.hookType == hookType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,command,hookType);

@override
String toString() {
  return 'Script._(name: $name, description: $description, command: $command, hookType: $hookType)';
}


}

/// @nodoc
abstract mixin class _$ScriptCopyWith<$Res> implements $ScriptCopyWith<$Res> {
  factory _$ScriptCopyWith(_Script value, $Res Function(_Script) _then) = __$ScriptCopyWithImpl;
@override @useResult
$Res call({
 String name, String? description, String command, HookType hookType
});




}
/// @nodoc
class __$ScriptCopyWithImpl<$Res>
    implements _$ScriptCopyWith<$Res> {
  __$ScriptCopyWithImpl(this._self, this._then);

  final _Script _self;
  final $Res Function(_Script) _then;

/// Create a copy of Script
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = freezed,Object? command = null,Object? hookType = null,}) {
  return _then(_Script(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,command: null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String,hookType: null == hookType ? _self.hookType : hookType // ignore: cast_nullable_to_non_nullable
as HookType,
  ));
}


}

// dart format on
