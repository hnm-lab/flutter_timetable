import 'package:flutter/material.dart';

import '../flutter_timetable.dart';

/// The [Timetable] widget displays calendar like view of the events that scrolls
/// horizontally through the days and vertical through the hours.
/// <img src="https://github.com/yourfriendken/flutter_timetable/raw/main/images/default.gif" width="400" />
class Timetable<Value, Header> extends StatefulWidget {
  /// [TimetableController] is the widget.controller that also initialize the timetable.
  final TimetableController<Header> controller;

  /// Renders for the cells the represent each hour that provides that [DateTime] for that hour
  @Deprecated('')
  final Widget Function(DateTime)? cellBuilderLegacy;
  final Widget Function(TimetableCell<Header>)? cellBuilder;

  /// Renders for the header that provides the [DateTime] for the day
  @Deprecated('')
  final Widget Function(DateTime)? headerCellBuilderLegacy;
  final Widget Function(TimetableHeader<Header>)? headerCellBuilder;

  /// Timetable items to display in the timetable
  final List<TimetableItem<Value, Header>> items;

  /// Renders event card from `TimetableItem<T>` for each item
  final Widget Function(TimetableItem<Value, Header>)? itemBuilder;

  /// Renders hour label given [TimeOfDay] for each hour
  final Widget Function(int hour)? hourLabelBuilder;

  /// Renders upper left corner of the timetable given the first visible date
  final Widget Function(TimetableHeader<Header> current)? cornerBuilder;

  /// Snap to hour column. Default is `true`.
  final bool snapToDay;

  /// Color of indicator line that shows the current time. Default is `Theme.indicatorColor`.
  final Color? nowIndicatorColor;

  /// The [Timetable] widget displays calendar like view of the events that scrolls
  /// horizontally through the days and vertical through the hours.
  /// <img src="https://github.com/yourfriendken/flutter_timetable/raw/main/images/default.gif" width="400" />
  const Timetable({
    Key? key,
    required this.controller,
    this.cellBuilder,
    @Deprecated('') this.cellBuilderLegacy,
    this.headerCellBuilder,
    @Deprecated('') this.headerCellBuilderLegacy,
    this.items = const [],
    this.itemBuilder,
    this.hourLabelBuilder,
    this.nowIndicatorColor,
    this.cornerBuilder,
    this.snapToDay = true,
  }) : super(key: key);

  @override
  State<Timetable<Value, Header>> createState() =>
      _TimetableState<Value, Header>();
}

class _TimetableState<Value, Header> extends State<Timetable<Value, Header>> {
  final _dayScrollController = ScrollController();
  final _dayHeadingScrollController = ScrollController();
  final _timeScrollController = ScrollController();
  double columnWidth = 50.0;
  final _key = GlobalKey();
  Color get nowIndicatorColor =>
      widget.nowIndicatorColor ?? Theme.of(context).indicatorColor;
  TimetableController? _controller;

  @override
  void initState() {
    if (widget.items.isNotEmpty) {
      widget.items.sort((a, b) => a.start.hour.compareTo(b.start.hour));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => adjustColumnWidth());

    super.initState();
  }

  @override
  void dispose() {
    _dayScrollController.dispose();
    _dayHeadingScrollController.dispose();
    _timeScrollController.dispose();
    super.dispose();
  }

  _eventHandler(TimetableControllerEvent event) async {
    if (event is TimetableJumpToRequested<Header>) {
      _jumpTo(event.cell);
    }

    if (event is TimetableColumnsChanged) {
      final visibleHeader = widget.controller.visibleTimetableHeader;
      final now = DateTime.now();
      await adjustColumnWidth();
      _jumpTo(TimetableCell(now.hour, visibleHeader));
      return;
    }

    if (mounted) setState(() {});
  }

  Future adjustColumnWidth() async {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    if (box.hasSize) {
      final size = box.size;
      final layoutWidth = size.width;
      final width = (layoutWidth - widget.controller.timelineWidth) /
          widget.controller.columns;
      if (width != columnWidth) {
        columnWidth = width;
        await Future.microtask(() => null);
        setState(() {});
      }
    }
  }

  bool _isTableScrolling = false;
  bool _isHeaderScrolling = false;

