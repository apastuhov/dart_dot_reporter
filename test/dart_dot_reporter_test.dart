import 'dart:io';

import 'package:dart_dot_reporter/dot_reporter.dart';
import 'package:dart_dot_reporter/parser.dart';
import 'package:dart_dot_reporter/model.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  test('TestModel', () {
    final model = TestModel();
    expect(model.id, null);
    expect(model.name, null);
    expect(model.message, null);
    expect(model.state, null);
  });

  group('parser', () {
    test('can parse file with lines containing json', () async {
      final parser = Parser();

      await parser.parseFile('./test/machine_sample.log');

      expect(parser.tests.keys, [27, 28, 29, 30, 31]);
      expect(
          parser.tests[27],
          TestModel()
            ..id = 27
            ..state = State.Success
            ..name = 'API getAll');
      expect(
          parser.tests[28],
          TestModel()
            ..id = 28
            ..state = State.Skipped
            ..name = 'API delete');
      expect(
          parser.tests[29],
          TestModel()
            ..id = 29
            ..state = State.Failure
            ..message =
                "\tExpected: {\n            'id': 103\n          }\n  Actual: {\n            'ids': 102,\n          }\n   Which: is missing map key 'id'\n"
            ..name = 'API update');
      expect(
          parser.tests[30],
          TestModel()
            ..id = 30
            ..name = 'API create');
      expect(
          parser.tests[31],
          TestModel()
            ..id = 31
            ..state = State.Failure
            ..name = 'API too big print text');
    });
  });

  group('dot_reporter', () {
    DotReporter reporter;
    Parser parser;
    OutMock out;

    final loadingTest = TestModel()
      ..id = 0
      ..name = 'loading /User/home... any path to .dart file';

    final errorWithMessageTest = TestModel()
      ..id = 2
      ..name = 'error name'
      ..state = State.Failure
      ..message =
          "Expected: {\n            'id': 103\n          }\n  Actual: {\n            'ids': 102,\n          }\n   Which: is missing map key 'id'\n";

    final successTest = TestModel()
      ..id = 1
      ..name = 'success name'
      ..state = State.Success;

    final errorTest = TestModel()
      ..id = 2
      ..name = 'error name'
      ..state = State.Failure;

    final skippedTest = TestModel()
      ..id = 3
      ..name = 'skipped name'
      ..state = State.Skipped;

    setUp(() {
      exitCode = 0;
      parser = Parser();
      out = OutMock();
      reporter = DotReporter(
        noColor: true,
        out: out,
        parser: parser,
      );
    });

    test('Ignore "loading" tests', () {
      parser.tests[loadingTest.id] = loadingTest;
      reporter.printReport();
      expect(exitCode, 0);
      verify(out.write('')).called(2);
      verify(out.writeln()).called(5);
      verify(out.writeAll(
        [
          'Total: 0',
          'Success: 0',
          'Skipped: 0',
          'Failure: 0',
        ],
        '\n',
      )).called(1);
    });

    test('Single success test passed', () {
      parser.tests[successTest.id] = successTest;
      reporter.printReport();
      expect(exitCode, 0);
      verify(out.write('.')).called(1);
      verify(out.writeln()).called(5);
      verify(out.write('')).called(1);
      verify(out.writeAll(
        [
          'Total: 1',
          'Success: 1',
          'Skipped: 0',
          'Failure: 0',
        ],
        '\n',
      )).called(1);
    });

    test('Single error test passed', () {
      parser.tests[errorTest.id] = errorTest;
      reporter.printReport();
      expect(exitCode, 2);
      verify(out.write('X')).called(1);
      verify(out.writeln()).called(5);
      verify(out.write('X error name')).called(1);
      verify(out.writeAll(
        [
          'Total: 1',
          'Success: 0',
          'Skipped: 0',
          'Failure: 1',
        ],
        '\n',
      )).called(1);
    });

    test('Single error with message test passed', () {
      parser.tests[errorWithMessageTest.id] = errorWithMessageTest;
      reporter = DotReporter(
        noColor: true,
        showMessage: true,
        out: out,
        parser: parser,
      );
      reporter.printReport();
      expect(exitCode, 2);
      verify(out.write('X')).called(1);
      verify(out.writeln()).called(5);
      verify(out.write(
              "X error name\nExpected: {\n            'id': 103\n          }\n  Actual: {\n            'ids': 102,\n          }\n   Which: is missing map key 'id'\n"))
          .called(1);
      verify(out.writeAll(
        [
          'Total: 1',
          'Success: 0',
          'Skipped: 0',
          'Failure: 1',
        ],
        '\n',
      )).called(1);
    });

    test('Single skip test passed', () {
      parser.tests[skippedTest.id] = skippedTest;
      reporter.printReport();
      expect(exitCode, 0);
      verify(out.write('!')).called(1);
      verify(out.writeln()).called(5);
      verify(out.write('! skipped name')).called(1);
      verify(out.writeAll(
        [
          'Total: 1',
          'Success: 0',
          'Skipped: 1',
          'Failure: 0',
        ],
        '\n',
      )).called(1);
    });
    test('Single skip test failed if flag is passed', () {
      parser.tests[skippedTest.id] = skippedTest;
      reporter = DotReporter(
        noColor: true,
        out: out,
        parser: parser,
        failSkipped: true,
      );
      reporter.printReport();
      expect(exitCode, 1);
      verify(out.write('!')).called(1);
      verify(out.writeln()).called(5);
      verify(out.write('! skipped name')).called(1);
      verify(out.writeAll(
        [
          'Total: 1',
          'Success: 0',
          'Skipped: 1',
          'Failure: 0',
        ],
        '\n',
      )).called(1);
    });

    test('All tests passed', () {
      parser.tests[successTest.id] = successTest;
      parser.tests[errorTest.id] = errorTest;
      parser.tests[skippedTest.id] = skippedTest;

      reporter.printReport();
      expect(exitCode, 2);
      verify(out.write('.X!')).called(1);
      verify(out.writeln()).called(5);
      verify(out.write('X error name\n! skipped name')).called(1);
      verify(out.writeAll(
        [
          'Total: 3',
          'Success: 1',
          'Skipped: 1',
          'Failure: 1',
        ],
        '\n',
      )).called(1);
    });

    test('hide skipped', () {
      parser.tests[successTest.id] = successTest;
      parser.tests[errorTest.id] = errorTest;
      parser.tests[skippedTest.id] = skippedTest;
      reporter = DotReporter(
        noColor: true,
        out: out,
        parser: parser,
        hideSkipped: true,
      );

      reporter.printReport();
      expect(exitCode, 2);
      verify(out.write('.X!')).called(1);
      verify(out.writeln()).called(5);
      verify(out.write('X error name')).called(1);
      verify(out.writeAll(
        [
          'Total: 3',
          'Success: 1',
          'Skipped: 1',
          'Failure: 1',
        ],
        '\n',
      )).called(1);
    });
    test('show Id of the test', () {
      parser.tests[successTest.id] = successTest;
      parser.tests[errorTest.id] = errorTest;
      parser.tests[skippedTest.id] = skippedTest;
      reporter = DotReporter(
        noColor: true,
        out: out,
        parser: parser,
        showId: true,
      );

      reporter.printReport();
      expect(exitCode, 2);
      verify(out.write('.X!')).called(1);
      verify(out.writeln()).called(5);
      verify(out.write('2 X error name\n3 ! skipped name')).called(1);
      verify(out.writeAll(
        [
          'Total: 3',
          'Success: 1',
          'Skipped: 1',
          'Failure: 1',
        ],
        '\n',
      )).called(1);
    });
    test('show successfull tests in list', () {
      parser.tests[successTest.id] = successTest;
      parser.tests[errorTest.id] = errorTest;
      parser.tests[skippedTest.id] = skippedTest;
      reporter = DotReporter(
        noColor: true,
        out: out,
        parser: parser,
        showSuccess: true,
      );

      reporter.printReport();
      expect(exitCode, 2);
      verify(out.write('.X!')).called(1);
      verify(out.writeln()).called(5);
      verify(out.write('. success name\nX error name\n! skipped name'))
          .called(1);
      verify(out.writeAll(
        [
          'Total: 3',
          'Success: 1',
          'Skipped: 1',
          'Failure: 1',
        ],
        '\n',
      )).called(1);
    });
  });
}

class OutMock extends Mock implements Stdout {}
