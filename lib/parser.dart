import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'model.dart';

class Parser {
  Map<int, TestModel> tests = {};
  bool success = true;

  Future<void> parseFile(String path) async {
    final lines = await File(path)
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .toList();
    // 1st pass
    lines.forEach(_parseLine);
    // 2d pass
    lines.forEach(_completeLine);
  }

  void _parseLine(String jsonString) {
    Map<String, dynamic> line;
    try {
      line = jsonDecode(jsonString);
    } catch (e) {
      return;
    }

    if (line.containsKey('type')) {
      _parseTestStart(line);
      _parseTestError(line);
      _parseTestMessage(line);
    }
  }

  void _completeLine(String jsonString) {
    Map<String, dynamic> line;
    try {
      line = jsonDecode(jsonString);
    } catch (e) {
      return;
    }

    if (line.containsKey('type')) {
      _parseTestDone(line);
      _parseResult(line);
    }
  }

  void _parseTestStart(Map<String, dynamic> line) {
    if (line['type'] == 'testStart') {
      int id = line['test']['id'];
      String name = line['test']['name'];

      final model = tests.putIfAbsent(id, () => TestModel());
      model.id = id;
      model.name = name;
    }
  }

  void _parseTestError(Map<String, dynamic> line) {
    if (line['type'] == 'error') {
      int id = line['testID'];
      String error = line['error'];
      final model = tests.putIfAbsent(id, () => TestModel());

      if (model != null) {
        model.error = error.endsWith('\n') ? '\t$error' : '\t$error\n';
      }
    }
  }

  void _parseTestMessage(Map<String, dynamic> line) {
    if (line['type'] == 'print') {
      int id = line['testID'];
      String message = line['message'];

      final model = tests[id];
      if (model != null && message != null) {
        model.message = '\t$message\n';
      }
    }
  }

  void _parseTestDone(Map<String, dynamic> line) {
    if (line['type'] == 'testDone') {
      int id = line['testID'];
      final model = tests[id];
      if (model == null) return;
      switch (line['result']) {
        case 'success':
          model.state = State.Success;
          break;
        case 'failure':
          model.state = State.Failure;
          break;
        default:
          model.state = State.Error;
          break;
      }
      if (line['skipped'] == true) {
        model.state = State.Skipped;
      }
      // test may failed after it had already completed
      if (model.error != null && model.state == State.Success) {
        model.state = State.Error;
      }
    }
  }

  void _parseResult(Map<String, dynamic> line) {
    if (line['type'] == 'done') {
      success = line['success'] == true;
    }
  }
}
