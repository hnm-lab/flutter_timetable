import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kotlin_scope_function/kotlin_scope_function.dart';

class TimetableHeaderConfig<Header> {
  final List<TimetableHeader<Header>> headers;
  final HeaderNameFormatter<Header> nameFormatter;

  TimetableHeaderConfig(this.headers, this.nameFormatter);

  static final defaultDateTimeHeader = dateTimeHeader(
      start: DateTime.now(), format: DateFormat('MMM\nd'), duration: 7);

  static TimetableHeaderConfig<DateTime> dateTimeHeader(
          {required DateTime start,
          required DateFormat format,
          int duration = 7}) =>
      TimetableHeaderConfig<DateTime>(
        start.let(
          (now) => List<TimetableHeader<DateTime>>.generate(
            duration,
            (index) => now.add(Duration(days: index)).let(
                  (date) => TimetableHeader<DateTime>(date),
                ),
          ),
        ),
        (date) => format.format(date.value),
      );
}

typedef HeaderNameFormatter<Header> = String Function(TimetableHeader<Header>);

class TimetableHeader<T> {
  final T value;

  TimetableHeader(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableHeader &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'TimetableHeader{value: $value}';
  }
}

class TimetableCell<Header> {
  final int hour;
  final TimetableHeader<Header> header;

  TimetableCell(this.hour, this.header);
  // TODO(tkc): headerのdate timeは日付以外不要。
  static TimetableCell<DateTime> fromDateTime(DateTime dateTime) =>
      TimetableCell(dateTime.hour, TimetableHeader<DateTime>(dateTime));

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: 0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableCell &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          header == other.header;

  @override
  int get hashCode => hour.hashCode ^ header.hashCode;
}