  @override
  Widget build(BuildContext context) {
    _controller?.clearListeners();
    _controller = widget.controller.also((it) {
      it.addListener(_eventHandler);
    });

    final timetableHeight =
        widget.controller.cellHeight * widget.controller.duration.inHours;
    return LayoutBuilder(
        key: _key,
        builder: (context, constraints) {
          return Column(
            children: [
              SizedBox(
                height: widget.controller.headerHeight,
                child: Row(
                  children: [
                    // Corner
                    SizedBox(
                      width: widget.controller.timelineWidth,
                      height: widget.controller.headerHeight,
                      child: _buildCorner(),
                    ),
                    // Header
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (_isTableScrolling) return false;
                          if (notification is ScrollEndNotification) {
                            _snapToCloset();
                            _updateVisibleDate();
                            _isHeaderScrolling = false;
                            return true;
                          }
                          _isHeaderScrolling = true;
                          _dayScrollController.jumpTo(
                              _dayHeadingScrollController.position.pixels);
                          return false;
                        },
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: _dayHeadingScrollController,
                          itemExtent: columnWidth,
                          itemCount: widget.controller.headers.length,
                          itemBuilder: (context, i) => SizedBox(
                            width: columnWidth,
                            child: _buildHeaderCell(i),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (_isHeaderScrolling) return false;

                    if (notification is ScrollEndNotification) {
                      _snapToCloset();
                      _updateVisibleDate();
                      _isTableScrolling = false;
                      return true;
                    }
                    _isTableScrolling = true;
                    _dayHeadingScrollController
                        .jumpTo(_dayScrollController.position.pixels);
                    return true;
                  },
                  child: SingleChildScrollView(
                    controller: _timeScrollController,
                    child: SizedBox(
                      height: timetableHeight,
                      child: Row(
                        children: [
                          // 時間
                          SizedBox(
                            width: widget.controller.timelineWidth,
                            height: timetableHeight,
                            child: Column(
                              children: [
                                SizedBox(
                                    height: widget.controller.cellHeight / 2),
                                for (var i = widget.controller.startHour + 1;
                                    i < widget.controller.endHour + 1;
                                    i++) //
                                  SizedBox(
                                    height: widget.controller.cellHeight,
                                    child: Center(child: _buildHour(i)),
                                  ),
                              ],
                            ),
                          ),
                          // セル
                          Expanded(
                            child: Stack(
                              children: [
                                ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  // cacheExtent: 10000.0,
                                  itemExtent: columnWidth,
                                  controller: _dayScrollController,
                                  itemCount: widget.controller.headers.length,
                                  itemBuilder: (context, index) {
                                    final header =
                                        widget.controller.headers[index];
                                    final events = widget.items
                                        .where((item) => item.header == header)
                                        .toList();
                                    final now = DateTime.now();
                                    final bool isToday;
                                    final headerValue = header.value;
                                    if (headerValue is DateTime) {
                                      // TODO(tkc): 24時超えると正しく動かなそう
                                      isToday =
                                          DateUtils.isSameDay(headerValue, now);
                                    } else {
                                      isToday = false;
                                    }
                                    return Container(
                                      clipBehavior: Clip.none,
                                      width: columnWidth,
                                      height: timetableHeight,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Column(
                                            children: [
                                              for (int i = widget
                                                      .controller.startHour;
                                                  i <
                                                      widget.controller
                                                              .endHour +
                                                          1;
                                                  i++)
                                                SizedBox(
                                                  width: columnWidth,
                                                  height: widget
                                                      .controller.cellHeight,
                                                  child: Center(
                                                    child: _buildCell(
                                                      TimetableCell(i, header),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          // Timetable items
                                          for (final event in events)
                                            Positioned(
                                              top: (event.start.hour -
                                                      widget.controller
                                                          .startHour +
                                                      (event.start.minute /
                                                          60)) *
                                                  widget.controller.cellHeight,
                                              width: columnWidth,
                                              height: event.duration.inMinutes *
                                                  widget.controller.cellHeight /
                                                  60,
                                              child: _buildEvent(event),
                                            ),
                                          if (isToday)
                                            // Now line
                                            Positioned(
                                              top: ((now.hour +
                                                          (now.minute / 60.0)) *
                                                      widget.controller
                                                          .cellHeight) -
                                                  1,
                                              width: columnWidth,
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Container(
                                                    clipBehavior: Clip.none,
                                                    color: nowIndicatorColor,
                                                    height: 2,
                                                    width: columnWidth + 1,
                                                  ),
                                                  Positioned(
                                                    top: -2,
                                                    left: -2,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            nowIndicatorColor,
                                                      ),
                                                      height: 6,
                                                      width: 6,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                if (!_isDateTimeHeader &&
                                    widget.controller.dateOfTable?.let((it) =>
                                            DateUtils.isSameDay(
                                                it, DateTime.now())) ==
                                        true)
                                  _nowLine(DateTime.now()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  bool get _isDateTimeHeader =>
      widget.controller.headers.first.value is DateTime;

  Widget _buildHeaderCell(int i) {
    final header = widget.controller.headers[i];
    if (widget.headerCellBuilder != null) {
      return widget.headerCellBuilder!(header);
    }
    // TODO(tkc): デフォなら太字に…できるならしたい
    // final weight = DateUtils.isSameDay(date, DateTime.now())
    //     ? FontWeight.bold
    //     : FontWeight.normal;
    return Center(
      child: Text(
        widget.controller.headerNameFormatter.call(header),
        style: const TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCell(TimetableCell<Header> cell) {
    if (widget.cellBuilder != null) return widget.cellBuilder!(cell);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
    );
  }

  Widget _buildHour(int hour) {
    if (widget.hourLabelBuilder != null) return widget.hourLabelBuilder!(hour);
    return Text('$hour:00', style: const TextStyle(fontSize: 11));
  }

  Widget _buildCorner() {
    final customCorner =
        widget.cornerBuilder?.call(widget.controller.visibleTimetableHeader);
    if (customCorner != null) {
      return customCorner;
    }
    // TODO(tkc): dateの場合は年を出したい
    return const Center(
      child: Text(
        '',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEvent(TimetableItem<Value, Header> event) {
    if (widget.itemBuilder != null) return widget.itemBuilder!(event);

    final start = TimeOfDay(hour: event.start.hour, minute: event.start.minute);
    final end = TimeOfDay(hour: event.end.hour, minute: event.end.minute);
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Text(
        "${start.hourOfPeriod}:${start.minute.toString().padLeft(2, '0')} ${start.period.name} - ${end.hourOfPeriod}:${end.minute.toString().padLeft(2, '0')} ${end.period.name}",
        style: TextStyle(
          fontSize: 10,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _nowLine(DateTime now) => Positioned(
        top: ((now.hour - widget.controller.startHour + (now.minute / 60.0)) *
                widget.controller.cellHeight) -
            1,
        width: columnWidth * widget.controller.columns,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              clipBehavior: Clip.none,
              color: nowIndicatorColor,
              height: 2,
              width: (columnWidth * widget.controller.columns) + 1,
            ),
            Positioned(
              top: -2,
              left: -2,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: nowIndicatorColor,
                ),
                height: 6,
                width: 6,
              ),
            ),
          ],
        ),
      );

  bool _isSnapping = false;
  final _animationDuration = const Duration(milliseconds: 300);
  final _animationCurve = Curves.bounceOut;
  Future _snapToCloset() async {
    if (_isSnapping || !widget.snapToDay) return;
    _isSnapping = true;
    await Future.microtask(() => null);
    final snapPosition =
        ((_dayScrollController.offset) / columnWidth).round() * columnWidth;
    _dayScrollController.animateTo(
      snapPosition,
      duration: _animationDuration,
      curve: _animationCurve,
    );
    _dayHeadingScrollController.animateTo(
      snapPosition,
      duration: _animationDuration,
      curve: _animationCurve,
    );
    _isSnapping = false;
  }

  _updateVisibleDate() async {
    final index = _dayHeadingScrollController.position.pixels ~/ columnWidth;
    final header = widget.controller.headers[index];
    if (header != widget.controller.visibleTimetableHeader) {
      widget.controller.updateVisibleHeader(header);
      setState(() {});
    }
  }

  Future _jumpTo(TimetableCell<Header> cell) async {
    final datePosition =
        widget.controller.headers.indexOf(cell.header) * columnWidth;
    final hourPosition = ((cell.hour - widget.controller.startHour) *
            widget.controller.cellHeight) -
        (widget.controller.cellHeight / 2);
    await Future.wait([
      _dayScrollController.animateTo(
        datePosition,
        duration: _animationDuration,
        curve: _animationCurve,
      ),
      _timeScrollController.animateTo(
        hourPosition,
        duration: _animationDuration,
        curve: _animationCurve,
      ),
    ]);
  }
}

extension _ObjectE<T extends Object> on T {
  dynamic let(dynamic Function(T it) dealing) {
    return dealing(this);
  }

  T also(void Function(T it) dealing) {
    dealing(this);
    return this;
  }
}
