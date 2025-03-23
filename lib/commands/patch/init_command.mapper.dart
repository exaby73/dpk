// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'init_command.dart';

class PatchOptionsMapper extends ClassMapperBase<PatchOptions> {
  PatchOptionsMapper._();

  static PatchOptionsMapper? _instance;
  static PatchOptionsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PatchOptionsMapper._());
      GlobalOptionsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PatchOptions';

  static bool _$debug(PatchOptions v) => v.debug;
  static const Field<PatchOptions, bool> _f$debug = Field('debug', _$debug);
  static String? _$directory(PatchOptions v) => v.directory;
  static const Field<PatchOptions, String> _f$directory =
      Field('directory', _$directory);
  static String _$cacheDir(PatchOptions v) => v.cacheDir;
  static const Field<PatchOptions, String> _f$cacheDir =
      Field('cacheDir', _$cacheDir);
  static String _$patchDir(PatchOptions v) => v.patchDir;
  static const Field<PatchOptions, String> _f$patchDir =
      Field('patchDir', _$patchDir);
  static bool _$force(PatchOptions v) => v.force;
  static const Field<PatchOptions, bool> _f$force = Field('force', _$force);

  @override
  final MappableFields<PatchOptions> fields = const {
    #debug: _f$debug,
    #directory: _f$directory,
    #cacheDir: _f$cacheDir,
    #patchDir: _f$patchDir,
    #force: _f$force,
  };

  static PatchOptions _instantiate(DecodingData data) {
    return PatchOptions(
        debug: data.dec(_f$debug),
        directory: data.dec(_f$directory),
        cacheDir: data.dec(_f$cacheDir),
        patchDir: data.dec(_f$patchDir),
        force: data.dec(_f$force));
  }

  @override
  final Function instantiate = _instantiate;

  static PatchOptions fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PatchOptions>(map);
  }

  static PatchOptions fromJson(String json) {
    return ensureInitialized().decodeJson<PatchOptions>(json);
  }
}

mixin PatchOptionsMappable {
  String toJson() {
    return PatchOptionsMapper.ensureInitialized()
        .encodeJson<PatchOptions>(this as PatchOptions);
  }

  Map<String, dynamic> toMap() {
    return PatchOptionsMapper.ensureInitialized()
        .encodeMap<PatchOptions>(this as PatchOptions);
  }

  PatchOptionsCopyWith<PatchOptions, PatchOptions, PatchOptions> get copyWith =>
      _PatchOptionsCopyWithImpl<PatchOptions, PatchOptions>(
          this as PatchOptions, $identity, $identity);
  @override
  String toString() {
    return PatchOptionsMapper.ensureInitialized()
        .stringifyValue(this as PatchOptions);
  }

  @override
  bool operator ==(Object other) {
    return PatchOptionsMapper.ensureInitialized()
        .equalsValue(this as PatchOptions, other);
  }

  @override
  int get hashCode {
    return PatchOptionsMapper.ensureInitialized()
        .hashValue(this as PatchOptions);
  }
}

extension PatchOptionsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PatchOptions, $Out> {
  PatchOptionsCopyWith<$R, PatchOptions, $Out> get $asPatchOptions =>
      $base.as((v, t, t2) => _PatchOptionsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PatchOptionsCopyWith<$R, $In extends PatchOptions, $Out>
    implements GlobalOptionsCopyWith<$R, $In, $Out> {
  @override
  $R call(
      {bool? debug,
      String? directory,
      String? cacheDir,
      String? patchDir,
      bool? force});
  PatchOptionsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PatchOptionsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PatchOptions, $Out>
    implements PatchOptionsCopyWith<$R, PatchOptions, $Out> {
  _PatchOptionsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PatchOptions> $mapper =
      PatchOptionsMapper.ensureInitialized();
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
  PatchOptions $make(CopyWithData data) => PatchOptions(
      debug: data.get(#debug, or: $value.debug),
      directory: data.get(#directory, or: $value.directory),
      cacheDir: data.get(#cacheDir, or: $value.cacheDir),
      patchDir: data.get(#patchDir, or: $value.patchDir),
      force: data.get(#force, or: $value.force));

  @override
  PatchOptionsCopyWith<$R2, PatchOptions, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _PatchOptionsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
