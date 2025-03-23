// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'upgrade_command.dart';

class PubUpgradeOptionsMapper extends ClassMapperBase<PubUpgradeOptions> {
  PubUpgradeOptionsMapper._();

  static PubUpgradeOptionsMapper? _instance;
  static PubUpgradeOptionsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PubUpgradeOptionsMapper._());
      PubOptionsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PubUpgradeOptions';

  static bool _$debug(PubUpgradeOptions v) => v.debug;
  static const Field<PubUpgradeOptions, bool> _f$debug =
      Field('debug', _$debug);
  static String? _$directory(PubUpgradeOptions v) => v.directory;
  static const Field<PubUpgradeOptions, String> _f$directory =
      Field('directory', _$directory);
  static String _$cacheDir(PubUpgradeOptions v) => v.cacheDir;
  static const Field<PubUpgradeOptions, String> _f$cacheDir =
      Field('cacheDir', _$cacheDir);
  static String _$patchDir(PubUpgradeOptions v) => v.patchDir;
  static const Field<PubUpgradeOptions, String> _f$patchDir =
      Field('patchDir', _$patchDir);
  static bool _$verbose(PubUpgradeOptions v) => v.verbose;
  static const Field<PubUpgradeOptions, bool> _f$verbose =
      Field('verbose', _$verbose);
  static bool? _$color(PubUpgradeOptions v) => v.color;
  static const Field<PubUpgradeOptions, bool> _f$color =
      Field('color', _$color);
  static bool _$offline(PubUpgradeOptions v) => v.offline;
  static const Field<PubUpgradeOptions, bool> _f$offline =
      Field('offline', _$offline);
  static bool _$dryRun(PubUpgradeOptions v) => v.dryRun;
  static const Field<PubUpgradeOptions, bool> _f$dryRun =
      Field('dryRun', _$dryRun);
  static bool _$precompile(PubUpgradeOptions v) => v.precompile;
  static const Field<PubUpgradeOptions, bool> _f$precompile =
      Field('precompile', _$precompile);
  static bool _$tighten(PubUpgradeOptions v) => v.tighten;
  static const Field<PubUpgradeOptions, bool> _f$tighten =
      Field('tighten', _$tighten);
  static bool _$unlockTransitive(PubUpgradeOptions v) => v.unlockTransitive;
  static const Field<PubUpgradeOptions, bool> _f$unlockTransitive =
      Field('unlockTransitive', _$unlockTransitive);
  static bool _$majorVersions(PubUpgradeOptions v) => v.majorVersions;
  static const Field<PubUpgradeOptions, bool> _f$majorVersions =
      Field('majorVersions', _$majorVersions);

  @override
  final MappableFields<PubUpgradeOptions> fields = const {
    #debug: _f$debug,
    #directory: _f$directory,
    #cacheDir: _f$cacheDir,
    #patchDir: _f$patchDir,
    #verbose: _f$verbose,
    #color: _f$color,
    #offline: _f$offline,
    #dryRun: _f$dryRun,
    #precompile: _f$precompile,
    #tighten: _f$tighten,
    #unlockTransitive: _f$unlockTransitive,
    #majorVersions: _f$majorVersions,
  };

  static PubUpgradeOptions _instantiate(DecodingData data) {
    return PubUpgradeOptions(
        debug: data.dec(_f$debug),
        directory: data.dec(_f$directory),
        cacheDir: data.dec(_f$cacheDir),
        patchDir: data.dec(_f$patchDir),
        verbose: data.dec(_f$verbose),
        color: data.dec(_f$color),
        offline: data.dec(_f$offline),
        dryRun: data.dec(_f$dryRun),
        precompile: data.dec(_f$precompile),
        tighten: data.dec(_f$tighten),
        unlockTransitive: data.dec(_f$unlockTransitive),
        majorVersions: data.dec(_f$majorVersions));
  }

  @override
  final Function instantiate = _instantiate;

  static PubUpgradeOptions fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PubUpgradeOptions>(map);
  }

  static PubUpgradeOptions fromJson(String json) {
    return ensureInitialized().decodeJson<PubUpgradeOptions>(json);
  }
}

