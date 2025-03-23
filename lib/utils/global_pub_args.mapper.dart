// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'global_pub_args.dart';

class PubOptionsMapper extends ClassMapperBase<PubOptions> {
  PubOptionsMapper._();

  static PubOptionsMapper? _instance;
  static PubOptionsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PubOptionsMapper._());
      GlobalOptionsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PubOptions';

  static bool _$debug(PubOptions v) => v.debug;
  static const Field<PubOptions, bool> _f$debug = Field('debug', _$debug);
  static String? _$directory(PubOptions v) => v.directory;
  static const Field<PubOptions, String> _f$directory =
      Field('directory', _$directory);
  static String _$cacheDir(PubOptions v) => v.cacheDir;
  static const Field<PubOptions, String> _f$cacheDir =
      Field('cacheDir', _$cacheDir);
  static String _$patchDir(PubOptions v) => v.patchDir;
  static const Field<PubOptions, String> _f$patchDir =
      Field('patchDir', _$patchDir);
  static bool _$verbose(PubOptions v) => v.verbose;
  static const Field<PubOptions, bool> _f$verbose = Field('verbose', _$verbose);
  static bool? _$color(PubOptions v) => v.color;
  static const Field<PubOptions, bool> _f$color = Field('color', _$color);

  @override
  final MappableFields<PubOptions> fields = const {
    #debug: _f$debug,
    #directory: _f$directory,
    #cacheDir: _f$cacheDir,
    #patchDir: _f$patchDir,
    #verbose: _f$verbose,
    #color: _f$color,
  };

  static PubOptions _instantiate(DecodingData data) {
    return PubOptions(
        debug: data.dec(_f$debug),
        directory: data.dec(_f$directory),
        cacheDir: data.dec(_f$cacheDir),
        patchDir: data.dec(_f$patchDir),
        verbose: data.dec(_f$verbose),
        color: data.dec(_f$color));
  }

  @override
  final Function instantiate = _instantiate;

  static PubOptions fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PubOptions>(map);
  }

  static PubOptions fromJson(String json) {
    return ensureInitialized().decodeJson<PubOptions>(json);
  }
}

mixin PubOptionsMappable {
  String toJson() {
    return PubOptionsMapper.ensureInitialized()
        .encodeJson<PubOptions>(this as PubOptions);
  }

  Map<String, dynamic> toMap() {
    return PubOptionsMapper.ensureInitialized()
        .encodeMap<PubOptions>(this as PubOptions);
  }

  PubOptionsCopyWith<PubOptions, PubOptions, PubOptions> get copyWith =>
      _PubOptionsCopyWithImpl<PubOptions, PubOptions>(
          this as PubOptions, $identity, $identity);
  @override
  String toString() {
    return PubOptionsMapper.ensureInitialized()
        .stringifyValue(this as PubOptions);
  }

  @override
  bool operator ==(Object other) {
    return PubOptionsMapper.ensureInitialized()
        .equalsValue(this as PubOptions, other);
  }

  @override
  int get hashCode {
    return PubOptionsMapper.ensureInitialized().hashValue(this as PubOptions);
  }
}

extension PubOptionsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PubOptions, $Out> {
  PubOptionsCopyWith<$R, PubOptions, $Out> get $asPubOptions =>
      $base.as((v, t, t2) => _PubOptionsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PubOptionsCopyWith<$R, $In extends PubOptions, $Out>
    implements GlobalOptionsCopyWith<$R, $In, $Out> {
  @override
  $R call(
      {bool? debug,
      String? directory,
      String? cacheDir,
      String? patchDir,
      bool? verbose,
      bool? color});
  PubOptionsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PubOptionsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PubOptions, $Out>
    implements PubOptionsCopyWith<$R, PubOptions, $Out> {
  _PubOptionsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PubOptions> $mapper =
      PubOptionsMapper.ensureInitialized();
  @override
  $R call(
          {bool? debug,
          Object? directory = $none,
          String? cacheDir,
          String? patchDir,
          bool? verbose,
          Object? color = $none}) =>
      $apply(FieldCopyWithData({
        if (debug != null) #debug: debug,
        if (directory != $none) #directory: directory,
        if (cacheDir != null) #cacheDir: cacheDir,
        if (patchDir != null) #patchDir: patchDir,
        if (verbose != null) #verbose: verbose,
        if (color != $none) #color: color
      }));
  @override
  PubOptions $make(CopyWithData data) => PubOptions(
      debug: data.get(#debug, or: $value.debug),
      directory: data.get(#directory, or: $value.directory),
      cacheDir: data.get(#cacheDir, or: $value.cacheDir),
      patchDir: data.get(#patchDir, or: $value.patchDir),
      verbose: data.get(#verbose, or: $value.verbose),
      color: data.get(#color, or: $value.color));

  @override
  PubOptionsCopyWith<$R2, PubOptions, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _PubOptionsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
