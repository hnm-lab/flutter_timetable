import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:intl/intl.dart';

/// A non-DateTime header value, representing e.g. a festival stage.
class _Stage {
  final String name;
  const _Stage(this.name);

  @override
  bool operator ==(Object other) => other is _Stage && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

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
    expect(event.headers, isNotNull);
    expect(event.headers, controller.headers);
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
    final cell = TimetableCell.fromDateTime(date);
    controller.addListener((e) => event = e);
    controller.jumpTo(cell);
    expect(event, isA<TimetableJumpToRequested>());
    expect(event.cell, isNotNull);
    expect(event.cell, cell);
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

  test("TimetableController supports non-DateTime header types", () {
    final stages = [const _Stage('Main Stage'), const _Stage('Second Stage')];
    final headers = stages.map((s) => TimetableHeader(s)).toList();
    final controller = TimetableController<_Stage>(
      headerConfig: TimetableHeaderConfig<_Stage>(
        headers,
        (header) => header.value.name,
      ),
    );
    expect(controller.headers, headers);
    expect(controller.visibleTimetableHeader.value, stages.first);
    expect(controller.headerNameFormatter(headers[1]), 'Second Stage');
  });

  test("TimetableController.startHour and endHour default to 0 and 23", () {
    final controller = TimetableController(
        headerConfig: TimetableHeaderConfig.defaultDateTimeHeader);
    expect(controller.startHour, 0);
    expect(controller.endHour, 23);
    expect(controller.duration, const Duration(hours: 24));
  });

  test("TimetableController.startHour and endHour narrow the visible duration",
      () {
    final controller = TimetableController(
      headerConfig: TimetableHeaderConfig.defaultDateTimeHeader,
      startHour: 9,
      endHour: 18,
    );
    expect(controller.startHour, 9);
    expect(controller.endHour, 18);
    expect(controller.duration, const Duration(hours: 10));
  });

  test("TimetableController.dateOfTable stores the given date", () {
    final date = DateTime(2024, 8, 1);
    final controller = TimetableController(
      headerConfig: TimetableHeaderConfig.defaultDateTimeHeader,
      dateOfTable: date,
    );
    expect(controller.dateOfTable, date);
  });
}
