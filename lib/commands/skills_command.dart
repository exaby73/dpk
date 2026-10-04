import 'package:dpk/commands/dpk_command.dart';
import 'package:dpk/constants/embedded_dpk_skill.dart';

final class SkillsCommand extends DpkCommand {
  SkillsCommand(super.context);

  @override
  String get name => 'skills';

  @override
  String get description => 'Print the dpk usage guide for AI agents.';

  @override
  String get category => CommandCategory.setup;

  @override
  Future<int> run() async {
    console.info(embeddedDpkSkill.trimRight());
    return 0;
  }
}
