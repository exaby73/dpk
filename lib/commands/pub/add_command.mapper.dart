// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'add_command.dart';

class PubAddOptionsMapper extends ClassMapperBase<PubAddOptions> {
  PubAddOptionsMapper._();

  static PubAddOptionsMapper? _instance;
  static PubAddOptionsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PubAddOptionsMapper._());
      PubOptionsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PubAddOptions';

  static bool _$debug(PubAddOptions v) => v.debug;
  static const Field<PubAddOptions, bool> _f$debug = Field('debug', _$debug);
  static String? _$directory(PubAddOptions v) => v.directory;
  static const Field<PubAddOptions, String> _f$directory =
      Field('directory', _$directory);
  static String _$cacheDir(PubAddOptions v) => v.cacheDir;
  static const Field<PubAddOptions, String> _f$cacheDir =
      Field('cacheDir', _$cacheDir);
  static String _$patchDir(PubAddOptions v) => v.patchDir;
  static const Field<PubAddOptions, String> _f$patchDir =
      Field('patchDir', _$patchDir);
  static bool _$verbose(PubAddOptions v) => v.verbose;
  static const Field<PubAddOptions, bool> _f$verbose =
      Field('verbose', _$verbose);
  static bool? _$color(PubAddOptions v) => v.color;
  static const Field<PubAddOptions, bool> _f$color = Field('color', _$color);
  static bool _$offline(PubAddOptions v) => v.offline;
  static const Field<PubAddOptions, bool> _f$offline =
      Field('offline', _$offline);
  static bool _$dryRun(PubAddOptions v) => v.dryRun;
  static const Field<PubAddOptions, bool> _f$dryRun = Field('dryRun', _$dryRun);
  static bool _$precompile(PubAddOptions v) => v.precompile;
  static const Field<PubAddOptions, bool> _f$precompile =
      Field('precompile', _$precompile);

  @override
  final MappableFields<PubAddOptions> fields = const {
    #debug: _f$debug,
    #directory: _f$directory,
    #cacheDir: _f$cacheDir,
    #patchDir: _f$patchDir,
    #verbose: _f$verbose,
    #color: _f$color,
    #offline: _f$offline,
    #dryRun: _f$dryRun,
    #precompile: _f$precompile,
  };

  static PubAddOptions _instantiate(DecodingData data) {
    return PubAddOptions(
        debug: data.dec(_f$debug),
        directory: data.dec(_f$directory),
        cacheDir: data.dec(_f$cacheDir),
        patchDir: data.dec(_f$patchDir),
        verbose: data.dec(_f$verbose),
        color: data.dec(_f$color),
        offline: data.dec(_f$offline),
        dryRun: data.dec(_f$dryRun),
        precompile: data.dec(_f$precompile));
  }

  @override
  final Function instantiate = _instantiate;

  static PubAddOptions fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PubAddOptions>(map);
  }

  static PubAddOptions fromJson(String json) {
    return ensureInitialized().decodeJson<PubAddOptions>(json);
  }
}

mixin PubAddOptionsMappable {
  String toJson() {
    return PubAddOptionsMapper.ensureInitialized()
        .encodeJson<PubAddOptions>(this as PubAddOptions);
  }

  Map<String, dynamic> toMap() {
    return PubAddOptionsMapper.ensureInitialized()
        .encodeMap<PubAddOptions>(this as PubAddOptions);
  }

  PubAddOptionsCopyWith<PubAddOptions, PubAddOptions, PubAddOptions>
      get copyWith => _PubAddOptionsCopyWithImpl<PubAddOptions, PubAddOptions>(
          this as PubAddOptions, $identity, $identity);
  @override
  String toString() {
    return PubAddOptionsMapper.ensureInitialized()
        .stringifyValue(this as PubAddOptions);
  }

  @override
  bool operator ==(Object other) {
    return PubAddOptionsMapper.ensureInitialized()
        .equalsValue(this as PubAddOptions, other);
  }

  @override
  int get hashCode {
    return PubAddOptionsMapper.ensureInitialized()
        .hashValue(this as PubAddOptions);
  }
}

extension PubAddOptionsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PubAddOptions, $Out> {
  PubAddOptionsCopyWith<$R, PubAddOptions, $Out> get $asPubAddOptions =>
      $base.as((v, t, t2) => _PubAddOptionsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PubAddOptionsCopyWith<$R, $In extends PubAddOptions, $Out>
    implements PubOptionsCopyWith<$R, $In, $Out> {
  @override
  $R call(
      {bool? debug,
      String? directory,
      String? cacheDir,
      String? patchDir,
      bool? verbose,
      bool? color,
      bool? offline,
      bool? dryRun,
      bool? precompile});
  PubAddOptionsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PubAddOptionsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PubAddOptions, $Out>
    implements PubAddOptionsCopyWith<$R, PubAddOptions, $Out> {
  _PubAddOptionsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PubAddOptions> $mapper =
      PubAddOptionsMapper.ensureInitialized();
  @override
  $R call(
          {bool? debug,
          Object? directory = $none,
          String? cacheDir,
          String? patchDir,
          bool? verbose,
          Object? color = $none,
          bool? offline,
          bool? dryRun,
          bool? precompile}) =>
      $apply(FieldCopyWithData({
        if (debug != null) #debug: debug,
        if (directory != $none) #directory: directory,
        if (cacheDir != null) #cacheDir: cacheDir,
        if (patchDir != null) #patchDir: patchDir,
        if (verbose != null) #verbose: verbose,
        if (color != $none) #color: color,
        if (offline != null) #offline: offline,
        if (dryRun != null) #dryRun: dryRun,
        if (precompile != null) #precompile: precompile
      }));
  @override
  PubAddOptions $make(CopyWithData data) => PubAddOptions(
      debug: data.get(#debug, or: $value.debug),
      directory: data.get(#directory, or: $value.directory),
      cacheDir: data.get(#cacheDir, or: $value.cacheDir),
      patchDir: data.get(#patchDir, or: $value.patchDir),
      verbose: data.get(#verbose, or: $value.verbose),
      color: data.get(#color, or: $value.color),
      offline: data.get(#offline, or: $value.offline),
      dryRun: data.get(#dryRun, or: $value.dryRun),
      precompile: data.get(#precompile, or: $value.precompile));

  @override
  PubAddOptionsCopyWith<$R2, PubAddOptions, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _PubAddOptionsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
