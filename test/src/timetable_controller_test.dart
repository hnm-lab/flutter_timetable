import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:intl/intl.dart';

void main() {
  test("TimetableController", () {
    final controller = TimetableController(
        headerConfig: TimetableHeaderConfig.defaultDateTimeHeader);
    expect(controller, isNotNull);
  });

  test("TimetableController.start", () {
    dynamic event;
    final controller = TimetableController(
        headerConfig: TimetableHeaderConfig.defaultDateTimeHeader);
    controller.addListener((e) => event = e);
    controller.cellHeaders = [TimetableHeader(DateTime.now())];
    expect(controller.headers, isNotNull);
    expect(event, isA<TimetableCellHeadersChanged>());
    expect(event.start, isNotNull);
    expect(event.start, controller.headers);
  });

  test("TimetableController.columns", () {
    dynamic event;
    final controller = TimetableController(
        headerConfig: TimetableHeaderConfig.defaultDateTimeHeader);
    controller.addListener((e) => event = e);
    controller.setColumns(7);
    expect(controller.columns, isNotNull);
    expect(controller.columns, 7);
    expect(event, isA<TimetableColumnsChanged>());
    expect(event.columns, isNotNull);
    expect(event.columns, controller.columns);
  });

  test("TimetableController.cellHeight", () {
    dynamic event;
    final controller = TimetableController(
        headerConfig: TimetableHeaderConfig.defaultDateTimeHeader);
    controller.addListener((e) => event = e);
    controller.setCellHeight(55);
    expect(controller.cellHeight, isNotNull);
    expect(controller.cellHeight, 55);
    expect(event, isA<TimetableCellHeightChanged>());
    expect(event.height, isNotNull);
    expect(event.height, controller.cellHeight);
  });

  test("TimetableController.jumpTo", () {
    dynamic event;
    final date = DateTime(2020, 1, 1);
    final controller = TimetableController(
        headerConfig: TimetableHeaderConfig.dateTimeHeader(
            start: date, format: DateFormat.H()));
    controller.addListener((e) => event = e);
    controller.jumpTo(TimetableCell.fromDateTime(date));
    expect(event, isA<TimetableJumpToRequested>());
    expect(event.date, isNotNull);
    expect(event.date, date);
  });

  test("TimetableController.updateVisibleDate", () {
    final date = TimetableHeader(DateTime(2020, 1, 1));
    dynamic event;
    final controller = TimetableController(
        headerConfig: TimetableHeaderConfig.defaultDateTimeHeader,
        onEvent: (e) => event = e);
    controller.updateVisibleHeader(date);
    expect(controller.visibleTimetableHeader, date);
    expect(event, isA<TimetableVisibleHeaderChanged>());
  });

  test("TimetableController.dispatch", () {
    final controller = TimetableController(
        headerConfig: TimetableHeaderConfig.defaultDateTimeHeader);
    dynamic event;
    controller.addListener((e) => event = e);
    controller.dispatch(TimetableJumpToRequested(
        TimetableCell.fromDateTime(DateTime(2020, 1, 1))));
    expect(event, isA<TimetableJumpToRequested>());
  });

  test("onEvent adds listen", () {
    dynamic event;
    final controller = TimetableController(
        headerConfig: TimetableHeaderConfig.defaultDateTimeHeader,
        onEvent: (e) => event = e);
    expect(controller.hasListeners, isTrue);
    controller.dispatch(TimetableJumpToRequested(
        TimetableCell.fromDateTime(DateTime(2020, 1, 1))));
    expect(event, isA<TimetableJumpToRequested>());
  });

  test("TimetableController.removeListener", () {
    final controller = TimetableController(
        headerConfig: TimetableHeaderConfig.defaultDateTimeHeader);
    final id = controller.addListener((e) {});
    expect(controller.hasListeners, isTrue);
    controller.removeListener(id);
    expect(controller.hasListeners, isFalse);
  });

  test("TimetableController.clearListeners", () {
    final controller = TimetableController(
        headerConfig: TimetableHeaderConfig.defaultDateTimeHeader);
    controller.addListener((e) {});
    expect(controller.hasListeners, isTrue);
    controller.clearListeners();
    expect(controller.hasListeners, isFalse);
  });

  test("TimetableController.addListener null", () {
    final controller = TimetableController(
        headerConfig: TimetableHeaderConfig.defaultDateTimeHeader);
    controller.addListener(null);
    expect(controller.hasListeners, isFalse);
  });
}
