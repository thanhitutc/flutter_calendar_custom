import 'package:demo_calendar/calendarro/calendarro.dart';
import 'package:demo_calendar/calendarro/date_utils.dart';
import 'package:flutter/material.dart' hide DateUtils;

class CalendarroDayItem extends StatelessWidget {
  CalendarroDayItem({
    required this.date,
    required this.month,
    required this.calendarroState,
    this.onTap,
  });

  DateTime date;
  DateTime month;
  CalendarroState calendarroState;
  DateTimeCallback? onTap;

  @override
  Widget build(BuildContext context) {
    bool isCurrentMonth = DateUtils.isDayOfMonth(date, month);
    var textColor = isCurrentMonth ? Colors.black : Colors.grey;
    bool isToday = DateUtils.isToday(date);

    bool daySelected = calendarroState.isDateSelected(date);

    BoxDecoration? boxDecoration;
    if (daySelected) {
      boxDecoration = BoxDecoration(color: Colors.blue);
    } else if (isToday) {
      boxDecoration = BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 1.0,
          ),
          shape: BoxShape.circle);
    } else {
      boxDecoration = BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 4.0,
          ),
          shape: BoxShape.rectangle);
    }

    return Expanded(
        child: GestureDetector(
          onTap: handleTap,
          behavior: HitTestBehavior.translucent,
          child: Container(
              height: 40,
              decoration: boxDecoration,
              child: Center(
                  child: Text(
                    "${date.day} \n hihi",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textColor),
                  ))),
        ));
  }

  void handleTap() {
    if (!DateUtils.isDayOfMonth(date, month)) return;
    onTap?.call(date);
    calendarroState.setSelectedDate(date);
    calendarroState.setCurrentDate(date);
  }
}