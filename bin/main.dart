import 'dart:io';

import 'package:dart_dot_reporter/dart_dot_reporter.dart' as dart_dot_reporter;

void main(List<String> arguments) {
  final usage = 'Usage: dart_dot_reporter <machine.log> [flags]';
  final help = 'Use -h flag to review documentation';

  if (arguments.isEmpty) {
    stderr.writeln('''
    No arguments were passed!
    $usage
    $help
    ''');
    exitCode = 2;
    return;
  }

  final path = arguments.first;

  if (!FileSystemEntity.isFileSync(path)) {
    stderr.writeln('''
    Cannot identify the file "$path".

    $usage
    $help
    ''');
    exitCode = 2;
    return;
  }

  if (arguments.contains('-h')) {
    // TODO: Add repo link
    stdout.writeln('''
    $usage

    Path to log file is required as first argument.

    Use one of next flags:

    -h               To get help. More info can be found on GitHub.

    --hide-skip      To hide output about skipped tests.

    --show-success   To show output about successfull tests.

    --show-id        To show id of the test from Machine log.

    --show-message   To show error message of the failed test.

    --no-color       To disable colors.
    ''');
    exitCode = 0;
    return;
  }

  dart_dot_reporter.run(
    path: path,
    HIDE_SKIPPED: arguments.contains('--hide-skip'),
    SHOW_SUCCESS: arguments.contains('--show-success'),
    SHOW_ID: arguments.contains('--show-id'),
    SHOW_MESSAGE: arguments.contains('--show-message'),
    NO_COLOR: arguments.contains('--no-color'),
  );
}
