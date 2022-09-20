import 'package:flutter/widgets.dart';

class CalendarWeekdayLabelsView extends StatelessWidget {
  const CalendarWeekdayLabelsView({Key? key, required this.height}) : super(key: key);

  final double height;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: const <Widget>[
          Expanded(child: Text("月", textAlign: TextAlign.center)),
          Expanded(child: Text("火", textAlign: TextAlign.center)),
          Expanded(child: Text("水", textAlign: TextAlign.center)),
          Expanded(child: Text("木", textAlign: TextAlign.center)),
          Expanded(child: Text("金", textAlign: TextAlign.center)),
          Expanded(child: Text("土", textAlign: TextAlign.center)),
          Expanded(child: Text("日", textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}