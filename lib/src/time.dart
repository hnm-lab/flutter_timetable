import 'package:flutter/material.dart';

class TimeOfLongDay implements Comparable<TimeOfLongDay> {
  /// Creates a time of day.
  ///
  /// The [hour] argument must be more than 0. The [minute]
  /// argument must be between 0 and 59, inclusive.
  const TimeOfLongDay({required this.hour, required this.minute});

  /// Creates a time of day based on the given time.
  ///
  /// The [hour] is set to the time's hour and the [minute] is set to the time's
  /// minute in the timezone of the given [DateTime].
  TimeOfLongDay.fromDateTime(DateTime time)
      : hour = time.hour,
        minute = time.minute;

  /// Creates a time of day based on the current time.
  ///
  /// The [hour] is set to the current hour and the [minute] is set to the
  /// current minute in the local time zone.
  factory TimeOfLongDay.now() {
    return TimeOfLongDay.fromDateTime(DateTime.now());
  }

  /// The number of hours in one day, i.e. 24.
  static const int hoursPerDay = 24;

  /// The number of hours in one day period (see also [DayPeriod]), i.e. 12.
  static const int hoursPerPeriod = 12;

  /// The number of minutes in one hour, i.e. 60.
  static const int minutesPerHour = 60;

  /// Returns a new TimeOfDay with the hour and/or minute replaced.
  TimeOfLongDay replacing({int? hour, int? minute}) {
    assert(hour == null || (hour >= 0));
    assert(minute == null || (minute >= 0 && minute < minutesPerHour));
    return TimeOfLongDay(
        hour: hour ?? this.hour, minute: minute ?? this.minute);
  }

  /// The selected hour, in 24 hour time from 0..23.
  final int hour;

  /// The selected minute.
  final int minute;

  /// Whether this time of day is before or after noon.
  DayPeriod get period => hour < hoursPerPeriod ? DayPeriod.am : DayPeriod.pm;

  /// Which hour of the current period (e.g., am or pm) this time is.
  ///
  /// For 12AM (midnight) and 12PM (noon) this returns 12.
  int get hourOfPeriod => hour == 0 || hour == 12 ? 12 : hour - periodOffset;

  /// The hour at which the current period starts.
  int get periodOffset => period == DayPeriod.am ? 0 : hoursPerPeriod;

  @override
  bool operator ==(Object other) {
    return other is TimeOfLongDay &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() {
    String addLeadingZeroIfNeeded(int value) {
      if (value < 10) {
        return '0$value';
      }
      return value.toString();
    }

    final String hourLabel = addLeadingZeroIfNeeded(hour);
    final String minuteLabel = addLeadingZeroIfNeeded(minute);

    return '$TimeOfLongDay($hourLabel:$minuteLabel)';
  }

  bool isBefore(TimeOfLongDay other) {
    return (_inMinute()) < (other._inMinute());
  }

  bool isAfter(TimeOfLongDay other) {
    return (_inMinute()) > (other._inMinute());
  }

  @override
  int compareTo(TimeOfLongDay other) {
    return _inMinute().compareTo(other._inMinute());
  }

  int _inMinute() => hour * 60 + minute;
}
