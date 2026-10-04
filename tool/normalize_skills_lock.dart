import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Rewrites absolute local skill sources in `skills-lock.json` to paths
/// relative to the current directory, so the lock file is portable.
void main() {
  final lockFile = File('skills-lock.json');
  if (!lockFile.existsSync()) {
    return;
  }

  final lock = jsonDecode(lockFile.readAsStringSync()) as Map<String, dynamic>;
  final skills = lock['skills'] as Map<String, dynamic>? ?? {};
  var changed = false;

  for (final skill in skills.values.cast<Map<String, dynamic>>()) {
    final source = skill['source'];
    if (source is! String || !p.isAbsolute(source)) {
      continue;
    }

    final relative = p.split(p.relative(source));
    skill['source'] = p.posix.joinAll([
      if (relative.first != '..') '.',
      ...relative,
    ]);
    changed = true;
  }

  if (changed) {
    lockFile.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(lock)}\n',
    );
  }
}
