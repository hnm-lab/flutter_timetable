import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimetableHeaderConfig<Header> {
  final List<TimetableHeader<Header>> headers;
  final HeaderNameFormatter<Header> nameFormatter;
  static const _defaultDateTimeHeaderDuration = 14;

  TimetableHeaderConfig(this.headers, this.nameFormatter);

  static final defaultDateTimeHeader = dateTimeHeader(
      start: DateTime.now(),
      format: DateFormat('MMM\nd'),
      duration: _defaultDateTimeHeaderDuration);

  static TimetableHeaderConfig<DateTime> dateTimeHeader(
      {required DateTime start,
      required DateFormat format,
      int duration = _defaultDateTimeHeaderDuration}) {
    final now = DateUtils.dateOnly(start);
    final headers = List<TimetableHeader<DateTime>>.generate(
      duration,
      (index) {
        final date = now.add(Duration(days: index));
        return TimetableHeader<DateTime>(date);
      },
    );
    return TimetableHeaderConfig<DateTime>(
      headers,
      (date) => format.format(date.value),
    );
  }
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

  static TimetableCell<DateTime> fromDateTime(DateTime dateTime) =>
      TimetableCell(dateTime.hour,
          TimetableHeader<DateTime>(DateUtils.dateOnly(dateTime)));

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
