import 'dart:io';

mixin ProcessHandlerMixin {
  Future<int> runDartProcess({
    required List<String> arguments,
    String? workingDirectory,
    Map<String, String>? environment,
  }) async {
    final process = await Process.start(
      'dart',
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
    );

    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);

    final exitCode = await process.exitCode;

    return exitCode;
  }
}
