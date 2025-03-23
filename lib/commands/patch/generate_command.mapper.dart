// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'generate_command.dart';

class GenerateOptionsMapper extends ClassMapperBase<GenerateOptions> {
  GenerateOptionsMapper._();

  static GenerateOptionsMapper? _instance;
  static GenerateOptionsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GenerateOptionsMapper._());
      GlobalOptionsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'GenerateOptions';

  static bool _$debug(GenerateOptions v) => v.debug;
  static const Field<GenerateOptions, bool> _f$debug = Field('debug', _$debug);
  static String? _$directory(GenerateOptions v) => v.directory;
  static const Field<GenerateOptions, String> _f$directory =
      Field('directory', _$directory);
  static String _$cacheDir(GenerateOptions v) => v.cacheDir;
  static const Field<GenerateOptions, String> _f$cacheDir =
      Field('cacheDir', _$cacheDir);
  static String _$patchDir(GenerateOptions v) => v.patchDir;
  static const Field<GenerateOptions, String> _f$patchDir =
      Field('patchDir', _$patchDir);
  static bool _$force(GenerateOptions v) => v.force;
  static const Field<GenerateOptions, bool> _f$force = Field('force', _$force);

  @override
  final MappableFields<GenerateOptions> fields = const {
    #debug: _f$debug,
    #directory: _f$directory,
    #cacheDir: _f$cacheDir,
    #patchDir: _f$patchDir,
    #force: _f$force,
  };

  static GenerateOptions _instantiate(DecodingData data) {
    return GenerateOptions(
        debug: data.dec(_f$debug),
        directory: data.dec(_f$directory),
        cacheDir: data.dec(_f$cacheDir),
        patchDir: data.dec(_f$patchDir),
        force: data.dec(_f$force));
  }

  @override
  final Function instantiate = _instantiate;

  static GenerateOptions fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GenerateOptions>(map);
  }

  static GenerateOptions fromJson(String json) {
    return ensureInitialized().decodeJson<GenerateOptions>(json);
  }
}

mixin GenerateOptionsMappable {
  String toJson() {
    return GenerateOptionsMapper.ensureInitialized()
        .encodeJson<GenerateOptions>(this as GenerateOptions);
  }

  Map<String, dynamic> toMap() {
    return GenerateOptionsMapper.ensureInitialized()
        .encodeMap<GenerateOptions>(this as GenerateOptions);
  }

  GenerateOptionsCopyWith<GenerateOptions, GenerateOptions, GenerateOptions>
      get copyWith =>
          _GenerateOptionsCopyWithImpl<GenerateOptions, GenerateOptions>(
              this as GenerateOptions, $identity, $identity);
  @override
  String toString() {
    return GenerateOptionsMapper.ensureInitialized()
        .stringifyValue(this as GenerateOptions);
  }

  @override
  bool operator ==(Object other) {
    return GenerateOptionsMapper.ensureInitialized()
        .equalsValue(this as GenerateOptions, other);
  }

  @override
  int get hashCode {
    return GenerateOptionsMapper.ensureInitialized()
        .hashValue(this as GenerateOptions);
  }
}

extension GenerateOptionsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, GenerateOptions, $Out> {
  GenerateOptionsCopyWith<$R, GenerateOptions, $Out> get $asGenerateOptions =>
      $base.as((v, t, t2) => _GenerateOptionsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class GenerateOptionsCopyWith<$R, $In extends GenerateOptions, $Out>
    implements GlobalOptionsCopyWith<$R, $In, $Out> {
  @override
  $R call(
      {bool? debug,
      String? directory,
      String? cacheDir,
      String? patchDir,
      bool? force});
  GenerateOptionsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _GenerateOptionsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, GenerateOptions, $Out>
    implements GenerateOptionsCopyWith<$R, GenerateOptions, $Out> {
  _GenerateOptionsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GenerateOptions> $mapper =
      GenerateOptionsMapper.ensureInitialized();
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
  GenerateOptions $make(CopyWithData data) => GenerateOptions(
      debug: data.get(#debug, or: $value.debug),
      directory: data.get(#directory, or: $value.directory),
      cacheDir: data.get(#cacheDir, or: $value.cacheDir),
      patchDir: data.get(#patchDir, or: $value.patchDir),
      force: data.get(#force, or: $value.force));

  @override
  GenerateOptionsCopyWith<$R2, GenerateOptions, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _GenerateOptionsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
