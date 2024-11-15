import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Dynamic Range Chart'),
        ),
        body: ChartPage(),
      ),
    );
  }
}

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  DateRange _selectedRange = DateRange.sevenDays;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedRange = DateRange.sevenDays;
                });
              },
              child: Text('7 Days'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedRange = DateRange.thirtyDays;
                });
              },
              child: Text('30 Days'),
            ),
          ],
        ),
        Expanded(
          child: SfCartesianChart(
            primaryXAxis: DateTimeAxis(
              name: 'Date',
              minimum: _selectedRange == DateRange.sevenDays
                  ? DateTime.now().subtract(Duration(days: 7))
                  : DateTime.now().subtract(Duration(days: 30)),
              maximum: DateTime.now(),
            ),
            series: <LineSeries<DataPoint, DateTime>>[
              LineSeries<DataPoint, DateTime>(
                name: 'Balance',
                dataSource: _getData(),
                xValueMapper: (DataPoint data, _) => data.date,
                yValueMapper: (DataPoint data, _) => data.value,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<DataPoint> _getData() {
    // Replace with your real data.
    return [
      DataPoint(DateTime.now().subtract(Duration(days: 30)), 300),
      DataPoint(DateTime.now().subtract(Duration(days: 20)), 3500),
      DataPoint(DateTime.now().subtract(Duration(days: 10)), 1000),
      DataPoint(DateTime.now().subtract(Duration(days: 5)), 2000),
      DataPoint(DateTime.now(), 1500),
    ];
  }
}

class DataPoint {
  final DateTime date;
  final int value;

  DataPoint(this.date, this.value);
}

enum DateRange { sevenDays, thirtyDays }
