import 'package:args/command_runner.dart';
import 'package:dpk/core/console.dart';
import 'package:dpk/core/context.dart';

/// Help categories, so dpk's own commands are listed apart from the pub
/// commands it forwards.
abstract final class CommandCategory {
  static const workspace = 'Scripts and workspaces';
  static const dependencies = 'Dependencies';
  static const patching = 'Patching';
  static const release = 'Releasing';
  static const pub = 'Other pub commands';
  static const setup = 'Setup';
}

/// A dpk command. Commands get the [DpkContext] in their constructor instead
/// of reaching for global state.
abstract base class DpkCommand extends Command<int> {
  DpkCommand(this.context);

  final DpkContext context;

  Console get console => context.console;
}
