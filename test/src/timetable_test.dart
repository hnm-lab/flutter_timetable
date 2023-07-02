import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:intl/intl.dart';

void main() {
  testWidgets("Timetable", (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable(
          key: const Key("TEST"),
          controller: TimetableController(
              headerConfig: TimetableHeaderConfig.defaultDateTimeHeader),
        ),
      ),
    );
    expect(find.byType(Timetable), findsOneWidget);
    expect(find.byKey(const Key("TEST")), findsOneWidget);
  });
  testWidgets("Timetable sorts items", (WidgetTester tester) async {
    final items = [
      TimetableItem.dateTime(
        start: DateTime(2020, 1, 1, 10, 0),
        end: DateTime(2020, 1, 1, 10, 1),
      ),
      TimetableItem.dateTime(
        start: DateTime(2020, 1, 1, 9, 0),
        end: DateTime(2020, 1, 1, 9, 1),
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable(
          items: items,
          controller: TimetableController(
              headerConfig: TimetableHeaderConfig.defaultDateTimeHeader),
        ),
      ),
    );
    expect(items.first.start.hour, 9);
    expect(items.last.start.hour, 10);
  });

  testWidgets("Timetable with custom header cell", (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable(
          headerCellBuilder: (header) => Text(header.toString()),
          controller: TimetableController(
              headerConfig: TimetableHeaderConfig.defaultDateTimeHeader),
        ),
      ),
    );
    final today = DateUtils.dateOnly(DateTime.now());
    expect(find.text(today.toString()), findsOneWidget);
  });

  testWidgets("Timetable with custom cell", (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable(
          cellBuilder: (cell) => Text(cell.toString()),
          controller: TimetableController(
              headerConfig: TimetableHeaderConfig.defaultDateTimeHeader),
        ),
      ),
    );
    final today = DateUtils.dateOnly(DateTime.now());
    expect(find.text(today.toString()), findsOneWidget);
  });

  testWidgets("Timetable with custom hour label", (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable(
          hourLabelBuilder: (hour) => Text(hour.toString()),
          controller: TimetableController(
              headerConfig: TimetableHeaderConfig.defaultDateTimeHeader),
        ),
      ),
    );
    expect(find.text(const TimeOfDay(hour: 12, minute: 0).toString()),
        findsOneWidget);
  });

  testWidgets("Timetable with custom day label", (WidgetTester tester) async {
    final items = [
      TimetableItem.dateTime(
        start: DateTime(2020, 1, 1, 10, 0),
        end: DateTime(2020, 1, 1, 11, 0),
        data: "test",
      ),
      TimetableItem.dateTime(
        start: DateTime(2020, 1, 1, 9, 0),
        end: DateTime(2020, 1, 1, 10, 0),
        data: "test 2",
      ),
    ];
    final controller = TimetableController<DateTime>(
      headerConfig: TimetableHeaderConfig.dateTimeHeader(
          start: DateTime(2020, 1, 1, 10, 0), format: DateFormat.H()),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable<String, DateTime>(
          items: items,
          itemBuilder: (item) => Text(item.data ?? ""),
          controller: controller,
        ),
      ),
    );
    expect(find.text("test", skipOffstage: false), findsOneWidget);
    expect(find.text("test 2", skipOffstage: false), findsOneWidget);
  });

  testWidgets("Timetable with custom day label", (WidgetTester tester) async {
    final item = TimetableItem.dateTime(
      start: DateTime(2020, 1, 1, 10, 0),
      end: DateTime(2020, 1, 1, 11, 0),
      data: "test",
    );

    final controller = TimetableController<DateTime>(
      headerConfig: TimetableHeaderConfig.dateTimeHeader(
          start: DateTime(2020, 1, 1, 10, 0), format: DateFormat.H()),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable<String, DateTime>(
          items: [item],
          controller: controller,
        ),
      ),
    );
    const label = "10:00 am - 11:00 am";
    expect(find.text(label, skipOffstage: false), findsOneWidget);
  });

  testWidgets("Timetable custom corner", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable(
          cornerBuilder: (_) => const Text("TEST"),
          controller: TimetableController(
            headerConfig: TimetableHeaderConfig.defaultDateTimeHeader,
          ),
        ),
      ),
    );
    expect(find.text("TEST"), findsOneWidget);
  });

  testWidgets("controller jump to", (tester) async {
    final controller = TimetableController(
      headerConfig: TimetableHeaderConfig.dateTimeHeader(
          start: DateTime(2020, 1, 1, 10, 0), format: DateFormat.H()),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable(
          controller: controller,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(controller.visibleTimetableHeader.value, DateTime(2020, 1, 1));
    controller.jumpTo(TimetableCell.fromDateTime(DateTime(2020, 1, 15, 11)));
    await tester.pumpAndSettle();
    expect(controller.visibleTimetableHeader.value, DateTime(2020, 1, 15));
  });

  testWidgets("controller columns changed", (tester) async {
    final controller = TimetableController(
      headerConfig: TimetableHeaderConfig.dateTimeHeader(
          start: DateTime(2020, 1, 1, 10, 0), format: DateFormat.H()),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable(
          controller: controller,
          headerCellBuilder: (_) => const Text("TEST"),
        ),
      ),
    );
    await tester.pumpAndSettle();
    controller.setColumns(2);
    await tester.pumpAndSettle();
    expect(find.text("TEST"), findsNWidgets(2));
  });

  testWidgets("controller columns changed", (tester) async {
    final controller = TimetableController(
      headerConfig: TimetableHeaderConfig.dateTimeHeader(
          start: DateTime(2020, 1, 1), format: DateFormat.H()),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable(
          controller: controller,
          headerCellBuilder: (date) => Text(date.toString()),
        ),
      ),
    );

    // drag to the left
    await tester.drag(
        find.text(DateTime(2020, 1, 1).toString()), const Offset(-200, -200));
    await tester.pumpAndSettle();
    expect(find.text(DateTime(2020, 1, 4).toString()), findsOneWidget);
  });
}
