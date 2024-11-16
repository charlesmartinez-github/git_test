import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finedger/screens/navigation_pages/change_password_page.dart';
import 'package:finedger/screens/navigation_pages/dashboard_page.dart';
import 'package:finedger/screens/navigation_pages/profile_settings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../constants/constants.dart';
import '../../services/firebase_auth_services.dart';
import '../getting_started/login_page.dart';

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
  final _addFundsController = TextEditingController();
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
                                                hintStyle: const TextStyle(
                                                    color: kGrayColor, fontWeight: FontWeight.w300, fontSize: 15.0),
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    borderSide: const BorderSide(color: kGrayColor)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    borderSide: const BorderSide(color: kGrayColor)),
                                                border: const OutlineInputBorder(),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
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
                                                hintStyle: const TextStyle(
                                                    color: kGrayColor, fontWeight: FontWeight.w300, fontSize: 15.0),
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    borderSide: const BorderSide(color: kGrayColor)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    borderSide: const BorderSide(color: kGrayColor)),
                                                border: const OutlineInputBorder(),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
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
                                                hintStyle: const TextStyle(
                                                    color: kGrayColor, fontWeight: FontWeight.w300, fontSize: 15.0),
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    borderSide: const BorderSide(color: kGrayColor)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    borderSide: const BorderSide(color: kGrayColor)),
                                                border: const OutlineInputBorder(),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
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
                                                hintStyle: const TextStyle(
                                                    color: kGrayColor, fontWeight: FontWeight.w300, fontSize: 15.0),
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    borderSide: const BorderSide(color: kGrayColor)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    borderSide: const BorderSide(color: kGrayColor)),
                                                border: const OutlineInputBorder(),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
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
                                                double amount =
                                                    double.parse(_targetAmountController.text.replaceAll(",", ""));
                                                if (_formKey.currentState!.validate()) {
                                                  _firebaseServices.addGoal(
                                                      _goalNameController.text, budgetStartDate, budgetEndDate, amount);
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
                        },
                      );
                    },
                    child: const Text('+ add new'),
                  )
                ],
              ),
              FutureBuilder<List<DocumentSnapshot>>(
                  future: _firebaseServices.getUserGoals(),
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

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Card(
                                child: Column(
                                  children: [
                                    ListTile(
                                      isThreeLine: true,
                                      title: Text(goalData['description'] ?? 'No description'),
                                      subtitle: Text(
                                          'Saved: ${goalData['amountSaved']} \nTarget Amount: ${goalData['targetAmount']}'),
                                      trailing: IconButton(
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return ClipRRect(
                                                  child: SizedBox(
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
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.w400, fontSize: 17.0),
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
                                                                    hintStyle: const TextStyle(
                                                                        color: kGrayColor,
                                                                        fontWeight: FontWeight.w300,
                                                                        fontSize: 15.0),
                                                                    enabledBorder: OutlineInputBorder(
                                                                        borderRadius: BorderRadius.circular(10.0),
                                                                        borderSide: const BorderSide(color: kGrayColor)),
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderRadius: BorderRadius.circular(10.0),
                                                                        borderSide: const BorderSide(color: kGrayColor)),
                                                                    border: const OutlineInputBorder(),
                                                                    contentPadding: const EdgeInsets.symmetric(
                                                                        vertical: 10.0, horizontal: 10.0),
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
                                                                    double amount =
                                                                    double.parse(_addFundsController.text.replaceAll(",", ""));
                                                                    _firebaseServices.addGoalFunds(goalId, amount);
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
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          icon: const Icon(FontAwesomeIcons.plus)),
                                    ),
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
      // appBar: AppBar(
      //   forceMaterialTransparency: true,
      //   title: Text(formatter),
      //   centerTitle: true,
      //   actions: <Widget>[
      //     IconButton(
      //       onPressed: () {},
      //       icon: const Icon(FontAwesomeIcons.comment),
      //     ),
      //     IconButton(
      //       onPressed: () {},
      //       icon: const Icon(FontAwesomeIcons.bell),
      //     ),
      //   ],
      // ),
      // drawer: Drawer(
      //   backgroundColor: Colors.white,
      //   child: ListView(
      //     padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
      //     children: [
      //       const DrawerHeader(
      //         child: Text('header'),
      //       ),
      //       Container(
      //         padding: const EdgeInsets.symmetric(horizontal: 8),
      //         decoration: BoxDecoration(
      //           color: const Color(0xFFfbfcfb),
      //           border: Border.all(color: Colors.grey),
      //           borderRadius: const BorderRadius.all(
      //             Radius.circular(10),
      //           ),
      //         ),
      //         child: ListTile(
      //           dense: true,
      //           leading: const Icon(
      //             FontAwesomeIcons.user,
      //             size: 16,
      //           ),
      //           title: const Text('Profile & Settings'),
      //           onTap: () {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (BuildContext context) {
      //                   return const ProfileSettings();
      //                 },
      //               ),
      //             );
      //           },
      //         ),
      //       ),
      //       SizedBox(height: screenHeight * 0.007),
      //       Container(
      //         padding: const EdgeInsets.symmetric(horizontal: 8),
      //         decoration: BoxDecoration(
      //           color: const Color(0xFFfbfcfb),
      //           border: Border.all(color: Colors.grey),
      //           borderRadius: const BorderRadius.all(
      //             Radius.circular(10),
      //           ),
      //         ),
      //         child: ListTile(
      //           dense: true,
      //           leading: const Icon(
      //             FontAwesomeIcons.coins,
      //             size: 16,
      //           ),
      //           title: const Text('Manage Expenses'),
      //           onTap: () {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (BuildContext context) {
      //                   return const ProfileSettings();
      //                 },
      //               ),
      //             );
      //           },
      //         ),
      //       ),
      //       SizedBox(height: screenHeight * 0.007),
      //       Container(
      //         padding: const EdgeInsets.symmetric(horizontal: 8),
      //         decoration: BoxDecoration(
      //           color: const Color(0xFFfbfcfb),
      //           border: Border.all(color: Colors.grey),
      //           borderRadius: const BorderRadius.all(
      //             Radius.circular(10),
      //           ),
      //         ),
      //         child: ListTile(
      //           dense: true,
      //           leading: const Icon(
      //             FontAwesomeIcons.moneyBills,
      //             size: 16,
      //           ),
      //           title: const Text('Manage Budget'),
      //           onTap: () {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (BuildContext context) {
      //                   return const ProfileSettings();
      //                 },
      //               ),
      //             );
      //           },
      //         ),
      //       ),
      //       SizedBox(height: screenHeight * 0.007),
      //       Container(
      //         padding: const EdgeInsets.symmetric(horizontal: 8),
      //         decoration: BoxDecoration(
      //           color: const Color(0xFFfbfcfb),
      //           border: Border.all(color: Colors.grey),
      //           borderRadius: const BorderRadius.all(
      //             Radius.circular(10),
      //           ),
      //         ),
      //         child: ListTile(
      //           dense: true,
      //           leading: const Icon(
      //             FontAwesomeIcons.piggyBank,
      //             size: 16,
      //           ),
      //           title: const Text('Manage Goals'),
      //           onTap: () {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (BuildContext context) {
      //                   return const GoalsPage();
      //                 },
      //               ),
      //             );
      //           },
      //         ),
      //       ),
      //       SizedBox(height: screenHeight * 0.007),
      //       Container(
      //         padding: const EdgeInsets.symmetric(horizontal: 8),
      //         decoration: BoxDecoration(
      //           color: const Color(0xFFfbfcfb),
      //           border: Border.all(color: Colors.grey),
      //           borderRadius: const BorderRadius.all(
      //             Radius.circular(10),
      //           ),
      //         ),
      //         child: ListTile(
      //           dense: true,
      //           leading: const Icon(
      //             FontAwesomeIcons.squarePollVertical,
      //             size: 16,
      //           ),
      //           title: const Text('Dashboard'),
      //           onTap: () {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (BuildContext context) {
      //                   return const DashboardPage();
      //                 },
      //               ),
      //             );
      //           },
      //         ),
      //       ),
      //       SizedBox(height: screenHeight * 0.007),
      //       Container(
      //         padding: const EdgeInsets.symmetric(horizontal: 8),
      //         decoration: BoxDecoration(
      //           color: const Color(0xFFfbfcfb),
      //           border: Border.all(color: Colors.grey),
      //           borderRadius: const BorderRadius.all(
      //             Radius.circular(10),
      //           ),
      //         ),
      //         child: ListTile(
      //           dense: true,
      //           leading: const Icon(
      //             FontAwesomeIcons.unlock,
      //             size: 16,
      //           ),
      //           title: const Text('Change Password'),
      //           onTap: () {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (BuildContext context) {
      //                   return const ChangePasswordPage();
      //                 },
      //               ),
      //             );
      //           },
      //         ),
      //       ),
      //       SizedBox(height: screenHeight * 0.007),
      //       Container(
      //         padding: const EdgeInsets.symmetric(horizontal: 8),
      //         decoration: BoxDecoration(
      //           color: const Color(0xFFfbfcfb),
      //           border: Border.all(color: Colors.grey),
      //           borderRadius: const BorderRadius.all(
      //             Radius.circular(10),
      //           ),
      //         ),
      //         child: ListTile(
      //           dense: true,
      //           leading: const Icon(
      //             FontAwesomeIcons.arrowRightFromBracket,
      //             size: 16,
      //           ),
      //           title: const Text('Sign out'),
      //           onTap: () {
      //             _firebaseServices.signOut();
      //             Navigator.pushReplacement(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (BuildContext context) {
      //                   return const LoginPage();
      //                 },
      //               ),
      //             );
      //           },
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
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
