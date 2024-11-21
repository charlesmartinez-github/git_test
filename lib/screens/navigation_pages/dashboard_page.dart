import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finedger/constants/constants.dart';
import 'package:finedger/providers/account_provider.dart';
import 'package:finedger/providers/page_provider.dart';
import 'package:finedger/screens/navigation_pages/initial_account_creation.dart';
import 'package:finedger/screens/navigation_pages/navigation.dart';
import 'package:finedger/services/firebase_auth_services.dart';
import 'package:finedger/widgets/graphs.dart';
import 'package:finedger/widgets/list_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:finedger/models/time_frame.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _firebaseServices = FirebaseAuthService();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _formKeyAccount = GlobalKey<FormState>();
  final _formKeyFund = GlobalKey<FormState>();
  final _expenseNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _selectedDateController = TextEditingController();
  final _amountController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _fundAmountController = TextEditingController();
  String formatter = DateFormat('E, MMM d').format(DateTime.now());
  TextEditingController date = TextEditingController();
  String? selectedValue;
  int selectedIndex = 0;

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

  DateTime? selectedDate;
  List<String> accountList = [];
  final _dropDownItems = [
    'Not on the budget',
    'Food',
    'Transportation',
    'Nails',
  ];

  Stream<List<Map<String, String>>> streamAccounts() {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return _db.collection('users').doc(userId).collection('accounts').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'accountId': doc.id,
          'accountName': doc['accountName'] as String,
        };
      }).toList();
    });
  }

  void clearFormFields() {
    _expenseNameController.clear();
    _categoryController.clear();
    _selectedDateController.clear();
    _amountController.clear();
    _accountNameController.clear();
    _fundAmountController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _accountNameController.dispose();
    _fundAmountController.dispose();
  }

  @override
  void initState() {
    super.initState();
    streamAccounts();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    String? selectedAccount = context.watch<AccountProvider>().selectedAccount;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: constraints.maxHeight * 0.02,
                  horizontal: constraints.maxWidth * 0.05,
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(child: Text('Account:')),
                        Expanded(
                          flex: 2,
                          child: StreamBuilder<List<Map<String, String>>>(
                            stream: streamAccounts(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              if (snapshot.hasError) {
                                return const Text('Error occurred');
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Text('No accounts found');
                              }

                              // Ensure that there's always a valid account selected before rendering the dropdown
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (context.read<AccountProvider>().selectedAccount == null &&
                                    snapshot.data!.isNotEmpty) {
                                  context
                                      .read<AccountProvider>()
                                      .setSelectedAccount(snapshot.data!.first['accountId']!);
                                }
                              });

                              // Get the current selected account value
                              String? selectedAccount = context.watch<AccountProvider>().selectedAccount;

                              // If no account is selected yet, return an empty container temporarily
                              if (selectedAccount == null) {
                                return const SizedBox
                                    .shrink(); // Returning an empty widget until `selectedAccount` is updated
                              }

                              // Create dropdown items from the account data
                              List<DropdownMenuItem<String>> dropdownItems = snapshot.data!.map((account) {
                                return DropdownMenuItem<String>(
                                  value: account['accountId'],
                                  child: Text(account['accountName']!),
                                );
                              }).toList();

                              return DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedAccount,
                                  hint: const Text('Select an Account'),
                                  items: dropdownItems,
                                  onChanged: (String? newValue) {
                                    context.read<AccountProvider>().setSelectedAccount(newValue!);
                                  },
                                  isExpanded: true,
                                ),
                              );
                            },
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showAddAccountBottomSheet(context, constraints.maxHeight),
                          child: const Text('add account'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text('Funds'),
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
                            return Text('₱${funds.toStringAsFixed(2)}');
                          },
                        ),
                        TextButton(
                          onPressed: () => _showAddFundsBottomSheet(context, constraints.maxHeight),
                          child: const Text('add funds'),
                        ),
                      ],
                    ),
                    Card(
                      elevation: 3,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: const BorderSide(
                          color: Colors.blue,
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text(
                                  'Expenses',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // showModalBottomSheet<dynamic>(
                                    //   isScrollControlled: true,
                                    //   context: context,
                                    //   builder: (BuildContext context) {
                                    //     return _buildBottomSheet(context, constraints.maxHeight);
                                    //   },
                                    // );
                                  },
                                  child: const Text('+ add new'),
                                )
                              ],
                            ),
                            selectedAccount != null && selectedAccount.isNotEmpty
                                ? ExpenseChart(
                                    stream: _firebaseServices.expenseData(selectedAccount),
                                    selectedTimeframe: selectedTimeframe,
                                  )
                                : const Center(
                                    child: Text('Please select an account to view expenses'),
                                  ),
                            const SizedBox(height: 10.0),
                            selectedAccount != null && selectedAccount.isNotEmpty
                                ? ExpenseListWidget(
                                    firebaseServices: _firebaseServices,
                                    selectedAccount: selectedAccount,
                                    showLatestOnly: true,
                                  )
                                : const Center(
                                    child: Text('Please select an account to view expenses'),
                                  ),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  context.read<PageProvider>().setCurrentPageIndex(3);
                                },
                                child: const Text('View All'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.03),
                    Card(
                      elevation: 3,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: const BorderSide(
                          color: Colors.blue,
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text(
                                  'Budget',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                TextButton(
                                  onPressed: () => _showAddBudgetBottomSheet(context, constraints.maxHeight),
                                  child: const Text('+ add new'),
                                )
                              ],
                            ),
                            selectedAccount != null && selectedAccount.isNotEmpty
                                ? BudgetChart(firebaseServices: _firebaseServices, selectedAccount: selectedAccount)
                                : const Center(
                                    child: Text('Please select an account to view budgets'),
                                  ),
                            const SizedBox(height: 10.0),
                            selectedAccount != null && selectedAccount.isNotEmpty
                                ? BudgetListWidget(
                                    firebaseServices: _firebaseServices,
                                    selectedAccount: selectedAccount,
                                    showLatestOnly: true)
                                : const Center(
                                    child: Text('Please select an account to view budgets'),
                                  ),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  context.read<PageProvider>().setCurrentPageIndex(1);
                                },
                                child: const Text('View All'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.03),
                    Card(
                      elevation: 3,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: const BorderSide(
                          color: Colors.blue,
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text(
                                  'Goals',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('+ add new'),
                                )
                              ],
                            ),
                            selectedAccount != null && selectedAccount.isNotEmpty
                                ? GoalChart(firebaseServices: _firebaseServices, selectedAccount: selectedAccount)
                                : const Center(
                                    child: Text('Please select an account to view goals'),
                                  ),
                            const SizedBox(height: 10.0),
                            selectedAccount != null && selectedAccount.isNotEmpty
                                ? GoalsListWidget(
                                    firebaseServices: _firebaseServices,
                                    selectedAccount: selectedAccount,
                                    showLatestOnly: true,
                                    screenHeight: screenHeight,
                                    showButtons: false,
                                  )
                                : const Center(
                                    child: Text('Please select an account to view goals'),
                                  ),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  context.read<PageProvider>().setCurrentPageIndex(2);
                                },
                                child: const Text('View All'),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddFundsBottomSheet(BuildContext context, double screenHeight) {
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
                        'Add funds',
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.xmark,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Form(
                  key: _formKeyFund,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Amount',
                          style: TextStyle(color: Colors.grey, fontSize: 15.0),
                        ),
                        const SizedBox(height: 3.0),
                        SizedBox(
                          height: 40.0,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "This field is required";
                              }
                              return null;
                            },
                            controller: _fundAmountController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                FontAwesomeIcons.pesoSign,
                                color: Colors.grey,
                              ),
                              hintText: 'enter amount',
                              hintStyle:
                                  const TextStyle(color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 15.0),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Colors.grey)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Colors.grey)),
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
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () {
                              if (_formKeyFund.currentState!.validate()) {
                                double amount = double.parse(_fundAmountController.text.replaceAll(",", ""));
                                final selectedAccount = context.read<AccountProvider>().selectedAccount;
                                if (selectedAccount != null) {
                                  _firebaseServices.addAccountFunds(selectedAccount, amount);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Funds added')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please select an account first')),
                                  );
                                }
                                _fundAmountController.clear();
                                Navigator.pop(context);
                              }
                            },
                            child: const Text(
                              'Add funds',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  void _showAddAccountBottomSheet(BuildContext context, double screenHeight) {
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
                        'Add an account',
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.xmark,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Form(
                  key: _formKeyAccount,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Account name',
                          style: TextStyle(color: Colors.grey, fontSize: 15.0),
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
                            controller: _accountNameController,
                            decoration: InputDecoration(
                              hintText: 'Description',
                              hintStyle:
                                  const TextStyle(color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 15.0),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Colors.grey)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Colors.grey)),
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
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () {
                              if (_formKeyAccount.currentState!.validate()) {
                                _firebaseServices.createInitialAccount(context, _accountNameController.text);
                                _accountNameController.clear();
                                Navigator.pop(context);
                              }
                            },
                            child: const Text(
                              'Create account',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddBudgetBottomSheet(BuildContext context, double screenHeight) {
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
                        'Add new budget',
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
                        'Expenses date',
                        style: TextStyle(color: kGrayColor, fontSize: 15.0),
                      ),
                      const SizedBox(height: 3.0),
                      SizedBox(
                        height: 40.0,
                        child: TextFormField(
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
                            DateTime? pickeddate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100));
                            if (pickeddate != null) {
                              setState(() {
                                date.text = DateFormat('EEE, M/ d/ y').format(pickeddate);
                              });
                            }
                          },
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
                          onPressed: () {},
                          child: const Text(
                            'Add Expenses',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
