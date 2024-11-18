import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finedger/providers/account_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../constants/constants.dart';
import '../../services/firebase_auth_services.dart';

class ExpensesPage extends StatefulWidget {
  final List<String>? budgetCategories;
  const ExpensesPage({super.key, this.budgetCategories});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final _firebaseServices = FirebaseAuthService();
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _expenseNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _selectedDateController = TextEditingController();
  final _amountController = TextEditingController();
  String formatter = DateFormat('E, MMM d').format(DateTime.now());
  String monthFormatter = DateFormat('MMMM').format(DateTime.now());
  String? selectedValue;
  DateTime? selectedDate;
  List<String> budgetDescriptions = [];
  List<DataPoint> _chartData = [];
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    fetchBudgetDescriptions(context);
  }

  Future<void> fetchBudgetDescriptions(BuildContext context) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String? selectedAccount = context.read<AccountProvider>().selectedAccount;

    if (selectedAccount == null) {
      throw Exception('No account selected');
    }

    // Fetch descriptions from the Firestore budgets collection for the selected account
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('budgets')
        .get();

    // Extract descriptions and add them to the list, excluding budgets where spentAmount equals amount
    setState(() {
      budgetDescriptions = snapshot.docs
          .where((doc) => doc['spentAmount'] != doc['amount'])
          .map((doc) => doc['description'] as String)
          .toList();
    });
  }

  void onTimeFrameSelected(int index) {
    setState(() {
      selectedIndex = index;

      // Update the selectedTimeframe enum accordingly
      switch (index) {
        case 0:
          selectedTimeframe = TimeFrame.sevenDays;
          break;
        case 1:
          selectedTimeframe = TimeFrame.thirtyDays;
          break;
        case 2:
          selectedTimeframe = TimeFrame.sixMonths;
          break;
      }
    });
  }

  void clearFormFields() {
    _expenseNameController.clear();
    _categoryController.clear();
    _selectedDateController.clear();
    _amountController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _expenseNameController.dispose();
    _categoryController.dispose();
    _selectedDateController.dispose();
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
                    'Expenses',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  Builder(
                    builder: (context) {
                      return TextButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          showModalBottomSheet<dynamic>(
                            isScrollControlled: true,
                            context: context,
                            builder: (BuildContext context) {
                              return FocusScope(child: expenseModal(screenHeight, context));
                            },
                          );
                        },
                        child: const Text('+ add new'),
                      );
                    },
                  )
                ],
              ),
              // Text(
              //   '$monthFormatter Spending',
              //   style: const TextStyle(fontSize: 16.0),
              // ),
              StreamBuilder<QuerySnapshot>(
                key: UniqueKey(),
                stream: _firebaseServices.expenseData(context),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  Map<DateTime, double> aggregatedData = {};

                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;

                    int dateValue = data['date'] ?? 0; // Default to 0 if date is null
                    double amountValue = data['amount'] ?? 0; // Default to 0 if amount is null

                    if (dateValue != 0) {
                      DateTime date = DateTime.fromMillisecondsSinceEpoch(dateValue);

                      // Normalize to just the date part (ignoring time) to group all expenses by day
                      DateTime dateOnly = DateTime(date.year, date.month, date.day);

                      if (aggregatedData.containsKey(dateOnly)) {
                        aggregatedData[dateOnly] = aggregatedData[dateOnly]! + amountValue;
                      } else {
                        aggregatedData[dateOnly] = amountValue;
                      }
                    }
                  }

                  DateTime now = DateTime.now();
                  DateTime filterStartDate =
                      now.subtract(const Duration(days: 30)); // Default value, e.g., last 30 days
                  int interval;
                  DateTimeIntervalType intervalType;
                  DateFormat dateFormat;

                  switch (selectedTimeframe) {
                    case TimeFrame.sevenDays:
                      interval = 1;
                      intervalType = DateTimeIntervalType.days;
                      filterStartDate = now.subtract(const Duration(days: 7));
                      dateFormat = DateFormat.yMd();
                      break;
                    case TimeFrame.thirtyDays:
                      interval = 5;
                      intervalType = DateTimeIntervalType.days;
                      filterStartDate = now.subtract(const Duration(days: 30));
                      dateFormat = DateFormat.yMd();
                      break;
                    case TimeFrame.sixMonths:
                      interval = 1;
                      intervalType = DateTimeIntervalType.months;
                      filterStartDate = now.subtract(const Duration(days: 180));
                      dateFormat = DateFormat.Md();
                      break;
                  }

                  Map<DateTime, double> filteredData =
                      Map.fromEntries(aggregatedData.entries.where((entry) => entry.key.isAfter(filterStartDate)));

                  _chartData = filteredData.entries.map((entry) {
                    return DataPoint(entry.key, entry.value);
                  }).toList();

                  _chartData.sort((a, b) => a.date.compareTo(b.date));

                  DateTime minimumDate = filterStartDate;
                  DateTime maximumDate = now; // Always set the maximum date to now

                  double maxYValue = _chartData.isNotEmpty
                      ? _chartData.map((data) => data.value).reduce((a, b) => a > b ? a : b)
                      : 0.0;

