// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'apply_command.dart';

class ApplyOptionsMapper extends ClassMapperBase<ApplyOptions> {
  ApplyOptionsMapper._();

  static ApplyOptionsMapper? _instance;
  static ApplyOptionsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ApplyOptionsMapper._());
      GlobalOptionsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ApplyOptions';

  static bool _$debug(ApplyOptions v) => v.debug;
  static const Field<ApplyOptions, bool> _f$debug = Field('debug', _$debug);
  static String? _$directory(ApplyOptions v) => v.directory;
  static const Field<ApplyOptions, String> _f$directory =
      Field('directory', _$directory);
  static String _$cacheDir(ApplyOptions v) => v.cacheDir;
  static const Field<ApplyOptions, String> _f$cacheDir =
      Field('cacheDir', _$cacheDir);
  static String _$patchDir(ApplyOptions v) => v.patchDir;
  static const Field<ApplyOptions, String> _f$patchDir =
      Field('patchDir', _$patchDir);
  static bool _$force(ApplyOptions v) => v.force;
  static const Field<ApplyOptions, bool> _f$force = Field('force', _$force);

  @override
  final MappableFields<ApplyOptions> fields = const {
    #debug: _f$debug,
    #directory: _f$directory,
    #cacheDir: _f$cacheDir,
    #patchDir: _f$patchDir,
    #force: _f$force,
  };

  static ApplyOptions _instantiate(DecodingData data) {
    return ApplyOptions(
        debug: data.dec(_f$debug),
        directory: data.dec(_f$directory),
        cacheDir: data.dec(_f$cacheDir),
        patchDir: data.dec(_f$patchDir),
        force: data.dec(_f$force));
  }

  @override
  final Function instantiate = _instantiate;

  static ApplyOptions fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ApplyOptions>(map);
  }

  static ApplyOptions fromJson(String json) {
    return ensureInitialized().decodeJson<ApplyOptions>(json);
  }
}

mixin ApplyOptionsMappable {
  String toJson() {
    return ApplyOptionsMapper.ensureInitialized()
        .encodeJson<ApplyOptions>(this as ApplyOptions);
  }

  Map<String, dynamic> toMap() {
    return ApplyOptionsMapper.ensureInitialized()
        .encodeMap<ApplyOptions>(this as ApplyOptions);
  }

  ApplyOptionsCopyWith<ApplyOptions, ApplyOptions, ApplyOptions> get copyWith =>
      _ApplyOptionsCopyWithImpl<ApplyOptions, ApplyOptions>(
          this as ApplyOptions, $identity, $identity);
  @override
  String toString() {
    return ApplyOptionsMapper.ensureInitialized()
        .stringifyValue(this as ApplyOptions);
  }

  @override
  bool operator ==(Object other) {
    return ApplyOptionsMapper.ensureInitialized()
        .equalsValue(this as ApplyOptions, other);
  }

  @override
  int get hashCode {
    return ApplyOptionsMapper.ensureInitialized()
        .hashValue(this as ApplyOptions);
  }
}

extension ApplyOptionsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ApplyOptions, $Out> {
  ApplyOptionsCopyWith<$R, ApplyOptions, $Out> get $asApplyOptions =>
      $base.as((v, t, t2) => _ApplyOptionsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ApplyOptionsCopyWith<$R, $In extends ApplyOptions, $Out>
    implements GlobalOptionsCopyWith<$R, $In, $Out> {
  @override
  $R call(
      {bool? debug,
      String? directory,
      String? cacheDir,
      String? patchDir,
      bool? force});
  ApplyOptionsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ApplyOptionsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ApplyOptions, $Out>
    implements ApplyOptionsCopyWith<$R, ApplyOptions, $Out> {
  _ApplyOptionsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ApplyOptions> $mapper =
      ApplyOptionsMapper.ensureInitialized();
  @override
  $R call(
          {bool? debug,
          Object? directory = $none,
          String? cacheDir,
          String? patchDir,
          bool? force}) =>
      $apply(FieldCopyWithData({
        if (debug != null) #debug: debug,
        if (directory != $none) #directory: directory,
        if (cacheDir != null) #cacheDir: cacheDir,
        if (patchDir != null) #patchDir: patchDir,
        if (force != null) #force: force
      }));
  @override
  ApplyOptions $make(CopyWithData data) => ApplyOptions(
      debug: data.get(#debug, or: $value.debug),
      directory: data.get(#directory, or: $value.directory),
      cacheDir: data.get(#cacheDir, or: $value.cacheDir),
      patchDir: data.get(#patchDir, or: $value.patchDir),
      force: data.get(#force, or: $value.force));

  @override
  ApplyOptionsCopyWith<$R2, ApplyOptions, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _ApplyOptionsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
