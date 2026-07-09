import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timetable/flutter_timetable.dart';

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
}
