// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'link_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LinkOptions {
  GlobalOptions get globalOptions;
  GlobalPubOptions get globalPubOptions;

  /// Create a copy of LinkOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LinkOptionsCopyWith<LinkOptions> get copyWith =>
      _$LinkOptionsCopyWithImpl<LinkOptions>(this as LinkOptions, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LinkOptions &&
            (identical(other.globalOptions, globalOptions) ||
                other.globalOptions == globalOptions) &&
            (identical(other.globalPubOptions, globalPubOptions) ||
                other.globalPubOptions == globalPubOptions));
  }

  @override
  int get hashCode => Object.hash(runtimeType, globalOptions, globalPubOptions);

  @override
  String toString() {
    return 'LinkOptions(globalOptions: $globalOptions, globalPubOptions: $globalPubOptions)';
  }
}

/// @nodoc
abstract mixin class $LinkOptionsCopyWith<$Res> {
  factory $LinkOptionsCopyWith(
          LinkOptions value, $Res Function(LinkOptions) _then) =
      _$LinkOptionsCopyWithImpl;
  @useResult
  $Res call({GlobalOptions globalOptions, GlobalPubOptions globalPubOptions});

  $GlobalOptionsCopyWith<$Res> get globalOptions;
  $GlobalPubOptionsCopyWith<$Res> get globalPubOptions;
}

/// @nodoc
class _$LinkOptionsCopyWithImpl<$Res> implements $LinkOptionsCopyWith<$Res> {
  _$LinkOptionsCopyWithImpl(this._self, this._then);

  final LinkOptions _self;
  final $Res Function(LinkOptions) _then;

  /// Create a copy of LinkOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? globalOptions = null,
    Object? globalPubOptions = null,
  }) {
    return _then(_self.copyWith(
      globalOptions: null == globalOptions
          ? _self.globalOptions
          : globalOptions // ignore: cast_nullable_to_non_nullable
              as GlobalOptions,
      globalPubOptions: null == globalPubOptions
          ? _self.globalPubOptions
          : globalPubOptions // ignore: cast_nullable_to_non_nullable
              as GlobalPubOptions,
    ));
  }

  /// Create a copy of LinkOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GlobalOptionsCopyWith<$Res> get globalOptions {
    return $GlobalOptionsCopyWith<$Res>(_self.globalOptions, (value) {
      return _then(_self.copyWith(globalOptions: value));
    });
  }

  /// Create a copy of LinkOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GlobalPubOptionsCopyWith<$Res> get globalPubOptions {
    return $GlobalPubOptionsCopyWith<$Res>(_self.globalPubOptions, (value) {
      return _then(_self.copyWith(globalPubOptions: value));
    });
  }
}

/// @nodoc

class _LinkOptions implements LinkOptions {
  const _LinkOptions(
      {required this.globalOptions, required this.globalPubOptions});

  @override
  final GlobalOptions globalOptions;
  @override
  final GlobalPubOptions globalPubOptions;

  /// Create a copy of LinkOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LinkOptionsCopyWith<_LinkOptions> get copyWith =>
      __$LinkOptionsCopyWithImpl<_LinkOptions>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LinkOptions &&
            (identical(other.globalOptions, globalOptions) ||
                other.globalOptions == globalOptions) &&
            (identical(other.globalPubOptions, globalPubOptions) ||
                other.globalPubOptions == globalPubOptions));
  }

  @override
  int get hashCode => Object.hash(runtimeType, globalOptions, globalPubOptions);

  @override
  String toString() {
    return 'LinkOptions(globalOptions: $globalOptions, globalPubOptions: $globalPubOptions)';
  }
}

/// @nodoc
abstract mixin class _$LinkOptionsCopyWith<$Res>
    implements $LinkOptionsCopyWith<$Res> {
  factory _$LinkOptionsCopyWith(
          _LinkOptions value, $Res Function(_LinkOptions) _then) =
      __$LinkOptionsCopyWithImpl;
  @override
  @useResult
  $Res call({GlobalOptions globalOptions, GlobalPubOptions globalPubOptions});

  @override
  $GlobalOptionsCopyWith<$Res> get globalOptions;
  @override
  $GlobalPubOptionsCopyWith<$Res> get globalPubOptions;
}

/// @nodoc
class __$LinkOptionsCopyWithImpl<$Res> implements _$LinkOptionsCopyWith<$Res> {
  __$LinkOptionsCopyWithImpl(this._self, this._then);

  final _LinkOptions _self;
  final $Res Function(_LinkOptions) _then;

  /// Create a copy of LinkOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? globalOptions = null,
    Object? globalPubOptions = null,
  }) {
    return _then(_LinkOptions(
      globalOptions: null == globalOptions
          ? _self.globalOptions
          : globalOptions // ignore: cast_nullable_to_non_nullable
              as GlobalOptions,
      globalPubOptions: null == globalPubOptions
          ? _self.globalPubOptions
          : globalPubOptions // ignore: cast_nullable_to_non_nullable
              as GlobalPubOptions,
    ));
  }

  /// Create a copy of LinkOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GlobalOptionsCopyWith<$Res> get globalOptions {
    return $GlobalOptionsCopyWith<$Res>(_self.globalOptions, (value) {
      return _then(_self.copyWith(globalOptions: value));
    });
  }

  /// Create a copy of LinkOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GlobalPubOptionsCopyWith<$Res> get globalPubOptions {
    return $GlobalPubOptionsCopyWith<$Res>(_self.globalPubOptions, (value) {
      return _then(_self.copyWith(globalPubOptions: value));
    });
  }
}

