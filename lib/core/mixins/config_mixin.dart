import 'package:args/command_runner.dart';
import 'package:dpm/config/data/config_data.dart';
import 'package:dpm/core/injection_container.dart';

base mixin ConfigMixin on Command {
  ConfigData get config => container();
}
