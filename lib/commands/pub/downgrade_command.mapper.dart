// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'downgrade_command.dart';

class PubDowngradeOptionsMapper extends ClassMapperBase<PubDowngradeOptions> {
  PubDowngradeOptionsMapper._();

  static PubDowngradeOptionsMapper? _instance;
  static PubDowngradeOptionsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PubDowngradeOptionsMapper._());
      PubOptionsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PubDowngradeOptions';

  static bool _$debug(PubDowngradeOptions v) => v.debug;
  static const Field<PubDowngradeOptions, bool> _f$debug =
      Field('debug', _$debug);
  static String? _$directory(PubDowngradeOptions v) => v.directory;
  static const Field<PubDowngradeOptions, String> _f$directory =
      Field('directory', _$directory);
  static String _$cacheDir(PubDowngradeOptions v) => v.cacheDir;
  static const Field<PubDowngradeOptions, String> _f$cacheDir =
      Field('cacheDir', _$cacheDir);
  static String _$patchDir(PubDowngradeOptions v) => v.patchDir;
  static const Field<PubDowngradeOptions, String> _f$patchDir =
      Field('patchDir', _$patchDir);
  static bool _$verbose(PubDowngradeOptions v) => v.verbose;
  static const Field<PubDowngradeOptions, bool> _f$verbose =
      Field('verbose', _$verbose);
  static bool? _$color(PubDowngradeOptions v) => v.color;
  static const Field<PubDowngradeOptions, bool> _f$color =
      Field('color', _$color);
  static bool _$offline(PubDowngradeOptions v) => v.offline;
  static const Field<PubDowngradeOptions, bool> _f$offline =
      Field('offline', _$offline);
  static bool _$dryRun(PubDowngradeOptions v) => v.dryRun;
  static const Field<PubDowngradeOptions, bool> _f$dryRun =
      Field('dryRun', _$dryRun);
  static bool _$tighten(PubDowngradeOptions v) => v.tighten;
  static const Field<PubDowngradeOptions, bool> _f$tighten =
      Field('tighten', _$tighten);

  @override
  final MappableFields<PubDowngradeOptions> fields = const {
    #debug: _f$debug,
    #directory: _f$directory,
    #cacheDir: _f$cacheDir,
    #patchDir: _f$patchDir,
    #verbose: _f$verbose,
    #color: _f$color,
    #offline: _f$offline,
    #dryRun: _f$dryRun,
    #tighten: _f$tighten,
  };

  static PubDowngradeOptions _instantiate(DecodingData data) {
    return PubDowngradeOptions(
        debug: data.dec(_f$debug),
        directory: data.dec(_f$directory),
        cacheDir: data.dec(_f$cacheDir),
        patchDir: data.dec(_f$patchDir),
        verbose: data.dec(_f$verbose),
        color: data.dec(_f$color),
        offline: data.dec(_f$offline),
        dryRun: data.dec(_f$dryRun),
        tighten: data.dec(_f$tighten));
  }

  @override
  final Function instantiate = _instantiate;

  static PubDowngradeOptions fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PubDowngradeOptions>(map);
  }

  static PubDowngradeOptions fromJson(String json) {
    return ensureInitialized().decodeJson<PubDowngradeOptions>(json);
  }
}

mixin PubDowngradeOptionsMappable {
  String toJson() {
    return PubDowngradeOptionsMapper.ensureInitialized()
        .encodeJson<PubDowngradeOptions>(this as PubDowngradeOptions);
  }

  Map<String, dynamic> toMap() {
    return PubDowngradeOptionsMapper.ensureInitialized()
        .encodeMap<PubDowngradeOptions>(this as PubDowngradeOptions);
  }

  PubDowngradeOptionsCopyWith<PubDowngradeOptions, PubDowngradeOptions,
      PubDowngradeOptions> get copyWith => _PubDowngradeOptionsCopyWithImpl<
          PubDowngradeOptions, PubDowngradeOptions>(
      this as PubDowngradeOptions, $identity, $identity);
  @override
  String toString() {
    return PubDowngradeOptionsMapper.ensureInitialized()
        .stringifyValue(this as PubDowngradeOptions);
  }

  @override
  bool operator ==(Object other) {
    return PubDowngradeOptionsMapper.ensureInitialized()
        .equalsValue(this as PubDowngradeOptions, other);
  }

  @override
  int get hashCode {
    return PubDowngradeOptionsMapper.ensureInitialized()
        .hashValue(this as PubDowngradeOptions);
  }
}

extension PubDowngradeOptionsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PubDowngradeOptions, $Out> {
  PubDowngradeOptionsCopyWith<$R, PubDowngradeOptions, $Out>
      get $asPubDowngradeOptions => $base.as(
          (v, t, t2) => _PubDowngradeOptionsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PubDowngradeOptionsCopyWith<$R, $In extends PubDowngradeOptions,
    $Out> implements PubOptionsCopyWith<$R, $In, $Out> {
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
      bool? tighten});
  PubDowngradeOptionsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _PubDowngradeOptionsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PubDowngradeOptions, $Out>
    implements PubDowngradeOptionsCopyWith<$R, PubDowngradeOptions, $Out> {
  _PubDowngradeOptionsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PubDowngradeOptions> $mapper =
      PubDowngradeOptionsMapper.ensureInitialized();
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
          bool? tighten}) =>
      $apply(FieldCopyWithData({
        if (debug != null) #debug: debug,
        if (directory != $none) #directory: directory,
        if (cacheDir != null) #cacheDir: cacheDir,
        if (patchDir != null) #patchDir: patchDir,
        if (verbose != null) #verbose: verbose,
        if (color != $none) #color: color,
        if (offline != null) #offline: offline,
        if (dryRun != null) #dryRun: dryRun,
        if (tighten != null) #tighten: tighten
      }));
  @override
  PubDowngradeOptions $make(CopyWithData data) => PubDowngradeOptions(
      debug: data.get(#debug, or: $value.debug),
      directory: data.get(#directory, or: $value.directory),
      cacheDir: data.get(#cacheDir, or: $value.cacheDir),
      patchDir: data.get(#patchDir, or: $value.patchDir),
      verbose: data.get(#verbose, or: $value.verbose),
      color: data.get(#color, or: $value.color),
      offline: data.get(#offline, or: $value.offline),
      dryRun: data.get(#dryRun, or: $value.dryRun),
      tighten: data.get(#tighten, or: $value.tighten));

  @override
  PubDowngradeOptionsCopyWith<$R2, PubDowngradeOptions, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _PubDowngradeOptionsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
