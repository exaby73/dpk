import 'dart:io';

import 'package:dpm/config/data/dpm_config.dart';
import 'package:dpm/core/mixins/config_mixin.dart';

base mixin CacheMixin on ConfigMixin {
  bool get isProjectCache => config.dpmConfig.mode == DpmMode.project;

  Map<String, String> getCacheEnv(String cacheDir) {
    return {
      if (isProjectCache) 'PUB_CACHE': cacheDir,
      if (Platform.environment.containsKey('PUB_CACHE'))
        'PUB_CACHE': Platform.environment['PUB_CACHE']!,
    };
  }
}
