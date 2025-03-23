// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'remove_command.dart';

class PubRemoveOptionsMapper extends ClassMapperBase<PubRemoveOptions> {
  PubRemoveOptionsMapper._();

  static PubRemoveOptionsMapper? _instance;
  static PubRemoveOptionsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PubRemoveOptionsMapper._());
      PubOptionsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PubRemoveOptions';

  static bool _$debug(PubRemoveOptions v) => v.debug;
  static const Field<PubRemoveOptions, bool> _f$debug = Field('debug', _$debug);
  static String? _$directory(PubRemoveOptions v) => v.directory;
  static const Field<PubRemoveOptions, String> _f$directory =
      Field('directory', _$directory);
  static String _$cacheDir(PubRemoveOptions v) => v.cacheDir;
  static const Field<PubRemoveOptions, String> _f$cacheDir =
      Field('cacheDir', _$cacheDir);
  static String _$patchDir(PubRemoveOptions v) => v.patchDir;
  static const Field<PubRemoveOptions, String> _f$patchDir =
      Field('patchDir', _$patchDir);
  static bool _$verbose(PubRemoveOptions v) => v.verbose;
  static const Field<PubRemoveOptions, bool> _f$verbose =
      Field('verbose', _$verbose);
  static bool? _$color(PubRemoveOptions v) => v.color;
  static const Field<PubRemoveOptions, bool> _f$color = Field('color', _$color);
  static bool _$offline(PubRemoveOptions v) => v.offline;
  static const Field<PubRemoveOptions, bool> _f$offline =
      Field('offline', _$offline);
  static bool _$dryRun(PubRemoveOptions v) => v.dryRun;
  static const Field<PubRemoveOptions, bool> _f$dryRun =
      Field('dryRun', _$dryRun);
  static bool _$precompile(PubRemoveOptions v) => v.precompile;
  static const Field<PubRemoveOptions, bool> _f$precompile =
      Field('precompile', _$precompile);

  @override
  final MappableFields<PubRemoveOptions> fields = const {
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

  static PubRemoveOptions _instantiate(DecodingData data) {
    return PubRemoveOptions(
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

  static PubRemoveOptions fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PubRemoveOptions>(map);
  }

  static PubRemoveOptions fromJson(String json) {
    return ensureInitialized().decodeJson<PubRemoveOptions>(json);
  }
}

mixin PubRemoveOptionsMappable {
  String toJson() {
    return PubRemoveOptionsMapper.ensureInitialized()
        .encodeJson<PubRemoveOptions>(this as PubRemoveOptions);
  }

  Map<String, dynamic> toMap() {
    return PubRemoveOptionsMapper.ensureInitialized()
        .encodeMap<PubRemoveOptions>(this as PubRemoveOptions);
  }

  PubRemoveOptionsCopyWith<PubRemoveOptions, PubRemoveOptions, PubRemoveOptions>
      get copyWith =>
          _PubRemoveOptionsCopyWithImpl<PubRemoveOptions, PubRemoveOptions>(
              this as PubRemoveOptions, $identity, $identity);
  @override
  String toString() {
    return PubRemoveOptionsMapper.ensureInitialized()
        .stringifyValue(this as PubRemoveOptions);
  }

  @override
  bool operator ==(Object other) {
    return PubRemoveOptionsMapper.ensureInitialized()
        .equalsValue(this as PubRemoveOptions, other);
  }

  @override
  int get hashCode {
    return PubRemoveOptionsMapper.ensureInitialized()
        .hashValue(this as PubRemoveOptions);
  }
}

extension PubRemoveOptionsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PubRemoveOptions, $Out> {
  PubRemoveOptionsCopyWith<$R, PubRemoveOptions, $Out>
      get $asPubRemoveOptions => $base
          .as((v, t, t2) => _PubRemoveOptionsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PubRemoveOptionsCopyWith<$R, $In extends PubRemoveOptions, $Out>
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
  PubRemoveOptionsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _PubRemoveOptionsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PubRemoveOptions, $Out>
    implements PubRemoveOptionsCopyWith<$R, PubRemoveOptions, $Out> {
  _PubRemoveOptionsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PubRemoveOptions> $mapper =
      PubRemoveOptionsMapper.ensureInitialized();
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
  PubRemoveOptions $make(CopyWithData data) => PubRemoveOptions(
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
  PubRemoveOptionsCopyWith<$R2, PubRemoveOptions, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _PubRemoveOptionsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
