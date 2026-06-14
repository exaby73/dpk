import 'package:args/command_runner.dart';
import 'package:dpk/constants/embedded_dpk_skill.dart';

final class SkillsCommand extends Command<int> {
  @override
  String get name => 'skills';

  @override
  String get description => 'Print detailed dpk usage guidance for AI agents';

  @override
  Future<int> run() async {
    // ignore: avoid_print
    print(embeddedDpkSkill.trimRight());
    return 0;
  }
}
