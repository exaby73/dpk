// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'get_command.dart';

class PubGetOptionsMapper extends ClassMapperBase<PubGetOptions> {
  PubGetOptionsMapper._();

  static PubGetOptionsMapper? _instance;
  static PubGetOptionsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PubGetOptionsMapper._());
      PubOptionsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PubGetOptions';

  static bool _$debug(PubGetOptions v) => v.debug;
  static const Field<PubGetOptions, bool> _f$debug = Field('debug', _$debug);
  static String? _$directory(PubGetOptions v) => v.directory;
  static const Field<PubGetOptions, String> _f$directory =
      Field('directory', _$directory);
  static String _$cacheDir(PubGetOptions v) => v.cacheDir;
  static const Field<PubGetOptions, String> _f$cacheDir =
      Field('cacheDir', _$cacheDir);
  static String _$patchDir(PubGetOptions v) => v.patchDir;
  static const Field<PubGetOptions, String> _f$patchDir =
      Field('patchDir', _$patchDir);
  static bool _$verbose(PubGetOptions v) => v.verbose;
  static const Field<PubGetOptions, bool> _f$verbose =
      Field('verbose', _$verbose);
  static bool? _$color(PubGetOptions v) => v.color;
  static const Field<PubGetOptions, bool> _f$color = Field('color', _$color);
  static bool _$offline(PubGetOptions v) => v.offline;
  static const Field<PubGetOptions, bool> _f$offline =
      Field('offline', _$offline);
  static bool _$dryRun(PubGetOptions v) => v.dryRun;
  static const Field<PubGetOptions, bool> _f$dryRun = Field('dryRun', _$dryRun);
  static bool _$enforceLockfile(PubGetOptions v) => v.enforceLockfile;
  static const Field<PubGetOptions, bool> _f$enforceLockfile =
      Field('enforceLockfile', _$enforceLockfile);
  static bool _$precompile(PubGetOptions v) => v.precompile;
  static const Field<PubGetOptions, bool> _f$precompile =
      Field('precompile', _$precompile);

  @override
  final MappableFields<PubGetOptions> fields = const {
    #debug: _f$debug,
    #directory: _f$directory,
    #cacheDir: _f$cacheDir,
    #patchDir: _f$patchDir,
    #verbose: _f$verbose,
    #color: _f$color,
    #offline: _f$offline,
    #dryRun: _f$dryRun,
    #enforceLockfile: _f$enforceLockfile,
    #precompile: _f$precompile,
  };

  static PubGetOptions _instantiate(DecodingData data) {
    return PubGetOptions(
        debug: data.dec(_f$debug),
        directory: data.dec(_f$directory),
        cacheDir: data.dec(_f$cacheDir),
        patchDir: data.dec(_f$patchDir),
        verbose: data.dec(_f$verbose),
        color: data.dec(_f$color),
        offline: data.dec(_f$offline),
        dryRun: data.dec(_f$dryRun),
        enforceLockfile: data.dec(_f$enforceLockfile),
        precompile: data.dec(_f$precompile));
  }

  @override
  final Function instantiate = _instantiate;

  static PubGetOptions fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PubGetOptions>(map);
  }

  static PubGetOptions fromJson(String json) {
    return ensureInitialized().decodeJson<PubGetOptions>(json);
  }
}

mixin PubGetOptionsMappable {
  String toJson() {
    return PubGetOptionsMapper.ensureInitialized()
        .encodeJson<PubGetOptions>(this as PubGetOptions);
  }

  Map<String, dynamic> toMap() {
    return PubGetOptionsMapper.ensureInitialized()
        .encodeMap<PubGetOptions>(this as PubGetOptions);
  }

  PubGetOptionsCopyWith<PubGetOptions, PubGetOptions, PubGetOptions>
      get copyWith => _PubGetOptionsCopyWithImpl<PubGetOptions, PubGetOptions>(
          this as PubGetOptions, $identity, $identity);
  @override
  String toString() {
    return PubGetOptionsMapper.ensureInitialized()
        .stringifyValue(this as PubGetOptions);
  }

  @override
  bool operator ==(Object other) {
    return PubGetOptionsMapper.ensureInitialized()
        .equalsValue(this as PubGetOptions, other);
  }

  @override
  int get hashCode {
    return PubGetOptionsMapper.ensureInitialized()
        .hashValue(this as PubGetOptions);
  }
}

extension PubGetOptionsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PubGetOptions, $Out> {
  PubGetOptionsCopyWith<$R, PubGetOptions, $Out> get $asPubGetOptions =>
      $base.as((v, t, t2) => _PubGetOptionsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PubGetOptionsCopyWith<$R, $In extends PubGetOptions, $Out>
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
      bool? enforceLockfile,
      bool? precompile});
  PubGetOptionsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PubGetOptionsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PubGetOptions, $Out>
    implements PubGetOptionsCopyWith<$R, PubGetOptions, $Out> {
  _PubGetOptionsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PubGetOptions> $mapper =
      PubGetOptionsMapper.ensureInitialized();
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
          bool? enforceLockfile,
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
        if (enforceLockfile != null) #enforceLockfile: enforceLockfile,
        if (precompile != null) #precompile: precompile
      }));
  @override
  PubGetOptions $make(CopyWithData data) => PubGetOptions(
      debug: data.get(#debug, or: $value.debug),
      directory: data.get(#directory, or: $value.directory),
      cacheDir: data.get(#cacheDir, or: $value.cacheDir),
      patchDir: data.get(#patchDir, or: $value.patchDir),
      verbose: data.get(#verbose, or: $value.verbose),
      color: data.get(#color, or: $value.color),
      offline: data.get(#offline, or: $value.offline),
      dryRun: data.get(#dryRun, or: $value.dryRun),
      enforceLockfile: data.get(#enforceLockfile, or: $value.enforceLockfile),
      precompile: data.get(#precompile, or: $value.precompile));

  @override
  PubGetOptionsCopyWith<$R2, PubGetOptions, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _PubGetOptionsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
