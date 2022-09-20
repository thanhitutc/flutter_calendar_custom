import 'package:demo_calendar/calendarro/calendarro.dart';
import 'package:demo_calendar/calendarro/date_utils.dart';
import 'package:demo_calendar/calendarro/default_weekday_labels_row.dart';
import 'package:flutter/material.dart' hide DateUtils;

class CalendarroPage extends StatelessWidget {

  static final MAX_ROWS_COUNT = 6;

  DateTime pageStartDate;
  DateTime pageEndDate;
  Widget weekdayLabelsRow;

  int startDayOffset;

  CalendarroPage({
    required this.pageStartDate,
    required this.pageEndDate,
    required this.weekdayLabelsRow
  }) : startDayOffset = pageStartDate.weekday - DateTime.monday;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            children: buildRows(context),
            mainAxisSize: MainAxisSize.min
        )
    );
  }

  List<Widget> buildRows(BuildContext context) {
    List<Widget> rows = [];
    rows.add(weekdayLabelsRow);

    DateTime rowLastDayDate = DateUtils.addDaysToDate(pageStartDate, 6 - startDayOffset);

    if (pageEndDate.isAfter(rowLastDayDate)) {
      rows.add(Row(
          children: buildCalendarRow(context, pageStartDate.add(Duration(days: -startDayOffset)), rowLastDayDate))
      );

      for (var i = 1; i < MAX_ROWS_COUNT; i++) {
        DateTime nextRowFirstDayDate = DateUtils.addDaysToDate(pageStartDate, 7 * i - startDayOffset);

        if (nextRowFirstDayDate.isAfter(pageEndDate)) {
          break;
        }

        DateTime nextRowLastDayDate = DateUtils.addDaysToDate(pageStartDate, 7 * i - startDayOffset + 6);

        // if (nextRowLastDayDate.isAfter(pageEndDate)) {
        //   nextRowLastDayDate = pageEndDate;
        // }

        rows.add(Row(
            children: buildCalendarRow(
                context, nextRowFirstDayDate, nextRowLastDayDate)));
      }
    } else {
      rows.add(Row(
          children: buildCalendarRow(context, pageStartDate, pageEndDate))
      );
    }

    return rows;
  }

  List<Widget> buildCalendarRow(
      BuildContext context, DateTime rowStartDate, DateTime rowEndDate) {
    CalendarroState? calendarroState = Calendarro.of(context);
    if (calendarroState == null) {
      throw StateError('calendarroState is null');
    }

    List<Widget> items = [];
    DateTime currentDate = rowStartDate;
    for (int i = 0; i < 7; i++) {
      if (i + 1 >= rowStartDate.weekday && i + 1 <= rowEndDate.weekday)  {
          Widget dayTile = calendarroState.widget.dayTileBuilder
              .build(context, currentDate, pageStartDate, calendarroState.widget.onTap);
          items.add(dayTile);
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }

    return items;
  }
}
