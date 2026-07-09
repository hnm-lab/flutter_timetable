import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timetable/flutter_timetable.dart';

void main() {
  group('TimeOfLongDay', () {
    test('equality and hashCode are based on hour and minute', () {
      const a = TimeOfLongDay(hour: 10, minute: 30);
      const b = TimeOfLongDay(hour: 10, minute: 30);
      const c = TimeOfLongDay(hour: 10, minute: 31);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });

    test('fromDateTime extracts hour and minute', () {
      final time = TimeOfLongDay.fromDateTime(DateTime(2024, 1, 1, 23, 45));
      expect(time, const TimeOfLongDay(hour: 23, minute: 45));
    });

    test('supports hours beyond 24 for overnight festival sets', () {
      // e.g. an after-midnight set is represented as 25:30 rather than 1:30
      // the next day, so it still sorts after the rest of the same day.
      const time = TimeOfLongDay(hour: 25, minute: 30);
      expect(time.hour, 25);
      expect(time.isAfter(const TimeOfLongDay(hour: 23, minute: 0)), isTrue);
    });

    test('isBefore/isAfter/compareTo order by total minutes', () {
      const earlier = TimeOfLongDay(hour: 9, minute: 0);
      const later = TimeOfLongDay(hour: 9, minute: 30);
      expect(earlier.isBefore(later), isTrue);
      expect(later.isAfter(earlier), isTrue);
      expect(earlier.compareTo(later), lessThan(0));
      expect(later.compareTo(earlier), greaterThan(0));
      expect(earlier.compareTo(earlier), 0);
    });

    test('replacing overrides only the given field', () {
      const time = TimeOfLongDay(hour: 10, minute: 15);
      expect(
          time.replacing(hour: 12), const TimeOfLongDay(hour: 12, minute: 15));
      expect(time.replacing(minute: 45),
          const TimeOfLongDay(hour: 10, minute: 45));
    });

    test('toString pads hour and minute to two digits', () {
      const time = TimeOfLongDay(hour: 9, minute: 5);
      expect(time.toString(), 'TimeOfLongDay(09:05)');
    });

    test('period is am before hour 12 and pm from hour 12 onward', () {
      expect(const TimeOfLongDay(hour: 0, minute: 0).period, DayPeriod.am);
      expect(const TimeOfLongDay(hour: 11, minute: 59).period, DayPeriod.am);
      expect(const TimeOfLongDay(hour: 12, minute: 0).period, DayPeriod.pm);
    });
  });
}
