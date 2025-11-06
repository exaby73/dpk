import 'dart:io';

mixin ProcessHandlerMixin {
  Future<int> runDartProcess({
    required List<String> arguments,
    String? workingDirectory,
    Map<String, String>? environment,
  }) async {
    final wd = workingDirectory != null
        ? Directory(workingDirectory).absolute.path
        : null;
    final process = await Process.start(
      'dart',
      arguments,
      workingDirectory: wd,
      runInShell: true,
      environment: environment,
    );

    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);

    final exitCode = await process.exitCode;

    return exitCode;
  }
}
