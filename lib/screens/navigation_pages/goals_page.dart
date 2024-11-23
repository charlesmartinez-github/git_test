import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finedger/providers/account_provider.dart';
import 'package:finedger/widgets/graphs.dart';
import 'package:finedger/widgets/list_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/constants.dart';
import '../../services/firebase_auth_services.dart';
import 'dart:math';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final _firebaseServices = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();
  final _goalNameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _savedAmountController = TextEditingController();
  String formatter = DateFormat('E, MMM d').format(DateTime.now());
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;


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
    String? selectedAccount = context.read<AccountProvider>().selectedAccount;
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
                          return addGoalModal(screenHeight, context);
                        },
                      );
                    },
                    child: const Text('+ add new'),
                  )
                ],
              ),
              GoalChart(firebaseServices: _firebaseServices, selectedAccount: selectedAccount),
              GoalsListWidget(
                firebaseServices: _firebaseServices,
                selectedAccount: selectedAccount!,
                screenHeight: MediaQuery.of(context).size.height,
                showButtons: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ClipRRect addGoalModal(double screenHeight, BuildContext context) {
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
                        onPressed: () async {
                          // Validate the form fields
                          if (_formKey.currentState!.validate()) {
                            // Check if the start and end dates are properly selected
                            if (selectedStartDate == null) {
                              // Show an error if the start date is not selected
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please select a start date for the goal.")),
                              );
                              return;
                            }

                            if (selectedEndDate == null) {
                              // Show an error if the end date is not selected
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please select an end date for the goal.")),
                              );
                              return;
                            }

                            // Try to parse the target amount
                            double amount;
                            String amountText = _targetAmountController.text.replaceAll(",", "");
                            try {
                              amount = double.parse(amountText);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please enter a valid target amount.")),
                              );
                              return;
                            }

                            // If everything is valid, proceed to add the goal
                            int budgetStartDate = selectedStartDate!.millisecondsSinceEpoch;
                            int budgetEndDate = selectedEndDate!.millisecondsSinceEpoch;

                            await _firebaseServices.addGoal(
                                context, _goalNameController.text, budgetStartDate, budgetEndDate, amount);

                            // Clear the form fields after successful addition
                            clearFormFields();

                            // Show a success dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Goal Added Successfully!'),
                                  content: const Text(
                                    'Congratulations on taking the first step towards your goal! Keep up the great work.',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                        Navigator.of(context).pop(); // Close the add goal modal
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
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
