import 'package:flutter/material.dart';
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
    expect(find.text(format(DateTime(2020, 1, 4)), skipOffstage: false),
        findsOneWidget);
  });

  testWidgets("Timetable with custom header type renders and supports jumpTo",
      (tester) async {
    final stages = List.generate(10, (i) => _Stage('Stage $i'));
    final headers = stages.map((s) => TimetableHeader(s)).toList();
    final controller = TimetableController<_Stage>(
      headerConfig: TimetableHeaderConfig<_Stage>(
        headers,
        (h) => h.value.name,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable<dynamic, _Stage>(controller: controller),
      ),
    );
    expect(find.text('Stage 0'), findsOneWidget);

    controller.jumpTo(TimetableCell(10, headers[3]));
    await tester.pumpAndSettle();
    expect(controller.visibleTimetableHeader.value, stages[3]);
  });

  testWidgets("Timetable respects controller startHour and endHour",
      (tester) async {
    final controller = TimetableController(
      headerConfig: TimetableHeaderConfig.dateTimeHeader(
          start: DateTime(2020, 1, 1), format: DateFormat.H()),
      startHour: 9,
      endHour: 18,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable<dynamic, DateTime>(controller: controller),
      ),
    );
    expect(find.text('10:00', skipOffstage: false), findsOneWidget);
    expect(find.text('18:00', skipOffstage: false), findsOneWidget);
    expect(find.text('9:00', skipOffstage: false), findsNothing);
    expect(find.text('19:00', skipOffstage: false), findsNothing);
  });

  testWidgets("Now line appears for custom headers when dateOfTable is today",
      (tester) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final header = TimetableHeader(const _Stage('Main'));
    final controller = TimetableController<_Stage>(
      headerConfig:
          TimetableHeaderConfig<_Stage>([header], (h) => h.value.name),
      dateOfTable: today,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable<dynamic, _Stage>(controller: controller),
      ),
    );
    expect(
      find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString() == '_NowIndicator'),
      findsOneWidget,
    );
  });

  testWidgets(
      "Now line is hidden for custom headers when dateOfTable is not today",
      (tester) async {
    final header = TimetableHeader(const _Stage('Main'));
    final controller = TimetableController<_Stage>(
      headerConfig:
          TimetableHeaderConfig<_Stage>([header], (h) => h.value.name),
      dateOfTable: DateTime(2000, 1, 1),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Timetable<dynamic, _Stage>(controller: controller),
      ),
    );
    expect(
      find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString() == '_NowIndicator'),
      findsNothing,
    );
  });

  testWidgets(
      "controller swapped on rebuild is rewired instead of the stale one",
      (tester) async {
    final controllerA = TimetableController(
      headerConfig: TimetableHeaderConfig.dateTimeHeader(
          start: DateTime(2020, 1, 1, 10, 0), format: DateFormat.H()),
    );
    final controllerB = TimetableController(
      headerConfig: TimetableHeaderConfig.dateTimeHeader(
          start: DateTime(2020, 1, 1, 10, 0), format: DateFormat.H()),
    );
    late StateSetter setState;
    var activeController = controllerA;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setter) {
            setState = setter;
            return Timetable<dynamic, DateTime>(
              controller: activeController,
              headerCellBuilder: (_) => const Text("TEST"),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(controllerA.hasListeners, isTrue);

    // Simulate a parent rebuilding with a different controller instance.
    setState(() => activeController = controllerB);
    await tester.pump();

    expect(controllerA.hasListeners, isFalse);
    expect(controllerB.hasListeners, isTrue);

    // The newly active controller must actually drive the timetable.
    controllerB.setColumns(2);
    await tester.pumpAndSettle();
    expect(find.text("TEST"), findsNWidgets(2));
  });
}
