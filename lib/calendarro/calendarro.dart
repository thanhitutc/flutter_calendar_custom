library calendarro;

import 'package:demo_calendar/calendarro/default_weekday_labels_row.dart';
import 'package:demo_calendar/calendarro/date_utils.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:intl/intl.dart';

typedef DateTimeCallback = void Function(DateTime datetime);
typedef MonthSelectedCallback = void Function(DateTime pageStartDate, DateTime pageEndDate);

class Calendar extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final DateTimeCallback? onTap;
  final MonthSelectedCallback? onMonthSelected;
  final DateTime? selectedSingleDate;
  final List<DateTime> selectedDates;
  late final int startDayOffset;
  final double dayLabelHeight;
  final double monthLabelHeight;
  final double navigationButtonWidth;

  Calendar({
    Key? key,
    DateTime? startDate,
    DateTime? endDate,
    List<DateTime>? selectedDates,
    this.selectedSingleDate,
    this.onTap,
    this.onMonthSelected,
    this.dayLabelHeight = 50.0,
    this.monthLabelHeight = 50.0,
    this.navigationButtonWidth = 50.0,
  })  :
        startDate = DateUtils.toMidnight(startDate ?? DateUtils.getFirstDayOfCurrentMonth()),
        endDate = DateUtils.toMidnight(endDate ?? DateUtils.getLastDayOfCurrentMonth()),
        selectedDates = selectedDates ?? [],
        super(key: key) {
    startDayOffset = this.startDate.weekday - DateTime.monday;
    if (this.startDate.isAfter(this.endDate)) {
      throw ArgumentError("Calendar: startDate is after the endDate");
    }
  }

  @override
  CalendarState createState() => CalendarState();

  int getPageForDate(DateTime date) => (date.year * 12 + date.month) - (startDate.year * 12 + startDate.month);
}

class CalendarState extends State<Calendar> {
  List<DateTime> _selectedDates = [];
  int _maxWeeksNumber = 6;
  late int _startDayOffset = _startDate.weekday - DateTime.monday;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  void setSelectedDate(DateTime date) {
    final alreadyExistingDate = widget.selectedDates.firstWhereOrNull((currentDate) =>
        DateUtils.isSameDay(currentDate, date));
    if (alreadyExistingDate != null) {
      widget.selectedDates.remove(alreadyExistingDate);
    } else {
      widget.selectedDates.add(date);
    }
    setState(() {
      _selectedDates = widget.selectedDates;
    });
  }

  @override
  Widget build(BuildContext context) {
     final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        widget.dayLabelHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
     _maxWeeksNumber = DateUtils.calculateMaxWeeksNumberMonthly(
        _startDate,
        _endDate,
     );

    return Container(
      color: Colors.blueGrey,
      height: availableHeight,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
        InkWell(
          onTap: () {
            final firstDayPreviousMonth = DateUtils.getFirstDayOfPreviousMonth(_startDate);
            final lastDayPreviousMonth = DateUtils.getLastDayOfPreviousMonth(_startDate);
            setState(() {
              _startDate = firstDayPreviousMonth;
              _endDate = lastDayPreviousMonth;
              _startDayOffset = _startDate.weekday - DateTime.monday;
              _maxWeeksNumber = DateUtils.calculateMaxWeeksNumberMonthly(
                _startDate,
                _endDate,
              );
            });
            widget.onMonthSelected?.call(
              firstDayPreviousMonth.add(Duration(days: - _startDayOffset)),
              lastDayPreviousMonth.add(Duration(days: (_maxWeeksNumber * 7 - _startDayOffset - lastDayPreviousMonth.day))),
            );
          },
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.white,
            width: widget.navigationButtonWidth,
            height: (availableHeight - widget.dayLabelHeight - widget.monthLabelHeight)/_maxWeeksNumber * 1.5,
            child: const Center(child: Text('prev', textAlign: TextAlign.center,))),
          ),
        SizedBox(
            width: MediaQuery.of(context).size.width - widget.navigationButtonWidth * 2 - 40,
            child: Column(
              children: [
                _Month(date: _startDate, height: widget.monthLabelHeight),
                _CalendarPage(
                  pageStartDate: _startDate,
                  pageEndDate: _endDate,
                  weekdayLabelsRow: CalendarWeekdayLabelsView(height: widget.dayLabelHeight),
                  dayItemHeight: (availableHeight - widget.dayLabelHeight - widget.monthLabelHeight)/_maxWeeksNumber,
                  selectedDates: _selectedDates,
                  startDayOffset: _startDayOffset,
                  onTap: (date) {
                    widget.onTap?.call(date);
                    setSelectedDate(date);
                  },
                ),
              ],
            ),
        ),
          InkWell(
            onTap: ()  {
              final firstDayNextMonth = DateUtils.getFirstDayOfNextMonth(_startDate);
              final lastDayNextMonth = DateUtils.getLastDayOfNextMonth(_startDate);
              setState(() {
                _startDate = firstDayNextMonth;
                _endDate = lastDayNextMonth;
                _startDayOffset = _startDate.weekday - DateTime.monday;
                _maxWeeksNumber = DateUtils.calculateMaxWeeksNumberMonthly(
                  _startDate,
                  _endDate,
                );
              });
              print("thanh_max week: $_maxWeeksNumber");
              widget.onMonthSelected?.call(
                firstDayNextMonth.add(Duration(days: - _startDayOffset)),
                lastDayNextMonth.add(Duration(days: (_maxWeeksNumber * 7 - _startDayOffset - lastDayNextMonth.day))),
              );
            },
            customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                color: Colors.white,
                width: widget.navigationButtonWidth,
                height: (availableHeight - widget.dayLabelHeight - widget.monthLabelHeight)/_maxWeeksNumber * 1.5,
                child: const Center(child: Text('next', textAlign: TextAlign.center,))),
          ),
      ],),
    );
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

  const _CalendarPage({
    required this.pageStartDate,
    required this.pageEndDate,
    required this.weekdayLabelsRow,
    required this.dayItemHeight,
    required this.selectedDates,
    required this.startDayOffset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blueGrey,
        child: Column(
            mainAxisSize: MainAxisSize.max,
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
      rows.add(Row(children: buildCalendarRow(
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
                    "${date.day} \n text custom",
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
