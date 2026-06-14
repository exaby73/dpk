import 'package:dpk/commands/add_command.dart';
import 'package:test/test.dart';

void main() {
  group('Given the add command argument parser', () {
    test('When --dev is provided then it is forwarded to pub add options', () {
      final results = AddCommand().argParser.parse([
        '--dev',
        'test_descriptor',
      ]);
      final options = PubAddOptions.fromArgResults(results);

      expect(options.dev, isTrue);
      expect(results.rest, equals(['test_descriptor']));
    });
  });
}
