// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
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

 Map<String, Script> get scriptsMap;
/// Create a copy of Scripts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScriptsCopyWith<Scripts> get copyWith => _$ScriptsCopyWithImpl<Scripts>(this as Scripts, _$identity);

  /// Serializes this Scripts to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Scripts&&const DeepCollectionEquality().equals(other.scriptsMap, scriptsMap));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(scriptsMap));

@override
String toString() {
  return 'Scripts(scriptsMap: $scriptsMap)';
}


}

/// @nodoc
abstract mixin class $ScriptsCopyWith<$Res>  {
  factory $ScriptsCopyWith(Scripts value, $Res Function(Scripts) _then) = _$ScriptsCopyWithImpl;
@useResult
$Res call({
 Map<String, Script> scriptsMap
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
@pragma('vm:prefer-inline') @override $Res call({Object? scriptsMap = null,}) {
  return _then(_self.copyWith(
scriptsMap: null == scriptsMap ? _self.scriptsMap : scriptsMap // ignore: cast_nullable_to_non_nullable
as Map<String, Script>,
  ));
}

}


/// Adds pattern-matching-related methods to [Scripts].
extension ScriptsPatterns on Scripts {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Scripts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Scripts() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Scripts value)  $default,){
final _that = this;
switch (_that) {
case _Scripts():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Scripts value)?  $default,){
final _that = this;
switch (_that) {
case _Scripts() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, Script> scriptsMap)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Scripts() when $default != null:
return $default(_that.scriptsMap);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, Script> scriptsMap)  $default,) {final _that = this;
switch (_that) {
case _Scripts():
return $default(_that.scriptsMap);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, Script> scriptsMap)?  $default,) {final _that = this;
switch (_that) {
case _Scripts() when $default != null:
return $default(_that.scriptsMap);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Scripts implements Scripts {
  const _Scripts({required final  Map<String, Script> scriptsMap}): _scriptsMap = scriptsMap;
  factory _Scripts.fromJson(Map<String, dynamic> json) => _$ScriptsFromJson(json);

 final  Map<String, Script> _scriptsMap;
@override Map<String, Script> get scriptsMap {
  if (_scriptsMap is EqualUnmodifiableMapView) return _scriptsMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_scriptsMap);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Scripts&&const DeepCollectionEquality().equals(other._scriptsMap, _scriptsMap));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_scriptsMap));

@override
String toString() {
  return 'Scripts(scriptsMap: $scriptsMap)';
}


}

