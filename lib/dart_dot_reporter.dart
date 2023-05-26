import 'dart:io';

import 'dot_reporter.dart';
import 'parser.dart';

void run({
  required String path,
  bool FAIL_SKIPPED = true,
  bool SHOW_SUCCESS = true,
  bool HIDE_SKIPPED = true,
  bool SHOW_ID = true,
  bool SHOW_MESSAGE = true,
  bool NO_COLOR = true,
}) async {
  final parser = Parser();

  await parser.parseFile(path);

  DotReporter(
    parser: parser,
    showSuccess: SHOW_SUCCESS,
    hideSkipped: HIDE_SKIPPED,
    failSkipped: FAIL_SKIPPED,
    showId: SHOW_ID,
    showMessage: SHOW_MESSAGE,
    noColor: NO_COLOR,
    out: stdout,
  ).printReport();
}
