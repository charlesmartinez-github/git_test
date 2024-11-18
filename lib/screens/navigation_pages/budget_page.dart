import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finedger/constants/constants.dart';
import 'package:finedger/services/firebase_auth_services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import 'package:syncfusion_flutter_gauges/gauges.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key, this.onAddItems});

  final Function(String)? onAddItems;

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _firebaseServices = FirebaseAuthService();
  String formatter = DateFormat('E, MMM d').format(DateTime.now());
  String monthFormatter = DateFormat('MMMM').format(DateTime.now());
  final _formKey = GlobalKey<FormState>();
  final _budgetNameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _amountController = TextEditingController();
  bool repeating = false;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  List<String> predefineCategories = [
    'Food',
    'Electric',
    'Transportation',
    'Gas',
    'Water',
    'Clothes',
    'Wifi',
  ];

  void clearFormFields() {
    _budgetNameController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _amountController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _budgetNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Budget',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet<dynamic>(
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return budgetModal(screenHeight, context);
                        },
                      );
                    },
                    child: const Text('+ add new'),
                  )
                ],
              ),
              Text(
                '$monthFormatter Summary',
                style: const TextStyle(fontSize: 16.0),
              ),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _firebaseServices.getUserBudgets(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No budget data available');
                  }

                  List<ChartData> chartData = snapshot.data!.map((doc) {
                    double spentAmount = (doc['spentAmount'] ?? 0).toDouble();
                    double budgetAmount = (doc['amount'] ?? 1).toDouble(); // Avoid division by zero
                    int colorValue = (doc['color'] ?? kBlueColor);
                    Color progressColor = Color(colorValue);
                    return ChartData(doc['description'] ?? 'No Description', spentAmount, budgetAmount, progressColor);
                  }).toList();

                  return charts.SfCircularChart(
                    legend: charts.Legend(
                      isVisible: true,
                      overflowMode: charts.LegendItemOverflowMode.wrap,
                    ),
                    series: <charts.CircularSeries<ChartData, String>>[
                      charts.RadialBarSeries<ChartData, String>(
                        cornerStyle: charts.CornerStyle.bothCurve,
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
                          textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                            double percentage = (data.spentAmount / data.budgetAmount) * 100;
                            return Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold),);
                          },
                        ),
                        maximumValue: 100, // Set to 100 to ensure full-circle capability
                        radius: '100%',
                        innerRadius: '30%', // Adjust this for visual clarity if needed
                      ),
                    ],
                  );

                },
              ),
              const SizedBox(height: 10.0),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _firebaseServices.getUserBudgets(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No budget found"));
                  } else {
                    final budgets = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: budgets.length,
                      itemBuilder: (context, index) {
                        final budget = budgets[index];
                        final String description = budget['description'] ?? 'No description';
                        final double spentAmount = budget['spentAmount']?.toDouble() ?? 0.0;
                        final double amount = budget['amount']?.toDouble() ?? 1.0; // Avoid division by zero
                        final double progressPercentage = (spentAmount / amount) * 100;
                        int colorValue = budget['color'] ?? kBlueColor;
                        Color progressColor = Color(colorValue);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            color: Colors.white,
                            elevation: 4.0,
                            shadowColor: progressColor,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ListTile(
                                    isThreeLine: true,
                                    leading: CircleAvatar(child: Text(description[0])),
                                    title: Text(description),
                                    subtitle: Text(
                                      'Spending: ₱${spentAmount.toStringAsFixed(2)}\nBudget: ₱${amount.toStringAsFixed(2)}',
                                    ),
                                  ),
                                  Row(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    // mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                        child: gauges.SfLinearGauge(
                                          minimum: 0,
                                          maximum: amount,
                                          showTicks: false,
                                          showLabels: false,
                                          axisTrackStyle: gauges.LinearAxisTrackStyle(
                                            edgeStyle: gauges.LinearEdgeStyle.bothCurve,
                                            thickness: 8,
                                            color: Colors.grey[300],
                                          ),
                                          barPointers: [
                                            gauges.LinearBarPointer(
                                              value: spentAmount,
                                              color: progressColor, // Use a soft red similar to your example
                                              thickness: 8, // Thickness similar to your example
                                              edgeStyle: gauges.LinearEdgeStyle.bothCurve, // Makes the bar look smooth
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 5.0),
                                      Text(
                                        '${progressPercentage.toStringAsFixed(1)}%',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                                      )
                                    ],
                                  ),
                                  // SizedBox(height: 5),
                                  // Text(
                                  //   'Progress: ${progressPercentage.toStringAsFixed(1)}%',
                                  //   style: TextStyle(fontWeight: FontWeight.bold),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  ClipRRect budgetModal(double screenHeight, BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(40.0),
        topRight: Radius.circular(40.0),
      ),
      child: SizedBox(
        height: screenHeight * 0.8,
        width: double.infinity,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Opacity(
                  opacity: 0.0,
                  child: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: null,
                  ),
                ),
                const Flexible(
                  child: Text(
                    'Add a budget',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.xmark,
                    color: kGrayColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            Form(
              key: _formKey,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Budget name',
                      style: TextStyle(color: kGrayColor, fontSize: 15.0),
                    ),
                    const SizedBox(height: 3.0),
                    SizedBox(
                      height: 40.0,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "This field is required";
                          }
                          return null;
                        },
                        controller: _budgetNameController,
                        decoration: InputDecoration(
                          hintText: 'Description',
                          hintStyle: const TextStyle(color: kGrayColor, fontWeight: FontWeight.w300, fontSize: 15.0),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: kGrayColor)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: kGrayColor)),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                    // ListView.builder(
                    //     shrinkWrap: true,
                    //     itemCount: predefineCategories.length,
                    //     itemBuilder: (context, index) {
                    //       final category = predefineCategories[index];
                    //       return Expanded(
                    //         child: ElevatedButton(
                    //             onPressed: (){},
                    //             child: Text(category)
                    //         ),
                    //       );
                    //     }),
                    const SizedBox(height: 6.0),
                    const Text(
                      'Start date',
                      style: TextStyle(color: kGrayColor, fontSize: 15.0),
                    ),
                    const SizedBox(height: 3.0),
                    SizedBox(
                      height: 40.0,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "This field is required";
                          }
                          return null;
                        },
                        controller: _startDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          suffixIcon: const Icon(
                            Icons.calendar_month_outlined,
                            color: kGrayColor,
                          ),
                          hintText: 'Set the date',
                          hintStyle: const TextStyle(color: kGrayColor, fontWeight: FontWeight.w300, fontSize: 15.0),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: kGrayColor)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: kGrayColor)),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        ),
                        onTap: () async {
                          selectedStartDate = await _selectDate(_startDateController);
                        },
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    const Text(
                      'End date',
                      style: TextStyle(color: kGrayColor, fontSize: 15.0),
                    ),
                    const SizedBox(height: 3.0),
                    SizedBox(
                      height: 40.0,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "This field is required";
                          }
                          return null;
                        },
                        controller: _endDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          suffixIcon: const Icon(
                            Icons.calendar_month_outlined,
                            color: kGrayColor,
                          ),
                          hintText: 'Set the deadline',
                          hintStyle: const TextStyle(color: kGrayColor, fontWeight: FontWeight.w300, fontSize: 15.0),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: kGrayColor)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: kGrayColor)),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        ),
                        onTap: () async {
                          selectedEndDate = await _selectDate(_endDateController);
                        },
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    const Text(
                      'Amount',
                      style: TextStyle(color: kGrayColor, fontSize: 15.0),
                    ),
                    const SizedBox(height: 3.0),
                    SizedBox(
                      height: 40.0,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "This field is required";
                          }
                          return null;
                        },
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            FontAwesomeIcons.pesoSign,
                            color: kGrayColor,
                          ),
                          hintText: '00.00',
                          hintStyle: const TextStyle(color: kGrayColor, fontWeight: FontWeight.w300, fontSize: 15.0),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: kGrayColor)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: kGrayColor)),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                    // const SizedBox(height: 3.0),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: <Widget>[
                    //     Text(
                    //         'Repeating',
                    //         style: TextStyle(color: kGrayColor, fontSize: 15.0)
                    //     ),
                    //     Switch(
                    //         activeColor: kBlueColor,
                    //         value: repeating,
                    //         onChanged: (bool newValue) {
                    //           setState(() {
                    //             repeating = newValue;
                    //           });
                    //         },
                    //       thumbColor: WidgetStatePropertyAll(kGrayColor),
                    //     )
                    //   ],
                    // ),
                    const SizedBox(height: 13.0),
                    SizedBox(
                      width: double.infinity,
                      height: 45.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                          backgroundColor: kBlueColor,
                        ),
                        onPressed: () {
                          String newCategory = _budgetNameController.text;
                          int budgetStartDate = selectedStartDate!.millisecondsSinceEpoch;
                          int budgetEndDate = selectedEndDate!.millisecondsSinceEpoch;
                          double amount = double.parse(_amountController.text.replaceAll(",", ""));
                          if (_formKey.currentState!.validate()) {
                            widget.onAddItems!(newCategory);
                            _firebaseServices.addBudget(
                                context, _budgetNameController.text, budgetStartDate, budgetEndDate, amount);
                            clearFormFields();
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          'Create budget',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _selectDate(TextEditingController dateController) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      dateController.text = DateFormat('MMMM d').format(picked);
      return picked;
    }
    return null;
  }
}

class ChartData {
  final String description;
  final double spentAmount;
  final double budgetAmount;
  final Color color;

  ChartData(this.description, this.spentAmount, this.budgetAmount, this.color);
}
