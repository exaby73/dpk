import 'package:freezed_annotation/freezed_annotation.dart';

part 'dpk_workspace_environment.freezed.dart';

@freezed
abstract class DpkWorkspaceEnvironment with _$DpkWorkspaceEnvironment {
  const factory DpkWorkspaceEnvironment({
    required String dpkPackagePath,
    required String dpkPackageName,
    String? dpkPackageVersion,
  }) = _DpkWorkspaceEnvironment;

  const DpkWorkspaceEnvironment._();

  static final _packagePathRegex = RegExp(
    r'DPK_PACKAGE_PATH|\$DPK_PACKAGE_PATH',
  );
  static final _packageNameRegex = RegExp(
    r'DPK_PACKAGE_NAME|\$DPK_PACKAGE_NAME',
  );
  static final _packageVersionRegex = RegExp(
    r'DPK_PACKAGE_VERSION|\$DPK_PACKAGE_VERSION',
  );

  String replace(String content) {
    var result = content.replaceAll(_packagePathRegex, dpkPackagePath);
    result = result.replaceAll(_packageNameRegex, dpkPackageName);
    if (dpkPackageVersion != null) {
      result = result.replaceAll(_packageVersionRegex, dpkPackageVersion!);
    }
    return result;
  }
}
