// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'global_args.dart';

class GlobalOptionsMapper extends ClassMapperBase<GlobalOptions> {
  GlobalOptionsMapper._();

  static GlobalOptionsMapper? _instance;
  static GlobalOptionsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GlobalOptionsMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'GlobalOptions';

  static bool _$debug(GlobalOptions v) => v.debug;
  static const Field<GlobalOptions, bool> _f$debug = Field('debug', _$debug);
  static String? _$directory(GlobalOptions v) => v.directory;
  static const Field<GlobalOptions, String> _f$directory =
      Field('directory', _$directory);
  static String _$cacheDir(GlobalOptions v) => v.cacheDir;
  static const Field<GlobalOptions, String> _f$cacheDir =
      Field('cacheDir', _$cacheDir);
  static String _$patchDir(GlobalOptions v) => v.patchDir;
  static const Field<GlobalOptions, String> _f$patchDir =
      Field('patchDir', _$patchDir);

  @override
  final MappableFields<GlobalOptions> fields = const {
    #debug: _f$debug,
    #directory: _f$directory,
    #cacheDir: _f$cacheDir,
    #patchDir: _f$patchDir,
  };

  static GlobalOptions _instantiate(DecodingData data) {
    return GlobalOptions(
        debug: data.dec(_f$debug),
        directory: data.dec(_f$directory),
        cacheDir: data.dec(_f$cacheDir),
        patchDir: data.dec(_f$patchDir));
  }

  @override
  final Function instantiate = _instantiate;

  static GlobalOptions fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GlobalOptions>(map);
  }

  static GlobalOptions fromJson(String json) {
    return ensureInitialized().decodeJson<GlobalOptions>(json);
  }
}

mixin GlobalOptionsMappable {
  String toJson() {
    return GlobalOptionsMapper.ensureInitialized()
        .encodeJson<GlobalOptions>(this as GlobalOptions);
  }

  Map<String, dynamic> toMap() {
    return GlobalOptionsMapper.ensureInitialized()
        .encodeMap<GlobalOptions>(this as GlobalOptions);
  }

  GlobalOptionsCopyWith<GlobalOptions, GlobalOptions, GlobalOptions>
      get copyWith => _GlobalOptionsCopyWithImpl<GlobalOptions, GlobalOptions>(
          this as GlobalOptions, $identity, $identity);
  @override
  String toString() {
    return GlobalOptionsMapper.ensureInitialized()
        .stringifyValue(this as GlobalOptions);
  }

  @override
  bool operator ==(Object other) {
    return GlobalOptionsMapper.ensureInitialized()
        .equalsValue(this as GlobalOptions, other);
  }

  @override
  int get hashCode {
    return GlobalOptionsMapper.ensureInitialized()
        .hashValue(this as GlobalOptions);
  }
}

extension GlobalOptionsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, GlobalOptions, $Out> {
  GlobalOptionsCopyWith<$R, GlobalOptions, $Out> get $asGlobalOptions =>
      $base.as((v, t, t2) => _GlobalOptionsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class GlobalOptionsCopyWith<$R, $In extends GlobalOptions, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({bool? debug, String? directory, String? cacheDir, String? patchDir});
  GlobalOptionsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _GlobalOptionsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, GlobalOptions, $Out>
    implements GlobalOptionsCopyWith<$R, GlobalOptions, $Out> {
  _GlobalOptionsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GlobalOptions> $mapper =
      GlobalOptionsMapper.ensureInitialized();
  @override
  $R call(
          {bool? debug,
          Object? directory = $none,
          String? cacheDir,
          String? patchDir}) =>
      $apply(FieldCopyWithData({
        if (debug != null) #debug: debug,
        if (directory != $none) #directory: directory,
        if (cacheDir != null) #cacheDir: cacheDir,
        if (patchDir != null) #patchDir: patchDir
      }));
  @override
  GlobalOptions $make(CopyWithData data) => GlobalOptions(
      debug: data.get(#debug, or: $value.debug),
      directory: data.get(#directory, or: $value.directory),
      cacheDir: data.get(#cacheDir, or: $value.cacheDir),
      patchDir: data.get(#patchDir, or: $value.patchDir));

  @override
  GlobalOptionsCopyWith<$R2, GlobalOptions, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _GlobalOptionsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
