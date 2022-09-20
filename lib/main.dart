
import 'package:demo_calendar/calendarro/calendarro.dart';
import 'package:demo_calendar/calendarro/date_utils.dart';
import 'package:flutter/material.dart' hide DateUtils;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Calendarro Demo',
      theme: new ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: new MyHomePage(title: 'Calendarro Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var startDate = DateUtils.getFirstDayOfNextMonth();
    var endDate = DateUtils.getLastDayOfNextMonth();
    final monthCalendarro = Calendarro(
        startDate: startDate,
        endDate: endDate,
        displayMode: DisplayMode.MONTHS,
        selectionMode: SelectionMode.MULTI,
        weekdayLabelsRow: CustomWeekdayLabelsRow(),
        onTap: (date) {
          print("onTap: $date");
        });
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: Column(
        children: <Widget>[
          Container(height: 32.0),
          monthCalendarro
        ],
      ),
    );
  }
}

class CustomWeekdayLabelsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        Expanded(child: Text("M", textAlign: TextAlign.center)),
        Expanded(child: Text("T", textAlign: TextAlign.center)),
        Expanded(child: Text("W", textAlign: TextAlign.center)),
        Expanded(child: Text("T", textAlign: TextAlign.center)),
        Expanded(child: Text("F", textAlign: TextAlign.center)),
        Expanded(child: Text("S", textAlign: TextAlign.center)),
        Expanded(child: Text("S", textAlign: TextAlign.center)),
      ],
    );
  }
}