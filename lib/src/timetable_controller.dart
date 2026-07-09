import 'dart:math';

import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:flutter_timetable/src/timetable_header_cell.dart';

/// A controller for the timetable.
///
/// The controller allow initialization of the timetable and to expose timetable functionality to the outside.
class TimetableController<Header> {
  TimetableController({
    /// The number of day columns to show.
    int initialColumns = 3,
    this.startHour = 0,
    this.endHour = 23,
    required TimetableHeaderConfig<Header> headerConfig,

    /// The height of each cell in the timetable. Default is 50.
    double? cellHeight,

    /// The height of the header in the timetable. Default is 50.
    double? headerHeight,

    /// The width of the timeline where hour labels are rendered. Default is 50.
    double? timelineWidth,

    /// Controller event listener.
    Function(TimetableControllerEvent)? onEvent,
    this.dateOfTable,
  }) {
    _columns = initialColumns;
    _headers = headerConfig.headers;
    _headerNameFormatter = headerConfig.nameFormatter;
    _cellHeight = cellHeight ?? 50;
    _headerHeight = headerHeight ?? 50;
    _timelineWidth = timelineWidth ?? 50;
    _visibleTimetableCellHeader = _headers.first;
    duration = Duration(hours: (endHour - startHour) + 1);
    if (onEvent != null) addListener(onEvent);
  }

  final int startHour;
  final int endHour;
  late final Duration duration;

  List<TimetableHeader<Header>> get headers => _headers;

  set cellHeaders(List<TimetableHeader<Header>> headers) {
    _headers = headers;
    dispatch(TimetableCellHeadersChanged(headers));
  }

  late List<TimetableHeader<Header>> _headers;

  late HeaderNameFormatter<Header> _headerNameFormatter;
  HeaderNameFormatter<Header> get headerNameFormatter => _headerNameFormatter;

  int _columns = 3;

  /// The current number of [columns] in the timetable.
  int get columns => _columns;

  double _cellHeight = 50.0;

  /// The current height of each cell in the timetable.
  double get cellHeight => _cellHeight;

  final Map<int, Function(TimetableControllerEvent)> _listeners = {};
  bool get hasListeners => _listeners.isNotEmpty;

  double _headerHeight = 50.0;

  /// The current height of the header in the timetable.
  double get headerHeight => _headerHeight;

  double _timelineWidth = 50.0;

  /// The current width of the timeline where hour labels are rendered.
  double get timelineWidth => _timelineWidth;

  DateTime? dateOfTable;

  late TimetableHeader<Header> _visibleTimetableCellHeader;

  /// The first header of the visible area of the timetable.
  TimetableHeader<Header> get visibleTimetableHeader =>
      _visibleTimetableCellHeader;

  /// Allows listening to events dispatched from the timetable
  int addListener(Function(TimetableControllerEvent)? listener) {
    if (listener == null) return -1;
    final id = _listeners.isEmpty ? 0 : _listeners.keys.reduce(max) + 1;
    _listeners[id] = listener;
    return id;
  }

  /// Removes a listener from the timetable
  void removeListener(int id) => _listeners.remove(id);

  /// Removes all listeners from the timetable
  void clearListeners() => _listeners.clear();

  /// Dispatches an event to all listeners
  void dispatch(TimetableControllerEvent event) {
    for (var listener in _listeners.values) {
      listener(event);
    }
  }

  /// Scrolls the timetable to the given date and time.
  @Deprecated('')
  void jumpToLegacy(DateTime date) {
    dispatch(TimetableJumpToRequestedLegacy(date));
  }

  void jumpTo(TimetableCell<Header> cell) {
    dispatch(TimetableJumpToRequested(cell));
  }

  /// Updates the number of columns in the timetable
  setColumns(int i) {
    if (i == _columns) return;
    _columns = i;
    dispatch(TimetableColumnsChanged(i));
  }

  /// Updates the height of each cell in the timetable
  setCellHeight(double height) {
    if (height == _cellHeight) return;
    if (height <= 0) return;
    _cellHeight = min(height, 1000);
    dispatch(TimetableCellHeightChanged(height));
  }

  /// This allows the timetable to update the current visible header.
  void updateVisibleHeader(TimetableHeader<Header> header) {
    _visibleTimetableCellHeader = header;
    dispatch(TimetableVisibleHeaderChanged(header));
  }
}

/// A generic event that can be dispatched from the timetable controller
abstract class TimetableControllerEvent {}

/// Event used to change the cell height of the timetable
class TimetableCellHeightChanged extends TimetableControllerEvent {
  final double height;
  TimetableCellHeightChanged(this.height);
}

/// Event used to change the number of columns in the timetable
class TimetableColumnsChanged extends TimetableControllerEvent {
  TimetableColumnsChanged(this.columns);
  final int columns;
}

/// Event used to scroll the timetable to a given date and time
@Deprecated('')
class TimetableJumpToRequestedLegacy extends TimetableControllerEvent {
  TimetableJumpToRequestedLegacy(this.date);
  final DateTime date;
}

class TimetableJumpToRequested<Header> extends TimetableControllerEvent {
  final TimetableCell<Header> cell;
  TimetableJumpToRequested(this.cell);
}

/// Event dispatched when the start date of the timetable changes
@Deprecated('')
class TimetableStartChanged extends TimetableControllerEvent {
  TimetableStartChanged(this.start);
  final DateTime start;
}

class TimetableCellHeadersChanged extends TimetableControllerEvent {
  TimetableCellHeadersChanged(this.headers);
  final List<TimetableHeader> headers;
}

/// Event dispatched when the visible date of the timetable changes
@Deprecated('')
class TimetableVisibleDateChanged extends TimetableControllerEvent {
  TimetableVisibleDateChanged(this.start);
  final DateTime start;
}

class TimetableVisibleHeaderChanged extends TimetableControllerEvent {
  TimetableVisibleHeaderChanged(this.header);
  final TimetableHeader header;
}