mixin PubUpgradeOptionsMappable {
  String toJson() {
    return PubUpgradeOptionsMapper.ensureInitialized()
        .encodeJson<PubUpgradeOptions>(this as PubUpgradeOptions);
  }

  Map<String, dynamic> toMap() {
    return PubUpgradeOptionsMapper.ensureInitialized()
        .encodeMap<PubUpgradeOptions>(this as PubUpgradeOptions);
  }

  PubUpgradeOptionsCopyWith<PubUpgradeOptions, PubUpgradeOptions,
          PubUpgradeOptions>
      get copyWith =>
          _PubUpgradeOptionsCopyWithImpl<PubUpgradeOptions, PubUpgradeOptions>(
              this as PubUpgradeOptions, $identity, $identity);
  @override
  String toString() {
    return PubUpgradeOptionsMapper.ensureInitialized()
        .stringifyValue(this as PubUpgradeOptions);
  }

  @override
  bool operator ==(Object other) {
    return PubUpgradeOptionsMapper.ensureInitialized()
        .equalsValue(this as PubUpgradeOptions, other);
  }

  @override
  int get hashCode {
    return PubUpgradeOptionsMapper.ensureInitialized()
        .hashValue(this as PubUpgradeOptions);
  }
}

extension PubUpgradeOptionsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PubUpgradeOptions, $Out> {
  PubUpgradeOptionsCopyWith<$R, PubUpgradeOptions, $Out>
      get $asPubUpgradeOptions => $base
          .as((v, t, t2) => _PubUpgradeOptionsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PubUpgradeOptionsCopyWith<$R, $In extends PubUpgradeOptions,
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
      bool? precompile,
      bool? tighten,
      bool? unlockTransitive,
      bool? majorVersions});
  PubUpgradeOptionsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _PubUpgradeOptionsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PubUpgradeOptions, $Out>
    implements PubUpgradeOptionsCopyWith<$R, PubUpgradeOptions, $Out> {
  _PubUpgradeOptionsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PubUpgradeOptions> $mapper =
      PubUpgradeOptionsMapper.ensureInitialized();
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
          bool? precompile,
          bool? tighten,
          bool? unlockTransitive,
          bool? majorVersions}) =>
      $apply(FieldCopyWithData({
        if (debug != null) #debug: debug,
        if (directory != $none) #directory: directory,
        if (cacheDir != null) #cacheDir: cacheDir,
        if (patchDir != null) #patchDir: patchDir,
        if (verbose != null) #verbose: verbose,
        if (color != $none) #color: color,
        if (offline != null) #offline: offline,
        if (dryRun != null) #dryRun: dryRun,
        if (precompile != null) #precompile: precompile,
        if (tighten != null) #tighten: tighten,
        if (unlockTransitive != null) #unlockTransitive: unlockTransitive,
        if (majorVersions != null) #majorVersions: majorVersions
      }));
  @override
  PubUpgradeOptions $make(CopyWithData data) => PubUpgradeOptions(
      debug: data.get(#debug, or: $value.debug),
      directory: data.get(#directory, or: $value.directory),
      cacheDir: data.get(#cacheDir, or: $value.cacheDir),
      patchDir: data.get(#patchDir, or: $value.patchDir),
      verbose: data.get(#verbose, or: $value.verbose),
      color: data.get(#color, or: $value.color),
      offline: data.get(#offline, or: $value.offline),
      dryRun: data.get(#dryRun, or: $value.dryRun),
      precompile: data.get(#precompile, or: $value.precompile),
      tighten: data.get(#tighten, or: $value.tighten),
      unlockTransitive:
          data.get(#unlockTransitive, or: $value.unlockTransitive),
      majorVersions: data.get(#majorVersions, or: $value.majorVersions));

  @override
  PubUpgradeOptionsCopyWith<$R2, PubUpgradeOptions, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _PubUpgradeOptionsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
