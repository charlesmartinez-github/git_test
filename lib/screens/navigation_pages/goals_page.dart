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
  final _formKey1 = GlobalKey<FormState>();
  final _goalNameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _savedAmountController = TextEditingController();
  final _percentageController = TextEditingController();
  String formatter = DateFormat('E, MMM d').format(DateTime.now());
  bool isPrioritized = false;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  void clearFormFields() {
    _goalNameController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _targetAmountController.clear();
    _savedAmountController.clear();
    _percentageController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _goalNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _targetAmountController.dispose();
    _savedAmountController.dispose();
    _percentageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    String? selectedAccount = context.read<AccountProvider>().selectedAccount;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          String? selectedAccount = context.read<AccountProvider>().selectedAccount;
          if (selectedAccount == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No account selected')),
            );
            return;
          }

          double? currentFunds = await _firebaseServices.getCurrentFunds(selectedAccount);
          if (currentFunds == null || currentFunds <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No funds available to distribute')),
            );
            return;
          }

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              final _percentageController = TextEditingController();
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _percentageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter percentage for prioritized goals (0-100)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        double? percentage = double.tryParse(_percentageController.text);
                        if (percentage == null || percentage < 0 || percentage > 100) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter a valid percentage (0-100)')),
                          );
                          return;
                        }

                        // Fetch goals and distribute funds here
                        await _distributeFunds(selectedAccount, currentFunds, percentage);

                        Navigator.pop(context);
                      },
                      child: const Text('Distribute Funds'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        label: const Text('Add funds to all'),
        icon: const Icon(FontAwesomeIcons.arrowDown),
      ),

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
                    'Funds',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  StreamBuilder<double>(
                    stream: selectedAccount != null ? _firebaseServices.streamFunds(selectedAccount) : null,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData) {
                        return const Text('No funds data available');
                      }
                      double funds = snapshot.data ?? 0.0;
                      return Text('₱${NumberFormat("#,##0.00", "en_US").format(funds)}');
                    },
                  ),
                ],
              ),
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
  Future<void> _distributeFunds(String selectedAccountId, double currentFunds, double prioritizedPercentage) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch goals from Firestore
    QuerySnapshot goalsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccountId)
        .collection('goals')
        .get();

    if (goalsSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No goals found to distribute funds')),
      );
      return;
    }

    // Separate prioritized and non-prioritized goals
    List<DocumentSnapshot> prioritizedGoals = [];
    List<DocumentSnapshot> nonPrioritizedGoals = [];

    for (var doc in goalsSnapshot.docs) {
      if (doc['isPrioritized'] == true) {
        prioritizedGoals.add(doc);
      } else {
        nonPrioritizedGoals.add(doc);
      }
    }

    double prioritizedFunds = currentFunds * (prioritizedPercentage / 100);
    double nonPrioritizedFunds = currentFunds * ((100 - prioritizedPercentage) / 100);

    double prioritizedShare = prioritizedGoals.isNotEmpty ? (prioritizedFunds / prioritizedGoals.length) : 0.0;
    double nonPrioritizedShare = nonPrioritizedGoals.isNotEmpty ? (nonPrioritizedFunds / nonPrioritizedGoals.length) : 0.0;

    // Update each goal with distributed funds
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (var goal in prioritizedGoals) {
      double currentSaved = (goal['amountSaved'] as num?)?.toDouble() ?? 0.0;
      batch.update(goal.reference, {'amountSaved': currentSaved + prioritizedShare});
    }

    for (var goal in nonPrioritizedGoals) {
      double currentSaved = (goal['amountSaved'] as num?)?.toDouble() ?? 0.0;
      batch.update(goal.reference, {'amountSaved': currentSaved + nonPrioritizedShare});
    }

    // Deduct the distributed funds from the selected account
    double totalDeductedFunds = prioritizedFunds + nonPrioritizedFunds;
    batch.update(
      FirebaseFirestore.instance.collection('users').doc(userId).collection('accounts').doc(selectedAccountId),
      {'funds': FieldValue.increment(-totalDeductedFunds)},
    );

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funds distributed successfully!')),
    );
  }

  StatefulBuilder addGoalModal(double screenHeight, BuildContext context) {
    bool isPrioritizedLocal = isPrioritized;
    return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
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
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Make this budget a priority?'),
                          FittedBox(
                            fit: BoxFit.fill,
                            child: Switch(
                              activeTrackColor: kBlueColor,
                              value: isPrioritizedLocal,
                              onChanged: (bool newValue) {
                                setModalState(() {
                                  isPrioritizedLocal = newValue; // Update the local state
                                });
                                setState(() {
                                  isPrioritized = newValue; // Update the global state
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
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

                              await _firebaseServices.addGoal(context, _goalNameController.text, budgetStartDate,
                                  budgetEndDate, amount, isPrioritized);

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
    });
  }

  Future<DateTime?> _selectDate(TextEditingController dateController) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      dateController.text = DateFormat('MMMM d, y').format(picked);
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
