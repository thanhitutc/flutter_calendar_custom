
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

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var startDate = DateUtils.getFirstDayOfCurrentMonth();
    var endDate = DateUtils.getLastDayOfCurrentMonth();
    final monthCalendarro = Calendar(
        startDate: startDate,
        endDate: endDate,
        onTap: (date) {
          print("onTap: $date");
        });
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        color: Colors.blueGrey,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            // Container(height: 100.0),
            monthCalendarro
          ],
        ),
      ),
    );
  }
}