/// @nodoc
mixin _$PackageConfigItem {
  String get name;
  Uri get rootUri;
  String get packageUri;
  String get languageVersion;

  /// Create a copy of PackageConfigItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PackageConfigItemCopyWith<PackageConfigItem> get copyWith =>
      _$PackageConfigItemCopyWithImpl<PackageConfigItem>(
          this as PackageConfigItem, _$identity);

  /// Serializes this PackageConfigItem to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PackageConfigItem &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.rootUri, rootUri) || other.rootUri == rootUri) &&
            (identical(other.packageUri, packageUri) ||
                other.packageUri == packageUri) &&
            (identical(other.languageVersion, languageVersion) ||
                other.languageVersion == languageVersion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, rootUri, packageUri, languageVersion);

  @override
  String toString() {
    return 'PackageConfigItem(name: $name, rootUri: $rootUri, packageUri: $packageUri, languageVersion: $languageVersion)';
  }
}

/// @nodoc
abstract mixin class $PackageConfigItemCopyWith<$Res> {
  factory $PackageConfigItemCopyWith(
          PackageConfigItem value, $Res Function(PackageConfigItem) _then) =
      _$PackageConfigItemCopyWithImpl;
  @useResult
  $Res call(
      {String name, Uri rootUri, String packageUri, String languageVersion});
}

/// @nodoc
class _$PackageConfigItemCopyWithImpl<$Res>
    implements $PackageConfigItemCopyWith<$Res> {
  _$PackageConfigItemCopyWithImpl(this._self, this._then);

  final PackageConfigItem _self;
  final $Res Function(PackageConfigItem) _then;

  /// Create a copy of PackageConfigItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? rootUri = null,
    Object? packageUri = null,
    Object? languageVersion = null,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      rootUri: null == rootUri
          ? _self.rootUri
          : rootUri // ignore: cast_nullable_to_non_nullable
              as Uri,
      packageUri: null == packageUri
          ? _self.packageUri
          : packageUri // ignore: cast_nullable_to_non_nullable
              as String,
      languageVersion: null == languageVersion
          ? _self.languageVersion
          : languageVersion // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _PackageConfigItem implements PackageConfigItem {
  const _PackageConfigItem(
      {required this.name,
      required this.rootUri,
      required this.packageUri,
      required this.languageVersion});
  factory _PackageConfigItem.fromJson(Map<String, dynamic> json) =>
      _$PackageConfigItemFromJson(json);

  @override
  final String name;
  @override
  final Uri rootUri;
  @override
  final String packageUri;
  @override
  final String languageVersion;

  /// Create a copy of PackageConfigItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PackageConfigItemCopyWith<_PackageConfigItem> get copyWith =>
      __$PackageConfigItemCopyWithImpl<_PackageConfigItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PackageConfigItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PackageConfigItem &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.rootUri, rootUri) || other.rootUri == rootUri) &&
            (identical(other.packageUri, packageUri) ||
                other.packageUri == packageUri) &&
            (identical(other.languageVersion, languageVersion) ||
                other.languageVersion == languageVersion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, rootUri, packageUri, languageVersion);

  @override
  String toString() {
    return 'PackageConfigItem(name: $name, rootUri: $rootUri, packageUri: $packageUri, languageVersion: $languageVersion)';
  }
}

/// @nodoc
abstract mixin class _$PackageConfigItemCopyWith<$Res>
    implements $PackageConfigItemCopyWith<$Res> {
  factory _$PackageConfigItemCopyWith(
          _PackageConfigItem value, $Res Function(_PackageConfigItem) _then) =
      __$PackageConfigItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String name, Uri rootUri, String packageUri, String languageVersion});
}

/// @nodoc
class __$PackageConfigItemCopyWithImpl<$Res>
    implements _$PackageConfigItemCopyWith<$Res> {
  __$PackageConfigItemCopyWithImpl(this._self, this._then);

  final _PackageConfigItem _self;
  final $Res Function(_PackageConfigItem) _then;

  /// Create a copy of PackageConfigItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? rootUri = null,
    Object? packageUri = null,
    Object? languageVersion = null,
  }) {
    return _then(_PackageConfigItem(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      rootUri: null == rootUri
          ? _self.rootUri
          : rootUri // ignore: cast_nullable_to_non_nullable
              as Uri,
      packageUri: null == packageUri
          ? _self.packageUri
          : packageUri // ignore: cast_nullable_to_non_nullable
              as String,
      languageVersion: null == languageVersion
          ? _self.languageVersion
          : languageVersion // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
