import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finedger/constants/constants.dart';
import 'package:finedger/screens/navigation_pages/budget_page.dart';
import 'package:finedger/screens/navigation_pages/expenses_page.dart';
import 'package:finedger/screens/navigation_pages/goals_page.dart';
import 'package:finedger/services/firebase_auth_services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:finedger/models/time_frame.dart';
import 'dart:ui' as ui;
class ExpenseChart extends StatefulWidget {
  final Stream<QuerySnapshot>? stream; // Stream can now be nullable
  final TimeFrame? selectedTimeframe;

  const ExpenseChart({super.key,
    required this.stream,
    required this.selectedTimeframe,
  });

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  List<DataPoint> _chartData = [];

  @override
  Widget build(BuildContext context) {
    // If the stream or selectedTimeframe is null, return a placeholder
    if (widget.stream == null || widget.selectedTimeframe == null) {
      return const Center(
        child: Text('Please select an account to view the expense chart'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: widget.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('An error occurred'));
        }

        if (snapshot.data!.docs.isEmpty) {
          return GestureDetector(
            onTap: () {},
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 150.0,
              decoration: BoxDecoration(
                color: const Color(0xFFfbfcfb),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(FontAwesomeIcons.pesoSign, color: kGrayColor),
                  SizedBox(height: 15.0),
                  Text(
                    'Your expense details will be displayed here',
                    style: TextStyle(color: kGrayColor, fontSize: 13.0),
                  ),
                ],
              ),
            ),
          );
        }

        // Process snapshot data to update _chartData
        Map<DateTime, double> aggregatedData = {};

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;

          int dateValue = data['date'] ?? 0;
          double amountValue = data['amount'] ?? 0;

          if (dateValue != 0) {
            DateTime date = DateTime.fromMillisecondsSinceEpoch(dateValue);
            DateTime dateOnly = DateTime(date.year, date.month, date.day);

            if (aggregatedData.containsKey(dateOnly)) {
              aggregatedData[dateOnly] = aggregatedData[dateOnly]! + amountValue;
            } else {
              aggregatedData[dateOnly] = amountValue;
            }
          }
        }

        DateTime now = DateTime.now();
        DateTime filterStartDate = now.subtract(const Duration(days: 30));
        int interval;
        charts.DateTimeIntervalType intervalType;
        DateFormat dateFormat;

        switch (widget.selectedTimeframe!) {
          case TimeFrame.sevenDays:
            interval = 1;
            intervalType = charts.DateTimeIntervalType.days;
            filterStartDate = now.subtract(const Duration(days: 7));
            dateFormat = DateFormat.yMd();
            break;
          case TimeFrame.thirtyDays:
            interval = 5;
            intervalType = charts.DateTimeIntervalType.days;
            filterStartDate = now.subtract(const Duration(days: 30));
            dateFormat = DateFormat.yMd();
            break;
          case TimeFrame.sixMonths:
            interval = 1;
            intervalType = charts.DateTimeIntervalType.months;
            filterStartDate = now.subtract(const Duration(days: 180));
            dateFormat = DateFormat.Md();
            break;
        }

        Map<DateTime, double> filteredData = Map.fromEntries(
          aggregatedData.entries.where((entry) => entry.key.isAfter(filterStartDate)),
        );

        _chartData = filteredData.entries.map((entry) {
          return DataPoint(entry.key, entry.value);
        }).toList();

        _chartData.sort((a, b) => a.date.compareTo(b.date));

        DateTime minimumDate = filterStartDate;
        DateTime maximumDate = now;

        double maxYValue = _chartData.isNotEmpty
            ? _chartData.map((data) => data.value).reduce((a, b) => a > b ? a : b)
            : 0.0;

        NumberFormat yAxisNumberFormat;
        if (maxYValue >= 1000) {
          yAxisNumberFormat = NumberFormat.compactCurrency(
            symbol: '₱',
            decimalDigits: 1,
          );
        } else {
          yAxisNumberFormat = NumberFormat.currency(
            symbol: '₱',
            decimalDigits: 0,
          );
        }

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: charts.SfCartesianChart(
            primaryXAxis: charts.DateTimeAxis(
              name: 'Date',
              minimum: minimumDate,
              maximum: maximumDate,
              interval: interval.toDouble(),
              intervalType: intervalType,
              dateFormat: dateFormat,
              edgeLabelPlacement: charts.EdgeLabelPlacement.shift,
            ),
            primaryYAxis: charts.NumericAxis(
              numberFormat: yAxisNumberFormat,
              maximum: maxYValue,
              name: 'Amount',
              minimum: 0,
            ),
            series: <charts.CartesianSeries<DataPoint, DateTime>>[
              charts.AreaSeries<DataPoint, DateTime>(
                color: kGreenColor.withOpacity(0.5),
                name: 'Expenses',
                dataSource: _chartData,
                xValueMapper: (DataPoint data, _) => data.date,
                yValueMapper: (DataPoint data, _) => data.value,
                borderGradient: const LinearGradient(
                  colors: [Colors.blue, Colors.red],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                markerSettings: const charts.MarkerSettings(
                  isVisible: true,
                  shape: charts.DataMarkerType.circle,
                  width: 7,
                  height: 7,
                  color: kBlueColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class BudgetChart extends StatefulWidget {
  const BudgetChart({
    super.key,
    required FirebaseAuthService firebaseServices,
    required this.selectedAccount,
  }) : _firebaseServices = firebaseServices;

  final FirebaseAuthService _firebaseServices;
  final String? selectedAccount; // Nullable selectedAccount

  @override
  State<BudgetChart> createState() => _BudgetChartState();
}

class _BudgetChartState extends State<BudgetChart> {
  @override
  Widget build(BuildContext context) {
    // If selectedAccount is null, show a placeholder message
    if (widget.selectedAccount == null) {
      return const Center(
        child: Text('Please select an account to view the budget chart'),
      );
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: widget._firebaseServices.getUserBudgets(widget.selectedAccount!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return GestureDetector(
            onTap: () {},
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 150.0,
              decoration: BoxDecoration(
                color: const Color(0xFFfbfcfb),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(FontAwesomeIcons.moneyBill, color: kGrayColor),
                  SizedBox(height: 15.0),
                  Text(
                    'Your budget details will be displayed here',
                    style: TextStyle(color: kGrayColor, fontSize: 13.0),
                  ),
                ],
              ),
            ),
          );
        }

        List<ChartData> chartData = snapshot.data!.map((doc) {
          double spentAmount = (doc['spentAmount'] ?? 0).toDouble();
          double budgetAmount = (doc['amount'] ?? 1).toDouble(); // Avoid division by zero
          int colorValue;
          if (doc['color'] is int) {
            colorValue = doc['color'];
          } else if (doc['color'] is Color) {
            colorValue = (doc['color'] as Color).value;
          } else {
            colorValue = kBlueColor.value;
          }
          Color progressColor = Color(colorValue);

          return ChartData(doc['description'] ?? 'No Description', spentAmount, budgetAmount, progressColor);
        }).toList();

        bool allMaxed = chartData.every((data) => (data.spentAmount / data.budgetAmount) * 100 >= 100);

        return charts.SfCircularChart(
          legend: const charts.Legend(
            isVisible: true,
            overflowMode: charts.LegendItemOverflowMode.wrap,
          ),
          series: <charts.CircularSeries<ChartData, String>>[
            charts.RadialBarSeries<ChartData, String>(
              cornerStyle: allMaxed ? charts.CornerStyle.bothFlat : charts.CornerStyle.bothCurve,
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.description,
              yValueMapper: (ChartData data, _) {
                double percentage = (data.spentAmount / data.budgetAmount) * 100;
                return percentage.isNaN ? 0 : percentage; // Handle any potential NaN
              },
              pointColorMapper: (ChartData data, _) => data.color,
              dataLabelSettings: charts.DataLabelSettings(
                isVisible: true,
                labelPosition: charts.ChartDataLabelPosition.outside,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                  double percentage = (data.spentAmount / data.budgetAmount) * 100;
                  return Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold),
                  );
                },
              ),
              maximumValue: 100, // Set to 100 to ensure full-circle capability
              radius: '100%',
              innerRadius: '30%', // Adjust this for visual clarity if needed
            ),
          ],
        );
      },
    );
  }
}