/// @nodoc
abstract mixin class _$ScriptsCopyWith<$Res> implements $ScriptsCopyWith<$Res> {
  factory _$ScriptsCopyWith(_Scripts value, $Res Function(_Scripts) _then) = __$ScriptsCopyWithImpl;
@override @useResult
$Res call({
 Map<String, Script> scriptsMap
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
@override @pragma('vm:prefer-inline') $Res call({Object? scriptsMap = null,}) {
  return _then(_Scripts(
scriptsMap: null == scriptsMap ? _self._scriptsMap : scriptsMap // ignore: cast_nullable_to_non_nullable
as Map<String, Script>,
  ));
}


}


/// @nodoc
mixin _$Script {

 String get name; String get command; String? get description; List<String>? get runInPackages; String? get runHooksFrom; List<String>? get scripts; bool get all; Map<String, String>? get env;
/// Create a copy of Script
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScriptCopyWith<Script> get copyWith => _$ScriptCopyWithImpl<Script>(this as Script, _$identity);

  /// Serializes this Script to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Script&&(identical(other.name, name) || other.name == name)&&(identical(other.command, command) || other.command == command)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.runInPackages, runInPackages)&&(identical(other.runHooksFrom, runHooksFrom) || other.runHooksFrom == runHooksFrom)&&const DeepCollectionEquality().equals(other.scripts, scripts)&&(identical(other.all, all) || other.all == all)&&const DeepCollectionEquality().equals(other.env, env));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,command,description,const DeepCollectionEquality().hash(runInPackages),runHooksFrom,const DeepCollectionEquality().hash(scripts),all,const DeepCollectionEquality().hash(env));

@override
String toString() {
  return 'Script(name: $name, command: $command, description: $description, runInPackages: $runInPackages, runHooksFrom: $runHooksFrom, scripts: $scripts, all: $all, env: $env)';
}


}

/// @nodoc
abstract mixin class $ScriptCopyWith<$Res>  {
  factory $ScriptCopyWith(Script value, $Res Function(Script) _then) = _$ScriptCopyWithImpl;
@useResult
$Res call({
 String name, String command, String? description, List<String>? runInPackages, String? runHooksFrom, List<String>? scripts, bool all, Map<String, String>? env
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
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? command = null,Object? description = freezed,Object? runInPackages = freezed,Object? runHooksFrom = freezed,Object? scripts = freezed,Object? all = null,Object? env = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,command: null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,runInPackages: freezed == runInPackages ? _self.runInPackages : runInPackages // ignore: cast_nullable_to_non_nullable
as List<String>?,runHooksFrom: freezed == runHooksFrom ? _self.runHooksFrom : runHooksFrom // ignore: cast_nullable_to_non_nullable
as String?,scripts: freezed == scripts ? _self.scripts : scripts // ignore: cast_nullable_to_non_nullable
as List<String>?,all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as bool,env: freezed == env ? _self.env : env // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Script].
extension ScriptPatterns on Script {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Script value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Script() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Script value)  $default,){
final _that = this;
switch (_that) {
case _Script():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Script value)?  $default,){
final _that = this;
switch (_that) {
case _Script() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String command,  String? description,  List<String>? runInPackages,  String? runHooksFrom,  List<String>? scripts,  bool all,  Map<String, String>? env)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Script() when $default != null:
return $default(_that.name,_that.command,_that.description,_that.runInPackages,_that.runHooksFrom,_that.scripts,_that.all,_that.env);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String command,  String? description,  List<String>? runInPackages,  String? runHooksFrom,  List<String>? scripts,  bool all,  Map<String, String>? env)  $default,) {final _that = this;
switch (_that) {
case _Script():
return $default(_that.name,_that.command,_that.description,_that.runInPackages,_that.runHooksFrom,_that.scripts,_that.all,_that.env);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String command,  String? description,  List<String>? runInPackages,  String? runHooksFrom,  List<String>? scripts,  bool all,  Map<String, String>? env)?  $default,) {final _that = this;
switch (_that) {
case _Script() when $default != null:
return $default(_that.name,_that.command,_that.description,_that.runInPackages,_that.runHooksFrom,_that.scripts,_that.all,_that.env);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Script implements Script {
  const _Script({required this.name, required this.command, this.description, final  List<String>? runInPackages, required this.runHooksFrom, final  List<String>? scripts, this.all = false, final  Map<String, String>? env}): _runInPackages = runInPackages,_scripts = scripts,_env = env;
  factory _Script.fromJson(Map<String, dynamic> json) => _$ScriptFromJson(json);

@override final  String name;
@override final  String command;
@override final  String? description;
 final  List<String>? _runInPackages;
@override List<String>? get runInPackages {
  final value = _runInPackages;
  if (value == null) return null;
  if (_runInPackages is EqualUnmodifiableListView) return _runInPackages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? runHooksFrom;
 final  List<String>? _scripts;
@override List<String>? get scripts {
  final value = _scripts;
  if (value == null) return null;
  if (_scripts is EqualUnmodifiableListView) return _scripts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  bool all;
 final  Map<String, String>? _env;
@override Map<String, String>? get env {
  final value = _env;
  if (value == null) return null;
  if (_env is EqualUnmodifiableMapView) return _env;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Script&&(identical(other.name, name) || other.name == name)&&(identical(other.command, command) || other.command == command)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._runInPackages, _runInPackages)&&(identical(other.runHooksFrom, runHooksFrom) || other.runHooksFrom == runHooksFrom)&&const DeepCollectionEquality().equals(other._scripts, _scripts)&&(identical(other.all, all) || other.all == all)&&const DeepCollectionEquality().equals(other._env, _env));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,command,description,const DeepCollectionEquality().hash(_runInPackages),runHooksFrom,const DeepCollectionEquality().hash(_scripts),all,const DeepCollectionEquality().hash(_env));

@override
String toString() {
  return 'Script(name: $name, command: $command, description: $description, runInPackages: $runInPackages, runHooksFrom: $runHooksFrom, scripts: $scripts, all: $all, env: $env)';
}


}

/// @nodoc
abstract mixin class _$ScriptCopyWith<$Res> implements $ScriptCopyWith<$Res> {
  factory _$ScriptCopyWith(_Script value, $Res Function(_Script) _then) = __$ScriptCopyWithImpl;
@override @useResult
$Res call({
 String name, String command, String? description, List<String>? runInPackages, String? runHooksFrom, List<String>? scripts, bool all, Map<String, String>? env
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
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? command = null,Object? description = freezed,Object? runInPackages = freezed,Object? runHooksFrom = freezed,Object? scripts = freezed,Object? all = null,Object? env = freezed,}) {
  return _then(_Script(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,command: null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,runInPackages: freezed == runInPackages ? _self._runInPackages : runInPackages // ignore: cast_nullable_to_non_nullable
as List<String>?,runHooksFrom: freezed == runHooksFrom ? _self.runHooksFrom : runHooksFrom // ignore: cast_nullable_to_non_nullable
as String?,scripts: freezed == scripts ? _self._scripts : scripts // ignore: cast_nullable_to_non_nullable
as List<String>?,all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as bool,env: freezed == env ? _self._env : env // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}

// dart format on
