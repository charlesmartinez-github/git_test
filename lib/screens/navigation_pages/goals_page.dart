import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finedger/providers/account_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import '../../constants/constants.dart';
import '../../services/firebase_auth_services.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import 'dart:math';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final _firebaseServices = FirebaseAuthService();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _goalNameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _savedAmountController = TextEditingController();
  final _addFundsController = TextEditingController();
  String formatter = DateFormat('E, MMM d').format(DateTime.now());
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  Stream<List<GoalData>> getUserGoals(BuildContext context) {
    String userId = _auth.currentUser!.uid;
    String? selectedAccount = context.read<AccountProvider>().selectedAccount;

    if (selectedAccount == null) {
      throw Exception('No account selected');
    }
    return _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('goals')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return GoalData(
          description: data['description'] ?? 'No description',
          targetAmount: (data['targetAmount'] ?? 1.0).toDouble(), // Default to avoid division by zero
          savedAmount: (data['amountSaved'] ?? 0.0).toDouble(),
          color: Color(data['color'] ?? Colors.grey.value),
        );
      }).toList();
    });
  }

  void clearFormFields() {
    _goalNameController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _targetAmountController.clear();
    _savedAmountController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _goalNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _targetAmountController.dispose();
    _savedAmountController.dispose();
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
                    'Goals',
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
              StreamBuilder<List<GoalData>>(
                stream: getUserGoals(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No goals available.'));
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
                    title: charts.ChartTitle(text: 'Goals Progress'),
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
                        dataLabelSettings: charts.DataLabelSettings(
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
              ),
              StreamBuilder<List<DocumentSnapshot>>(
                  stream: _firebaseServices.getUserGoals(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: LinearProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("Create a goal"));
                    } else {
                      final goals = snapshot.data!;

                      return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: goals.length,
                          itemBuilder: (context, index) {
                            final goal = goals[index];
                            final goalId = goal.id; // Document ID for the goal
                            final goalData = goal.data() as Map<String, dynamic>;
                            DateTime startDate = DateTime.fromMillisecondsSinceEpoch(goal['startDate']);
                            DateTime endDate = DateTime.fromMillisecondsSinceEpoch(goal['endDate']);
                            String textStartDate = DateFormat('MMMM d, y').format(startDate);
                            String textEndDate = DateFormat('MMMM d, y').format(endDate);
                            double savedAmount = goal['amountSaved'] ?? 0.0;
                            double targetAmount = goal['targetAmount'] ?? 1.0;
                            double progress = (savedAmount / targetAmount) * 100;
                            int colorValue =
                                goalData['color'] ?? kBlueColor; // Retrieve stored color or default to teal
                            Color progressColor = Color(colorValue);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Card(
                                color: Colors.white,
                                elevation: 4.0,
                                shadowColor: progressColor,
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      leading: SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: gauges.SfRadialGauge(
                                          axes: <gauges.RadialAxis>[
                                            gauges.RadialAxis(
                                              minimum: 0,
                                              maximum: 100,
                                              startAngle: 270,
                                              endAngle: 270,
                                              showLabels: false,
                                              showTicks: false,
                                              axisLineStyle: gauges.AxisLineStyle(
                                                thickness: 0.15,
                                                color: Colors.grey[300]!,
                                                thicknessUnit: gauges.GaugeSizeUnit.factor,
                                              ),
                                              pointers: <gauges.GaugePointer>[
                                                gauges.RangePointer(
                                                  value: progress.clamp(0, 100),
                                                  width: 0.15,
                                                  sizeUnit: gauges.GaugeSizeUnit.factor,
                                                  color: progressColor,
                                                  enableAnimation: true,
                                                )
                                              ],
                                              annotations: <gauges.GaugeAnnotation>[
                                                gauges.GaugeAnnotation(
                                                  widget: Text(
                                                    "${progress.toStringAsFixed(0)}%",
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  angle: 90,
                                                  positionFactor: 0.1,
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      isThreeLine: true,
                                      title: Text(goalData['description'] ?? 'No description'),
                                      subtitle: Text(
                                          'Saved: ₱${goalData['amountSaved']} \nTarget Amount: ₱${goalData['targetAmount']}'),
                                      trailing: IconButton(
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return ClipRRect(
                                                  child: addFundsModal(screenHeight, context, goalId),
                                                );
                                              },
                                            );
                                          },
                                          icon: const Icon(FontAwesomeIcons.plus)),
                                    ),
                                    Divider(),
                                    ListTile(
                                      dense: true,
                                      subtitle: Text('Start Date: $textStartDate \nEnd Date: $textEndDate'),
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  SizedBox addFundsModal(double screenHeight, BuildContext context, String goalId) {
    return SizedBox(
      height: screenHeight * 0.8,
      width: double.infinity,
      child: Column(
        children: <Widget>[
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
                  'Add funds to your goal',
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
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 40.0,
                  child: TextFormField(
                    key: _formKey1,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This field is required";
                      }
                      return null;
                    },
                    controller: _addFundsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        FontAwesomeIcons.pesoSign,
                        color: kGrayColor,
                      ),
                      hintText: '00.00',
                      hintStyle: const TextStyle(color: kGrayColor, fontWeight: FontWeight.w300, fontSize: 15.0),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: kGrayColor)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: kGrayColor)),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
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
                      double amount = double.parse(_addFundsController.text.replaceAll(",", ""));
                      _firebaseServices.addGoalFunds(context, goalId, amount);
                      _addFundsController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Add funds',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
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
                    'Add a goal',
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
                      'Goal name',
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
                        controller: _goalNameController,
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
                      'Target Amount',
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
                        controller: _targetAmountController,
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
                          int budgetStartDate = selectedStartDate!.millisecondsSinceEpoch;
                          int budgetEndDate = selectedEndDate!.millisecondsSinceEpoch;
                          double amount = double.parse(_targetAmountController.text.replaceAll(",", ""));
                          if (_formKey.currentState!.validate()) {
                            _firebaseServices.addGoal(
                                context, _goalNameController.text, budgetStartDate, budgetEndDate, amount);
                            clearFormFields();
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          'Create goal',
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

Color generateRandomColor() {
  Random random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(256), // R value (0-255)
    random.nextInt(256), // G value (0-255)
    random.nextInt(256), // B value (0-255)
  );
}

class GoalData {
  final String description;
  final double targetAmount;
  final double savedAmount;
  final Color color;

  GoalData({
    required this.description,
    required this.targetAmount,
    required this.savedAmount,
    required this.color,
  });
}

class GoalChartData {
  final String description;
  final double amount;
  final Color color;
  final bool isSaved;

  GoalChartData(this.description, this.amount, this.color, this.isSaved);
}
