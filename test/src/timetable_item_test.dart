import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timetable/flutter_timetable.dart';

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
  test('TimetableItem', () {
    const data = "test";
    final item = TimetableItem.dateTime(
        start: DateTime(2020, 1, 1, 1),
        end: DateTime(2020, 1, 1, 2),
        data: data);
    expect(item.start, const TimeOfLongDay(hour: 1, minute: 0));
    expect(item.end, const TimeOfLongDay(hour: 2, minute: 0));
    expect(item.duration, const Duration(hours: 1));
    expect(item.data, isA<String>());
    expect(item.data, data);
  });

  test('TimetableItem asserts start is before end', () {
    expect(
      () => TimetableItem<String, DateTime>(
        start: const TimeOfLongDay(hour: 10, minute: 0),
        end: const TimeOfLongDay(hour: 9, minute: 0),
        header: TimetableHeader(DateTime(2020, 1, 1)),
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  test('TimetableItem supports non-DateTime header types', () {
    final header = TimetableHeader(const _Stage('Main'));
    final item = TimetableItem<String, _Stage>(
      start: const TimeOfLongDay(hour: 10, minute: 0),
      end: const TimeOfLongDay(hour: 11, minute: 0),
      header: header,
      data: 'artist',
    );
    expect(item.header, header);
    expect(item.duration, const Duration(hours: 1));
  });

  test('TimetableItem supports overnight hours beyond 24', () {
    final item = TimetableItem<String, DateTime>(
      start: const TimeOfLongDay(hour: 23, minute: 30),
      end: const TimeOfLongDay(hour: 25, minute: 0),
      header: TimetableHeader(DateTime(2020, 1, 1)),
    );
    expect(item.duration, const Duration(hours: 1, minutes: 30));
  });
}
