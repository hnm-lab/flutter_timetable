import 'package:flutter/material.dart';
import 'package:flutter_timetable/flutter_timetable.dart';

/// A time table item is a single entry in a time table.
/// Required fields:
///  - [startHour] - The start hour of the item
///  - [endHour] - The end hour of the item
///
/// Optional fields:
///  - [data] - Optional generic payload that can be used by the item builder to render the item card
///
/// Calculated fields:
/// - [duration] - Duration is the difference between [start] and [end] provided in the constructor
class TimetableItem<T, Header> {
  static TimetableItem<String, DateTime> dateTime(
      {required DateTime start, required DateTime end, String? data}) {
    return TimetableItem<String, DateTime>(
      start: TimeOfLongDay.fromDateTime(start),
      end: TimeOfLongDay.fromDateTime(end),
      header: TimetableHeader<DateTime>(DateUtils.dateOnly(start)),
      data: data,
    );
  }

  TimetableItem({
    required this.start,
    required this.end,
    required this.header,
    this.data,
  })  : assert(start.isBefore(end), 'start($start) is not before end($end)'),
        duration = Duration(
            hours: end.hour - start.hour, minutes: end.minute - start.minute);
  final TimeOfLongDay start;
  final TimeOfLongDay end;
  final TimetableHeader<Header> header;
  final T? data;
  final Duration duration;
}
