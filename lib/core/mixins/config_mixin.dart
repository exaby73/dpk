import 'package:args/command_runner.dart';
import 'package:dpk/config/data/config_data.dart';
import 'package:dpk/core/injection_container.dart';

base mixin ConfigMixin on Command {
  ConfigData get config => container();
}
