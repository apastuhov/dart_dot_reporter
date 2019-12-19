import 'dart:io';

import 'dot_reporter.dart';
import 'parser.dart';

void run({
  String path,
  bool FAIL_SKIPPED,
  bool SHOW_SUCCESS,
  bool HIDE_SKIPPED,
  bool SHOW_ID,
  bool SHOW_MESSAGE,
  bool NO_COLOR,
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
