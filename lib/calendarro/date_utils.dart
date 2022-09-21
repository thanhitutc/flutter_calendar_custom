class DateUtils {
  static DateTime toMidnight(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  static bool isToday(DateTime date) {
    var now = DateTime.now();
    return date.day == now.day && date.month == now.month && date.year == now.year;
  }

  static bool isPastDay(DateTime date) {
    var today = toMidnight(DateTime.now());
    return date.isBefore(today);
  }

  static DateTime addDaysToDate(DateTime date, int days) {
    DateTime newDate = date.add(Duration(days: days));
    if (date.hour != newDate.hour) {
      var hoursDifference = date.hour - newDate.hour;
      if (hoursDifference <= 3 && hoursDifference >= -3) {
        newDate = newDate.add(Duration(hours: hoursDifference));
      } else if (hoursDifference <= -21) {
        newDate = newDate.add(Duration(hours: 24 + hoursDifference));
      } else if (hoursDifference >= 21) {
        newDate = newDate.add(Duration(hours: hoursDifference - 24));
      }
    }
    return newDate;
  }

  static bool isSpecialPastDay(DateTime date) {
    return isPastDay(date) || (isToday(date) && DateTime.now().hour >= 12);
  }

  static DateTime getFirstDayOfCurrentMonth() {
    var dateTime = DateTime.now();
    dateTime = getFirstDayOfMonth(dateTime);
    return dateTime;
  }

  static DateTime getFirstDayOfPreviousMonth(DateTime dateTime) {
    final previousMonth = getFirstDayOfMonth(dateTime).add(const Duration(days: -1));
    dateTime = getFirstDayOfMonth(previousMonth);
    return dateTime;
  }

  static DateTime getLastDayOfPreviousMonth(DateTime dateTime) {
    return getFirstDayOfMonth(dateTime).add(const Duration(days: -1));
  }

  static DateTime getFirstDayOfNextMonth(DateTime dateTime) {
    return getLastDayOfMonth(dateTime).add(const Duration(days: 1));
  }

  static DateTime getLastDayOfNextMonth(DateTime dateTime) {
    return getLastDayOfMonth(getFirstDayOfNextMonth(dateTime));
  }

  static DateTime getLastDayOfCurrentMonth() {
    return getLastDayOfMonth(DateTime.now());
  }

  static DateTime addMonths(DateTime fromMonth, int months) {
    DateTime firstDayOfCurrentMonth = fromMonth;
    for (int i = 0; i < months; i++) {
      firstDayOfCurrentMonth =
          getLastDayOfMonth(firstDayOfCurrentMonth)
              .add(Duration(days: 1));
    }
    
    return firstDayOfCurrentMonth;
  }

  static DateTime getFirstDayOfMonth(DateTime month) {
    return DateTime(month.year, month.month);
  }
  
  static DateTime getLastDayOfMonth(DateTime month) {
    DateTime firstDayOfMonth = DateTime(month.year, month.month);
    DateTime nextMonth = firstDayOfMonth.add(const Duration(days: 32));
    DateTime firstDayOfNextMonth = DateTime(nextMonth.year, nextMonth.month);
    return firstDayOfNextMonth.subtract(const Duration(days: 1));
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.day == date2.day
        && date1.month == date2.month
        && date1.year == date2.year;
  }

  static bool isCurrentMonth(DateTime date) {
    var now = DateTime.now();
    return date.month == now.month && date.year == now.year;
  }

  static bool isDayOfMonth(DateTime date, DateTime dayOfMonth) {
    return  date.month == dayOfMonth.month && date.year == dayOfMonth.year;
  }


  
  static int calculateMaxWeeksNumberMonthly(
      DateTime startDate,
      DateTime endDate) {
    
    int monthsNumber = calculateMonthsDifference(startDate, endDate);
    
    List<int> weeksNumbersMonthly = [];


    if (monthsNumber == 0) {
      return calculateWeeksNumber(startDate, endDate);
    } else {
      weeksNumbersMonthly.add(
          calculateWeeksNumber(startDate, getLastDayOfMonth(startDate))
      );

      DateTime firstDateOfMonth = getFirstDayOfMonth(startDate);
      for (int i = 1; i <= monthsNumber - 2; i++) {
        firstDateOfMonth = firstDateOfMonth.add(Duration(days: 31));
        weeksNumbersMonthly.add(
            calculateWeeksNumber(
                firstDateOfMonth,
                getLastDayOfMonth(firstDateOfMonth))
        );
      }

      weeksNumbersMonthly.add(
          calculateWeeksNumber(getFirstDayOfMonth(endDate), endDate)
      );

      weeksNumbersMonthly.sort((a, b) => b.compareTo(a));
      return weeksNumbersMonthly[0];
    }
  }

  static int calculateMonthsDifference(
      DateTime startDate,
      DateTime endDate) {
    var yearsDifference = endDate.year - startDate.year;
    return 12 * yearsDifference
        + endDate.month - startDate.month;
  }
  
  static int calculateWeeksNumber(
      DateTime monthStartDate,
      DateTime monthEndDate) {
    int rowsNumber = 1;

    DateTime currentDay = monthStartDate;
    while (currentDay.isBefore(monthEndDate)) {
      currentDay = currentDay.add(Duration(days: 1));
      if (currentDay.weekday == DateTime.monday) {
        rowsNumber += 1;
      }
    }

    return rowsNumber;
  }
}
