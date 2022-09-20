library calendarro;

import 'package:demo_calendar/calendarro/date_range.dart';
import 'package:demo_calendar/calendarro/default_weekday_labels_row.dart';
import 'package:demo_calendar/calendarro/date_utils.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:intl/intl.dart';

typedef DateTimeCallback = void Function(DateTime datetime);
typedef CurrentPageCallback = void Function(DateTime pageStartDate, DateTime pageEndDate);

class Calendar extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final DateTimeCallback? onTap;
  final CurrentPageCallback? onPageSelected;
  final DateTime? selectedSingleDate;
  final List<DateTime> selectedDates;
  late final int startDayOffset;
  final double dayLabelHeight;
  final double monthLabelHeight;

  Calendar({
    Key? key,
    DateTime? startDate,
    DateTime? endDate,
    List<DateTime>? selectedDates,
    this.selectedSingleDate,
    this.onTap,
    this.onPageSelected,
    this.dayLabelHeight = 50.0,
    this.monthLabelHeight = 50.0,
  })  :
        startDate = DateUtils.toMidnight(startDate ?? DateUtils.getFirstDayOfCurrentMonth()),
        endDate = DateUtils.toMidnight(endDate ?? DateUtils.getLastDayOfCurrentMonth()),
        selectedDates = selectedDates ?? [],
        super(key: key) {
    startDayOffset = this.startDate.weekday - DateTime.monday;
    if (this.startDate.isAfter(this.endDate)) {
      throw ArgumentError("Calendarro: startDate is after the endDate");
    }
  }

  @override
  CalendarState createState() => CalendarState();

  int getPageForDate(DateTime date) => (date.year * 12 + date.month) - (startDate.year * 12 + startDate.month);
}

class CalendarState extends State<Calendar> {
  DateTime? _selectedSingleDate;
  late double _availableHeight;
  int _maxWeeksNumber = 5;
  int? _pagesCount;
  PageView? _pageView;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = widget.startDate;
    _selectedSingleDate ??= widget.startDate;
  }

  void setSelectedDate(DateTime date) {
    final alreadyExistingDate = widget.selectedDates.firstWhereOrNull((currentDate) =>
        DateUtils.isSameDay(currentDate, date));
    if (alreadyExistingDate != null) {
      widget.selectedDates.remove(alreadyExistingDate);
    } else {
      widget.selectedDates.add(date);
    }
  }

  void setCurrentDate(DateTime date) {
    setState(() {
      int page = widget.getPageForDate(date);
      _pageView?.controller.jumpToPage(page);
    });
  }

  @override
  Widget build(BuildContext context) {
    _pagesCount = DateUtils.calculateMonthsDifference(widget.startDate, widget.endDate) + 1;
    final selectedDate = _selectedSingleDate;
    _pageView = PageView.builder(
      itemBuilder: (context, position) => Column(
        children: [
          _Month(date: _month, height: widget.monthLabelHeight),
          _buildCalendarPageInMonthsMode(position),
        ],
      ),
      itemCount: _pagesCount,
      controller: PageController(
          initialPage:
          selectedDate != null ? widget.getPageForDate(selectedDate) : 0),
      onPageChanged: (page) {
        if (widget.onPageSelected != null) {
          DateRange pageDateRange = _calculatePageDateRangeInMonthsMode(page);
          widget.onPageSelected?.call(pageDateRange.startDate, pageDateRange.endDate);
          setState(() {
            _month = pageDateRange.startDate;
          });
        }
      },
    );

     _availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        widget.dayLabelHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
     _maxWeeksNumber = DateUtils.calculateMaxWeeksNumberMonthly(
        widget.startDate,
        widget.endDate,
     );
    return Container(
      color: Colors.blueGrey,
      height: _availableHeight,
      child: _pageView,
    );
  }

  Widget _buildCalendarPageInMonthsMode(int position) {
    DateRange pageDateRange = _calculatePageDateRangeInMonthsMode(position);
    return _CalendarPage(
      pageStartDate: pageDateRange.startDate,
      pageEndDate: pageDateRange.endDate,
      weekdayLabelsRow: CalendarWeekdayLabelsView(height: widget.dayLabelHeight),
      dayItemHeight: (_availableHeight - widget.dayLabelHeight - widget.monthLabelHeight)/_maxWeeksNumber,
      selectedDates: widget.selectedDates,
      onTap: (date) {
        widget.onTap?.call(date);
        setSelectedDate(date);
        setCurrentDate(date);
      },
    );
  }

  DateRange _calculatePageDateRangeInMonthsMode(int pagePosition) {
    final count = _pagesCount;
    if (count == null) {
      throw StateError('pagesCount is null');
    }

    DateTime pageStartDate;
    DateTime pageEndDate;

    if (pagePosition == 0) {
      pageStartDate = widget.startDate;
      if (count <= 1) {
        pageEndDate = widget.endDate;
      } else {
        var lastDayOfMonth = DateUtils.getLastDayOfMonth(widget.startDate);
        pageEndDate = lastDayOfMonth;
      }
    } else if (pagePosition == count - 1) {
      pageStartDate = DateUtils.getFirstDayOfMonth(widget.endDate);
      pageEndDate = widget.endDate;
    } else {
      DateTime firstDateOfCurrentMonth = DateUtils.addMonths(
          widget.startDate,
          pagePosition);
      pageStartDate = firstDateOfCurrentMonth;
      pageEndDate = DateUtils.getLastDayOfMonth(firstDateOfCurrentMonth);
    }

    return DateRange(pageStartDate, pageEndDate);
  }
}

