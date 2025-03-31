import 'dart:io';

import 'package:dpk/config/data/dpk_config.dart';
import 'package:dpk/core/mixins/config_mixin.dart';

base mixin CacheMixin on ConfigMixin {
  bool get isProjectCache => config.dpkConfig.mode == DpkMode.project;

  Map<String, String> getCacheEnv(String cacheDir) {
    return {
      if (isProjectCache) 'PUB_CACHE': cacheDir,
      if (Platform.environment.containsKey('PUB_CACHE'))
        'PUB_CACHE': Platform.environment['PUB_CACHE']!,
    };
  }
}
