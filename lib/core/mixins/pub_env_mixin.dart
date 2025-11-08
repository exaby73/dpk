import 'dart:io';

import 'package:dpk/config/data/dpk_config.dart';
import 'package:dpk/core/mixins/config_mixin.dart';
import 'package:path/path.dart' as path;

base mixin PubEnvMixin on ConfigMixin {
  bool get isProjectMode => config.dpkConfig.mode == DpkMode.project;

  String resolveCacheDir(String cacheDir) {
    if (cacheDir.startsWith('/')) {
      return cacheDir;
    }

    return path.join(config.workingDirectory, cacheDir);
  }

  Map<String, String> getCacheEnv(String cacheDir) {
    final resolvedCacheDir = resolveCacheDir(cacheDir);
    return {
      if (Platform.environment.containsKey('PUB_CACHE'))
        'PUB_CACHE': Platform.environment['PUB_CACHE']!,
      if (Platform.environment.containsKey('PUB_HOSTED_URL'))
        'PUB_HOSTED_URL': Platform.environment['PUB_HOSTED_URL']!,
      if (isProjectMode) 'PUB_CACHE': resolvedCacheDir,
    };
  }
}