// Set the number format based on the max Y-axis value, with a peso sign
                  NumberFormat yAxisNumberFormat;
                  if (maxYValue >= 1000) {
                    yAxisNumberFormat = NumberFormat.compactCurrency(
                      symbol: '₱',
                      decimalDigits: 1, // Customize decimal places if needed
                    );
                  } else {
                    yAxisNumberFormat = NumberFormat.currency(
                      symbol: '₱',
                      decimalDigits: 0, // No decimal places for smaller values
                    );
                  }

                  return SizedBox(
                    height: screenHeight * 0.3,
                    child: SfCartesianChart(
                      key: UniqueKey(),
                      primaryXAxis: DateTimeAxis(
                        name: 'Date',
                        minimum: minimumDate,
                        maximum: maximumDate,
                        interval: interval.toDouble(),
                        intervalType: intervalType,
                        dateFormat: DateFormat.MMMd(),
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                      ),
                      primaryYAxis: NumericAxis(
                        numberFormat: yAxisNumberFormat,
                        maximum: maxYValue,
                        name: 'Amount',
                        minimum: 0,
                      ),
                      series: <CartesianSeries<DataPoint, DateTime>>[
                        AreaSeries<DataPoint, DateTime>(
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
                          markerSettings: const MarkerSettings(
                            isVisible: true,
                            shape: DataMarkerType.circle,
                            width: 7,
                            height: 7,
                            color: kBlueColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // Button for 7 Days
                  // Button for 7 Days
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () => onTimeFrameSelected(0),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: selectedIndex == 0 ? Colors.blue.shade100 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(color: selectedIndex == 0 ? Colors.white : Colors.grey.shade300),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(
                          '7 days',
                          style: TextStyle(
                            color: selectedIndex == 0 ? Colors.white : Colors.black,
                            fontWeight: selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Button for 30 Days
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () => onTimeFrameSelected(1),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: selectedIndex == 1 ? Colors.blue.shade100 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(color: selectedIndex == 1 ? Colors.white : Colors.grey.shade300),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(
                          '30 days',
                          style: TextStyle(
                            color: selectedIndex == 1 ? Colors.white : Colors.black,
                            fontWeight: selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Button for 6 Months
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () => onTimeFrameSelected(2),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: selectedIndex == 2 ? Colors.blue.shade100 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(color: selectedIndex == 2 ? Colors.white : Colors.grey.shade300),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(
                          '6 months',
                          style: TextStyle(
                            color: selectedIndex == 2 ? Colors.white : Colors.black,
                            fontWeight: selectedIndex == 2 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _firebaseServices.getUserExpenses(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: LinearProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No expense found"));
                    } else {
                      final expenses = snapshot.data!;
                      return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(expense['date']);
                            String expenseDate = DateFormat('MMMM d').format(dateTime);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Card(
                                child: ListTile(
                                  // tileColor: const Color(0xFFfbfcfb),
                                  // shape: RoundedRectangleBorder(
                                  //     borderRadius: BorderRadius.circular(10.0),
                                  //     side: const BorderSide(
                                  //         color: Color(0xFFcbcbcb))),
                                  leading: CircleAvatar(child: Text(expense['description'][0])),
                                  title: Text(expense['description'] ?? 'No Description'),
                                  subtitle: Text(
                                    '${expense['category'] ?? 'No category'}, $expenseDate',
                                    style: const TextStyle(fontSize: 12.0, color: kGrayColor),
                                  ),
                                  trailing: Text(
                                    'P${expense['amount'].toString()}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                            );
                          });
                    }
                  }),
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
      //             FontAwesomeIcons.squarePollVertical,
      //             size: 16,
      //           ),
      //           title: const Text('Dashboard'),
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
      //             FontAwesomeIcons.unlock,
      //             size: 16,
      //           ),
      //           title: const Text('Change Password'),
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

  ClipRRect expenseModal(double screenHeight, BuildContext context) {
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
                    'Add an expense',
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
                      'Expenses name',
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
                        controller: _expenseNameController,
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
                      'Categories',
                      style: TextStyle(color: kGrayColor, fontSize: 15.0),
                    ),
                    const SizedBox(height: 3.0),
                    Container(
                      height: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: kGrayColor), // Your custom border color
                      ),
                      child: DropdownButtonFormField(
                        validator: (value) {
                          if (value == null) {
                            return "This field is required / add a budget first";
                          }
                          return null;
                        },
                        hint: const Text(
                          'Select category',
                          style: TextStyle(color: kGrayColor, fontWeight: FontWeight.w300, fontSize: 15.0),
                        ),
                        icon: const Visibility(visible: false, child: Icon(Icons.arrow_downward)),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        isExpanded: true,
                        items: budgetDescriptions.map((String item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            selectedValue = value!;
                          });
                        },
                        value: selectedValue,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    const Text(
                      'Expenses date',
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
                        controller: _selectedDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          suffixIcon: const Icon(
                            Icons.calendar_month_outlined,
                            color: kGrayColor,
                          ),
                          hintText: 'Date',
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
                          selectedDate = await _selectDate();
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
                          int expenseDate = selectedDate!.millisecondsSinceEpoch;
                          double amount = double.parse(_amountController.text.replaceAll(",", ""));
                          if (_formKey.currentState!.validate()) {
                            _firebaseServices.addExpense(
                                context, amount, selectedValue, _expenseNameController.text, expenseDate);
                            setState(() {
                              selectedValue = null;
                            });
                            clearFormFields();
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          'Create expense',
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

  Future<DateTime?> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      _selectedDateController.text = DateFormat('MMMM d').format(picked);
      return picked;
    }
    return null;
  }
}

class DataPoint {
  final DateTime date;
  final double value;

  DataPoint(this.date, this.value);
}

enum TimeFrame { sevenDays, thirtyDays, sixMonths }

TimeFrame selectedTimeframe = TimeFrame.sevenDays;
