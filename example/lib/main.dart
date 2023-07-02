import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => MaterialApp(
        routes: {
          '/': (context) => const TimetableScreen(),
          '/custom': (context) => const CustomTimetableScreen(),
        },
      );
}

/// Plain old default time table screen.
class TimetableScreen extends StatelessWidget {
  const TimetableScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          actions: [
            TextButton(
              onPressed: () async => Navigator.pushNamed(context, '/custom'),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: const [
                  Icon(Icons.celebration_outlined, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Custom builders",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right_outlined, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
        body: Timetable(
          controller: TimetableController(
              headerConfig: TimetableHeaderConfig.defaultDateTimeHeader),
        ),
      );
}

/// Timetable screen with all the stuff - controller, builders, etc.
class CustomTimetableScreen extends StatefulWidget {
  const CustomTimetableScreen({Key? key}) : super(key: key);
  @override
  State<CustomTimetableScreen> createState() => _CustomTimetableScreenState();
}

class _CustomTimetableScreenState extends State<CustomTimetableScreen> {
  final items = generateItems();
  late final TimetableController<DateTime> controller;

  @override
  void initState() {
    super.initState();
    final nowDate = DateUtils.dateOnly(DateTime.now());
    final format = DateFormat('MMM\nd');
    final headers = List<TimetableHeader<DateTime>>.generate(14, (index) {
      final date = nowDate.add(Duration(days: index));
      return TimetableHeader<DateTime>(date);
    });
    controller = TimetableController(
      headerConfig:
          TimetableHeaderConfig(headers, (date) => format.format(date.value)),
      initialColumns: 3,
      cellHeight: 100.0,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.delayed(const Duration(milliseconds: 100), () {
        controller.jumpTo(_nowCell());
      });
    });
  }

  TimetableCell<DateTime> _nowCell() {
    final now = DateTime.now();
    final nowDate = DateUtils.dateOnly(now);
    final header =
        controller.headers.firstWhere((header) => header.value == nowDate);
    final nowCell = TimetableCell<DateTime>(now.hour, header);
    return nowCell;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          actions: [
            TextButton(
              onPressed: () async => Navigator.pop(context),
              child: Row(
                children: const [
                  Icon(Icons.chevron_left_outlined, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Default",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.calendar_view_day),
              onPressed: () => controller.setColumns(1),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_view_month_outlined),
              onPressed: () => controller.setColumns(3),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_view_week),
              onPressed: () => controller.setColumns(5),
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () =>
                  controller.setCellHeight(controller.cellHeight + 10),
            ),
            IconButton(
              icon: const Icon(Icons.zoom_out),
              onPressed: () =>
                  controller.setCellHeight(controller.cellHeight - 10),
            ),
          ],
        ),
        body: Timetable<String, DateTime>(
          controller: controller,
          items: items,
          cellBuilder: (cell) => Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey, width: 0.2),
            ),
            child: Center(
              child: Text(
                '${DateFormat("MM/d/yyyy").format(cell.header.value)}\n${cell.timeOfDay.hourOfPeriod}${cell.timeOfDay.period.name}',
                style: TextStyle(
                  color: Color(0xff000000 +
                          (0x002222 * cell.hour) +
                          (0x110000 * cell.header.value.day))
                      .withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          cornerBuilder: (currentHeader) {
            final datetime = currentHeader.value;
            return Container(
              color: Colors.accents[datetime.day % Colors.accents.length],
              child: Center(child: Text("${datetime.year}")),
            );
          },
          headerCellBuilder: (header) {
            final datetime = header.value;
            final color =
                Colors.primaries[datetime.day % Colors.accents.length];
            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: color, width: 2)),
              ),
              child: Center(
                child: Text(
                  DateFormat("E\nMMM d").format(datetime),
                  style: TextStyle(
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
          hourLabelBuilder: (hour) {
            final hourPeriod = hour == 12 ? 12 : hour % 12;
            final period = hour < 12 ? "am" : "pm";
            final isCurrentHour = hour == DateTime.now().hour;
            return Text(
              "$hourPeriod$period",
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.normal,
              ),
            );
          },
          itemBuilder: (item) => Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(220),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                item.data ?? "",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          nowIndicatorColor: Colors.red,
          snapToDay: true,
        ),
        floatingActionButton: FloatingActionButton(
          child: const Text("Now"),
          onPressed: () => controller.jumpTo(_nowCell()),
        ),
      );
}

/// Generates some random items for the timetable.
List<TimetableItem<String, DateTime>> generateItems() {
  final random = Random();
  final items = <TimetableItem<String, DateTime>>[];
  final today = DateUtils.dateOnly(DateTime.now());
  for (var i = 0; i < 100; i++) {
    int hourOffset = random.nextInt(56 * 24) - (7 * 24);
    final date = today.add(Duration(hours: hourOffset));
    final endDate = date.add(Duration(minutes: (random.nextInt(8) * 15) + 15));
    items.add(TimetableItem.dateTime(
      start: date,
      end: endDate,
      data: "item $i",
    ));
  }
  return items;
}
