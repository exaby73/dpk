// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConfigData {

 Pubspec get pubspec; DpkConfig get dpkConfig; Scripts? get scripts; String get workingDirectory; String? get workspaceRoot;
/// Create a copy of ConfigData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfigDataCopyWith<ConfigData> get copyWith => _$ConfigDataCopyWithImpl<ConfigData>(this as ConfigData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfigData&&(identical(other.pubspec, pubspec) || other.pubspec == pubspec)&&(identical(other.dpkConfig, dpkConfig) || other.dpkConfig == dpkConfig)&&(identical(other.scripts, scripts) || other.scripts == scripts)&&(identical(other.workingDirectory, workingDirectory) || other.workingDirectory == workingDirectory)&&(identical(other.workspaceRoot, workspaceRoot) || other.workspaceRoot == workspaceRoot));
}


@override
int get hashCode => Object.hash(runtimeType,pubspec,dpkConfig,scripts,workingDirectory,workspaceRoot);

@override
String toString() {
  return 'ConfigData(pubspec: $pubspec, dpkConfig: $dpkConfig, scripts: $scripts, workingDirectory: $workingDirectory, workspaceRoot: $workspaceRoot)';
}


}

/// @nodoc
abstract mixin class $ConfigDataCopyWith<$Res>  {
  factory $ConfigDataCopyWith(ConfigData value, $Res Function(ConfigData) _then) = _$ConfigDataCopyWithImpl;
@useResult
$Res call({
 Pubspec pubspec, DpkConfig dpkConfig, Scripts? scripts, String workingDirectory, String? workspaceRoot
});


$DpkConfigCopyWith<$Res> get dpkConfig;$ScriptsCopyWith<$Res>? get scripts;

}
/// @nodoc
class _$ConfigDataCopyWithImpl<$Res>
    implements $ConfigDataCopyWith<$Res> {
  _$ConfigDataCopyWithImpl(this._self, this._then);

  final ConfigData _self;
  final $Res Function(ConfigData) _then;

/// Create a copy of ConfigData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pubspec = null,Object? dpkConfig = null,Object? scripts = freezed,Object? workingDirectory = null,Object? workspaceRoot = freezed,}) {
  return _then(_self.copyWith(
pubspec: null == pubspec ? _self.pubspec : pubspec // ignore: cast_nullable_to_non_nullable
as Pubspec,dpkConfig: null == dpkConfig ? _self.dpkConfig : dpkConfig // ignore: cast_nullable_to_non_nullable
as DpkConfig,scripts: freezed == scripts ? _self.scripts : scripts // ignore: cast_nullable_to_non_nullable
as Scripts?,workingDirectory: null == workingDirectory ? _self.workingDirectory : workingDirectory // ignore: cast_nullable_to_non_nullable
as String,workspaceRoot: freezed == workspaceRoot ? _self.workspaceRoot : workspaceRoot // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ConfigData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DpkConfigCopyWith<$Res> get dpkConfig {
  
  return $DpkConfigCopyWith<$Res>(_self.dpkConfig, (value) {
    return _then(_self.copyWith(dpkConfig: value));
  });
}/// Create a copy of ConfigData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScriptsCopyWith<$Res>? get scripts {
    if (_self.scripts == null) {
    return null;
  }

  return $ScriptsCopyWith<$Res>(_self.scripts!, (value) {
    return _then(_self.copyWith(scripts: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConfigData].
extension ConfigDataPatterns on ConfigData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfigData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfigData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfigData value)  $default,){
final _that = this;
switch (_that) {
case _ConfigData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfigData value)?  $default,){
final _that = this;
switch (_that) {
case _ConfigData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Pubspec pubspec,  DpkConfig dpkConfig,  Scripts? scripts,  String workingDirectory,  String? workspaceRoot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfigData() when $default != null:
return $default(_that.pubspec,_that.dpkConfig,_that.scripts,_that.workingDirectory,_that.workspaceRoot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Pubspec pubspec,  DpkConfig dpkConfig,  Scripts? scripts,  String workingDirectory,  String? workspaceRoot)  $default,) {final _that = this;
switch (_that) {
case _ConfigData():
return $default(_that.pubspec,_that.dpkConfig,_that.scripts,_that.workingDirectory,_that.workspaceRoot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Pubspec pubspec,  DpkConfig dpkConfig,  Scripts? scripts,  String workingDirectory,  String? workspaceRoot)?  $default,) {final _that = this;
switch (_that) {
case _ConfigData() when $default != null:
return $default(_that.pubspec,_that.dpkConfig,_that.scripts,_that.workingDirectory,_that.workspaceRoot);case _:
  return null;

}
}

}

/// @nodoc


class _ConfigData implements ConfigData {
  const _ConfigData({required this.pubspec, required this.dpkConfig, required this.scripts, required this.workingDirectory, this.workspaceRoot});
  

@override final  Pubspec pubspec;
@override final  DpkConfig dpkConfig;
@override final  Scripts? scripts;
@override final  String workingDirectory;
@override final  String? workspaceRoot;

/// Create a copy of ConfigData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfigDataCopyWith<_ConfigData> get copyWith => __$ConfigDataCopyWithImpl<_ConfigData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfigData&&(identical(other.pubspec, pubspec) || other.pubspec == pubspec)&&(identical(other.dpkConfig, dpkConfig) || other.dpkConfig == dpkConfig)&&(identical(other.scripts, scripts) || other.scripts == scripts)&&(identical(other.workingDirectory, workingDirectory) || other.workingDirectory == workingDirectory)&&(identical(other.workspaceRoot, workspaceRoot) || other.workspaceRoot == workspaceRoot));
}


@override
int get hashCode => Object.hash(runtimeType,pubspec,dpkConfig,scripts,workingDirectory,workspaceRoot);

@override
String toString() {
  return 'ConfigData(pubspec: $pubspec, dpkConfig: $dpkConfig, scripts: $scripts, workingDirectory: $workingDirectory, workspaceRoot: $workspaceRoot)';
}


}

/// @nodoc
abstract mixin class _$ConfigDataCopyWith<$Res> implements $ConfigDataCopyWith<$Res> {
  factory _$ConfigDataCopyWith(_ConfigData value, $Res Function(_ConfigData) _then) = __$ConfigDataCopyWithImpl;
@override @useResult
$Res call({
 Pubspec pubspec, DpkConfig dpkConfig, Scripts? scripts, String workingDirectory, String? workspaceRoot
});


@override $DpkConfigCopyWith<$Res> get dpkConfig;@override $ScriptsCopyWith<$Res>? get scripts;

}
/// @nodoc
class __$ConfigDataCopyWithImpl<$Res>
    implements _$ConfigDataCopyWith<$Res> {
  __$ConfigDataCopyWithImpl(this._self, this._then);

  final _ConfigData _self;
  final $Res Function(_ConfigData) _then;

/// Create a copy of ConfigData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pubspec = null,Object? dpkConfig = null,Object? scripts = freezed,Object? workingDirectory = null,Object? workspaceRoot = freezed,}) {
  return _then(_ConfigData(
pubspec: null == pubspec ? _self.pubspec : pubspec // ignore: cast_nullable_to_non_nullable
as Pubspec,dpkConfig: null == dpkConfig ? _self.dpkConfig : dpkConfig // ignore: cast_nullable_to_non_nullable
as DpkConfig,scripts: freezed == scripts ? _self.scripts : scripts // ignore: cast_nullable_to_non_nullable
as Scripts?,workingDirectory: null == workingDirectory ? _self.workingDirectory : workingDirectory // ignore: cast_nullable_to_non_nullable
as String,workspaceRoot: freezed == workspaceRoot ? _self.workspaceRoot : workspaceRoot // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ConfigData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DpkConfigCopyWith<$Res> get dpkConfig {
  
  return $DpkConfigCopyWith<$Res>(_self.dpkConfig, (value) {
    return _then(_self.copyWith(dpkConfig: value));
  });
}/// Create a copy of ConfigData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScriptsCopyWith<$Res>? get scripts {
    if (_self.scripts == null) {
    return null;
  }

  return $ScriptsCopyWith<$Res>(_self.scripts!, (value) {
    return _then(_self.copyWith(scripts: value));
  });
}
}

// dart format on
