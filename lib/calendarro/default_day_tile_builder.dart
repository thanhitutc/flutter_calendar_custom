import 'package:demo_calendar/calendarro/calendarro.dart';
import 'package:demo_calendar/calendarro/default_day_tile.dart';
import 'package:flutter/material.dart';

class DefaultDayTileBuilder extends DayTileBuilder {

  DefaultDayTileBuilder();

  @override
  Widget build(BuildContext context, DateTime date, DateTime month, DateTimeCallback? onTap) {
    final state = Calendarro.of(context);
    if (state == null) {
      throw StateError('calendarroState is null');
    }

    return CalendarroDayItem(date: date, calendarroState: state, month: month, onTap: onTap);
  }
}