class GoalChart extends StatefulWidget {
  const GoalChart({
    super.key,
    required FirebaseAuthService firebaseServices,
    required this.selectedAccount,
  }) : _firebaseServices = firebaseServices;

  final FirebaseAuthService _firebaseServices;
  final String? selectedAccount;

  @override
  State<GoalChart> createState() => _GoalChartState();
}

class _GoalChartState extends State<GoalChart> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GoalData>>(
      stream: widget._firebaseServices.getUserGoalsChart(widget.selectedAccount),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return GestureDetector(
            onTap: () {},
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 150.0,
              decoration: BoxDecoration(
                color: const Color(0xFFfbfcfb),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(FontAwesomeIcons.piggyBank, color: kGrayColor),
                  SizedBox(height: 15.0),
                  Text(
                    'Your goals details will be displayed here',
                    style: TextStyle(color: kGrayColor, fontSize: 13.0),
                  ),
                ],
              ),
            ),
          );
        }

        final List<GoalChartData> chartData = [];
        for (var goal in snapshot.data!) {
          double savedAmount = goal.savedAmount;
          double remainingAmount = goal.targetAmount - goal.savedAmount;
          remainingAmount = remainingAmount < 0 ? 0 : remainingAmount; // Ensure no negative values

          // Add a single goal segment, consisting of a saved and remaining part
          chartData.add(GoalChartData('${goal.description} (Saved)', savedAmount, goal.color, true));
          chartData.add(GoalChartData('${goal.description} (Remaining)', remainingAmount, Colors.grey[300]!, false));
        }

        return charts.SfCircularChart(
          title: const charts.ChartTitle(text: 'Goals Progress'),
          series: <charts.CircularSeries>[
            charts.DoughnutSeries<GoalChartData, String>(
              dataSource: chartData,
              xValueMapper: (GoalChartData data, _) => data.description,
              yValueMapper: (GoalChartData data, _) => data.amount,
              pointColorMapper: (GoalChartData data, _) => data.color,
              radius: '80%',
              innerRadius: '60%',
              strokeWidth: 2, // Adds a border around each segment
              strokeColor: Colors.white,
              dataLabelSettings: const charts.DataLabelSettings(
                isVisible: true,
                labelPosition: charts.ChartDataLabelPosition.outside,
                connectorLineSettings: charts.ConnectorLineSettings(
                  type: charts.ConnectorType.curve,
                ),
              ),
              dataLabelMapper: (GoalChartData data, _) {
                // Only show labels for the saved part, hide labels for remaining part
                return data.isSaved ? '${data.description}: ${data.amount}' : '';
              },
            ),
          ],
          annotations: <charts.CircularChartAnnotation>[
            charts.CircularChartAnnotation(
              widget: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total Savings',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₱${snapshot.data!.fold(0.0, (sum, goal) => sum + goal.savedAmount).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


