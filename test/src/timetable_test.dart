import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:intl/intl.dart';

void main() {
  testWidgets("Timetable", (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable<dynamic, DateTime>(
          key: const Key("TEST"),
          controller: TimetableController(
              headerConfig: TimetableHeaderConfig.defaultDateTimeHeader),
        ),
      ),
    );
    expect(find.byType(Timetable<dynamic, DateTime>), findsOneWidget);
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
        home: Timetable<dynamic, DateTime>(
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
        home: Timetable<dynamic, DateTime>(
          headerCellBuilder: (header) => Text(header.value.day.toString()),
          controller: TimetableController(
              headerConfig: TimetableHeaderConfig.defaultDateTimeHeader),
        ),
      ),
    );
    final today = DateUtils.dateOnly(DateTime.now());
    expect(find.text(today.day.toString()), findsOneWidget);
  });

  testWidgets("Timetable with custom cell", (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable<dynamic, DateTime>(
          cellBuilder: (cell) => Text('${cell.header.value.day}-${cell.hour}'),
          controller: TimetableController(
              headerConfig: TimetableHeaderConfig.defaultDateTimeHeader),
        ),
      ),
    );
    final today = DateUtils.dateOnly(DateTime.now());
    expect(find.text('${today.day}-${today.hour}'), findsOneWidget);
  });

  testWidgets("Timetable with custom hour label", (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable<dynamic, DateTime>(
          hourLabelBuilder: (hour) => Text(hour.toString()),
          controller: TimetableController(
              headerConfig: TimetableHeaderConfig.defaultDateTimeHeader),
        ),
      ),
    );
    expect(find.text(const TimeOfLongDay(hour: 12, minute: 0).hour.toString()),
        findsOneWidget);
  });

  testWidgets("Timetable with custom day label", (WidgetTester tester) async {
    final items = [
      TimetableItem.dateTime(
        start: DateTime(2020, 1, 1, 3, 0),
        end: DateTime(2020, 1, 1, 4, 0),
        data: "test",
      ),
      TimetableItem.dateTime(
        start: DateTime(2020, 1, 1, 1, 0),
        end: DateTime(2020, 1, 1, 2, 0),
        data: "test 2",
      ),
    ];
    final controller = TimetableController<DateTime>(
      headerConfig: TimetableHeaderConfig.dateTimeHeader(
          start: DateTime(2020, 1, 1), format: DateFormat.H()),
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
        home: Timetable<dynamic, DateTime>(
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
        home: Timetable<dynamic, DateTime>(
          controller: controller,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(controller.visibleTimetableHeader.value, DateTime(2020, 1, 1));
    controller.jumpTo(TimetableCell.fromDateTime(DateTime(2020, 1, 6, 11)));
    await tester.pumpAndSettle();
    expect(controller.visibleTimetableHeader.value, DateTime(2020, 1, 6));
  });

  testWidgets("controller columns changed", (tester) async {
    final controller = TimetableController(
      headerConfig: TimetableHeaderConfig.dateTimeHeader(
          start: DateTime(2020, 1, 1, 10, 0), format: DateFormat.H()),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable<dynamic, DateTime>(
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

  testWidgets("Swipe columns", (tester) async {
    final controller = TimetableController(
      headerConfig: TimetableHeaderConfig.dateTimeHeader(
          start: DateTime(2020, 1, 1), format: DateFormat.H()),
    );
    final format = DateFormat('MMM=d').format;
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable<dynamic, DateTime>(
          controller: controller,
          headerCellBuilder: (header) => Text(format(header.value)),
        ),
      ),
    );

    // drag to the left
    await tester.drag(
        find.text(format(DateTime(2020, 1, 1))), const Offset(-400, -200));
    await tester.pumpAndSettle();
    expect(find.text(format(DateTime(2020, 1, 1))), findsOneWidget);
    // TODO(tkc): スクロールがうまくできてないのか、skipOffstageならpassする
    expect(find.text(format(DateTime(2020, 1, 4))), findsOneWidget);
  });
}
