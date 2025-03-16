import 'dart:io';

Future<bool> gitExists() async {
  final exitCode = await Process.start('git', [
    '--version',
  ]).then((process) => process.exitCode);
  return exitCode == 0;
}