class _CalendarPage extends StatelessWidget {
  static const maxRowsCount = 6;

  final DateTime pageStartDate;
  final DateTime pageEndDate;
  final Widget weekdayLabelsRow;

  final int startDayOffset;
  final double dayItemHeight;
  final List<DateTime> selectedDates;
  final DateTimeCallback? onTap;

  _CalendarPage({
    Key? key,
    required this.pageStartDate,
    required this.pageEndDate,
    required this.weekdayLabelsRow,
    required this.dayItemHeight,
    required this.selectedDates,
    this.onTap,
  }) : startDayOffset = pageStartDate.weekday - DateTime.monday, super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blueGrey,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: buildRows(
                dayItemHeight: dayItemHeight,
                selectedDates: selectedDates,
                onTap: onTap,
            ),
        ),
    );
  }

  List<Widget> buildRows({
    required double dayItemHeight,
    required List<DateTime> selectedDates,
    DateTimeCallback? onTap,
  }) {
    List<Widget> rows = [];
    rows.add(weekdayLabelsRow);

    DateTime rowLastDayDate = DateUtils.addDaysToDate(pageStartDate, 6 - startDayOffset);

    if (pageEndDate.isAfter(rowLastDayDate)) {
      rows.add(Row(
          children: buildCalendarRow(
        rowStartDate: pageStartDate.add(Duration(days: -startDayOffset)),
        rowEndDate: rowLastDayDate,
        dayItemHeight: dayItemHeight,
        selectedDates: selectedDates,
        onTap: onTap,
      )));

      for (var i = 1; i < maxRowsCount; i++) {
        DateTime nextRowFirstDayDate = DateUtils.addDaysToDate(pageStartDate, 7 * i - startDayOffset);
        if (nextRowFirstDayDate.isAfter(pageEndDate)) {
          break;
        }
        DateTime nextRowLastDayDate = DateUtils.addDaysToDate(pageStartDate, 7 * i - startDayOffset + 6);
        rows.add(Row(
            children: buildCalendarRow(
          rowStartDate: nextRowFirstDayDate,
          rowEndDate: nextRowLastDayDate,
          dayItemHeight: dayItemHeight,
          selectedDates: selectedDates,
          onTap: onTap,
        )));
      }
    } else {
      rows.add(Row(children: buildCalendarRow(
        rowStartDate: pageStartDate,
        rowEndDate: pageEndDate,
        dayItemHeight: dayItemHeight,
        selectedDates: selectedDates,
        onTap: onTap,
      )));
    }
    return rows;
  }

  List<Widget> buildCalendarRow({
    required DateTime rowStartDate,
    required DateTime rowEndDate,
    required double dayItemHeight,
    required List<DateTime> selectedDates,
    DateTimeCallback? onTap,
  }) {
    List<Widget> items = [];
    DateTime currentDate = rowStartDate;
    for (int i = 0; i < 7; i++) {
      if (i + 1 >= rowStartDate.weekday && i + 1 <= rowEndDate.weekday)  {
        Widget dayTile = _CalendarDayItem(
          selectedDates: selectedDates,
          height: dayItemHeight,
          date: currentDate,
          month: pageStartDate,
          onTap: onTap,
        );
        items.add(dayTile);
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }
    return items;
  }
}

class _Month extends StatelessWidget {
  const _Month({
    required this.date,
    required this.height,
  });

  final DateTime date;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        // DateFormat.yMMM('ja').format(date),
        '$date',
        textAlign: TextAlign.start,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }
}

class _CalendarDayItem extends StatelessWidget {
  const _CalendarDayItem({
    required this.selectedDates,
    required this.date,
    required this.month,
    required this.height,
    this.onTap,
  });

  final DateTime date;
  final DateTime month;
  final List<DateTime> selectedDates;
  final DateTimeCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    bool isCurrentMonth = DateUtils.isDayOfMonth(date, month);
    var textColor = isCurrentMonth ? Colors.black : Colors.grey;
    var backgroundColor = isCurrentMonth ? Colors.white : Colors.amberAccent;

    bool daySelected = _isDateSelected(date);

    BoxDecoration? boxDecoration;
    if (daySelected) {
      boxDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue,
          border: Border.all(
            color: Colors.blueGrey,
            width: 4.0,
          ),
          shape: BoxShape.rectangle);
    } else {
      boxDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: backgroundColor,
          border: Border.all(
            color: Colors.blueGrey,
            width: 4.0,
          ),
          shape: BoxShape.rectangle);
    }

    return Expanded(
        child: GestureDetector(
          onTap: handleTap,
          behavior: HitTestBehavior.translucent,
          child: Container(
              height: height,
              decoration: boxDecoration,
              child: Center(
                  child: Text(
                    "${date.day} \n 通常営業",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textColor),
                  ))),
        ));
  }

  void handleTap() {
    if (!DateUtils.isDayOfMonth(date, month)) return;
    onTap?.call(date);
  }

  bool _isDateSelected(DateTime date) {
    final matchedSelectedDate = selectedDates.firstWhereOrNull((currentDate) => DateUtils.isSameDay(currentDate, date));
    return matchedSelectedDate != null;
  }
}

extension IterableExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    final list = where(test);
    return list.isEmpty ? null : list.first;
  }
}
