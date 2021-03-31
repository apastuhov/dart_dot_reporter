import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'model.dart';

class Parser {
  Map<int, TestModel> tests = {};

  Future parseFile(String path) {
    return File(path)
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .forEach(_parseLine);
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
      _parseTestDone(line);
    }
  }

  void _parseTestStart(Map<String, dynamic> line) {
    if (line['type'] == 'testStart') {
      int id = line['test']['id'];
      String name = line['test']['name'];

      if (name.startsWith('loading /')) {
        return;
      }

      final model = tests.putIfAbsent(id, () => TestModel());
      model.id = id;
      model.name = name;
      if (line['test']['metadata']['skip']) {
        model.state = State.Skipped;
      }
    }
  }

  void _parseTestError(Map<String, dynamic> line) {
    if (line['type'] == 'error') {
      int id = line['testID'];
      String error = line['error'];

      final model = tests[id];
      if (model != null) {
        if (!error.startsWith('Test failed. See exception logs above.')) {
          model.error = error.endsWith('\n') ? '\t$error' : '\t$error\n';
        }
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
      if (model != null && model.state == null) {
        model.state =
            line['result'] == 'success' ? State.Success : State.Failure;
      }
    }
  }
}
