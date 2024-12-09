import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finedger/constants/constants.dart';
import 'package:finedger/providers/account_provider.dart';
import 'package:finedger/services/firebase_auth_services.dart';
import 'package:finedger/widgets/graphs.dart';
import 'package:finedger/widgets/list_display.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  late TextEditingController _budgetNameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _amountController = TextEditingController();
  final _predefinedCategoriesController = TextEditingController();
  bool repeating = false;
  DateTime? _selectedStartDateBudget;
  DateTime? _selectedEndDateBudget;
  List<String> predefinedCategories = [
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
    _predefinedCategoriesController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _budgetNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _amountController.dispose();
    _predefinedCategoriesController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    String? selectedAccount = context.watch<AccountProvider>().selectedAccount;
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
                          String? selectedAccount = context.watch<AccountProvider>().selectedAccount;
                          return addBudgetModal(screenHeight, context, selectedAccount);
                        },
                      );
                    },
                    child: const Text('+ add new'),
                  )
                ],
              ),
              const Text(
                'Summary',
                style: TextStyle(fontSize: 16.0),
              ),
              BudgetChart(
                firebaseServices: _firebaseServices,
                selectedAccount: context.watch<AccountProvider>().selectedAccount,
              ),
              const SizedBox(height: 10.0),
              BudgetListWidget(firebaseServices: _firebaseServices, selectedAccount: selectedAccount),
            ],
          ),
        ),
      ),
    );
  }

  ClipRRect addBudgetModal(double screenHeight, BuildContext context, String? selectedAccount) {
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
                    clearFormFields();
                  },
                ),
              ],
            ),
            Form(
              key: _formKey,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text(
                    'Select budget',
                    style: TextStyle(color: kGrayColor, fontSize: 15.0),
                  ),
                  const SizedBox(height: 3.0),
                  DropdownMenu<String>(
                    inputDecorationTheme: InputDecorationTheme(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      constraints: BoxConstraints.tight(const Size.fromHeight(42)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    width: double.infinity,
                    initialSelection: 'Set budget name',
                    controller: _predefinedCategoriesController,
                    requestFocusOnTap: true,
                    hintText: 'Budget Name',
                    onSelected: (String? value) {
                      setState(() {
                        if (value != null) {
                          _budgetNameController.text = value; // Set the selected value to the budgetNameController
                        }
                      });
                    },
                    dropdownMenuEntries: predefinedCategories.map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry<String>(
                        value: value,
                        label: value,
                      );
                    }).toList(),
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
                            borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: kGrayColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: kGrayColor)),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Set start date as today and end date 7 days after
                            _selectedStartDateBudget = DateTime.now();
                            _selectedEndDateBudget = _selectedStartDateBudget!.add(const Duration(days: 7));
                            _startDateController.text = DateFormat('MMMM d, y').format(_selectedStartDateBudget!);
                            _endDateController.text = DateFormat('MMMM d, y').format(_selectedEndDateBudget!);
                          });
                        },
                        child: const Text('7 Days'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Set start date as the 1st of the current month and end date 15 days after
                            _selectedStartDateBudget = DateTime(DateTime.now().year, DateTime.now().month, 1);
                            _selectedEndDateBudget = _selectedStartDateBudget!.add(const Duration(days: 15));
                            _startDateController.text = DateFormat('MMMM d, y').format(_selectedStartDateBudget!);
                            _endDateController.text = DateFormat('MMMM d, y').format(_selectedEndDateBudget!);
                          });
                        },
                        child: const Text('15 Days'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Set start date as the 1st of the current month and end date as the last day of the current month
                            _selectedStartDateBudget = DateTime(DateTime.now().year, DateTime.now().month, 1);
                            _selectedEndDateBudget = DateTime(
                              DateTime.now().year,
                              DateTime.now().month + 1,
                              0,
                            );
                            _startDateController.text = DateFormat('MMMM d, y').format(_selectedStartDateBudget!);
                            _endDateController.text = DateFormat('MMMM d, y').format(_selectedEndDateBudget!);
                          });
                        },
                        child: const Text('1 month'),
                      ),
                    ],
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
                            borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: kGrayColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: kGrayColor)),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      ),
                      onTap: () async {
                        _selectedStartDateBudget = await _selectDateBudget(_startDateController, DateType.start);
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
                            borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: kGrayColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: kGrayColor)),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      ),
                      onTap: () async {
                        _selectedEndDateBudget = await _selectDateBudget(_endDateController, DateType.end);
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
                            borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: kGrayColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: kGrayColor)),
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
                          if (_selectedStartDateBudget == null) {
                            // Show an error if the start date is not selected
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please select a start date for the budget.")),
                            );
                            return;
                          }

                          if (_selectedEndDateBudget == null) {
                            // Show an error if the end date is not selected
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please select an end date for the budget.")),
                            );
                            return;
                          }

                          // Try to parse the target amount
                          double amount;
                          String amountText = _amountController.text.replaceAll(",", "");
                          try {
                            amount = double.parse(amountText);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please enter a valid target amount.")),
                            );
                            return;
                          }

                          // If everything is valid, proceed to add the budget
                          String newCategory = _budgetNameController.text;
                          int budgetStartDate = _selectedStartDateBudget!.millisecondsSinceEpoch;
                          int budgetEndDate = _selectedEndDateBudget!.millisecondsSinceEpoch;

                          // Call addBudget and check if it was successful
                          bool isSuccess = await _firebaseServices.addBudget(
                              context, selectedAccount!, newCategory, budgetStartDate, budgetEndDate, amount);

                          if (isSuccess) {
                            // Add the new item using the callback
                            widget.onAddItems!(newCategory);

                            // Clear the form fields after successful addition
                            clearFormFields();

                            // Show a success snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Budget added successfully! Great job staying on track!'),
                                duration: Duration(seconds: 3),
                              ),
                            );

                            // Close the add budget modal
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Text(
                        'Create budget',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _selectDateBudget(TextEditingController dateController, DateType dateType) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = dateType == DateType.start ? DateTime(2000) : DateTime.now().add(const Duration(days: 1));
    DateTime lastDate = dateType == DateType.start ? DateTime.now() : DateTime(2100);

    // Ensure initialDate is not before firstDate to avoid assertion error
    if (dateType == DateType.end) {
      initialDate = firstDate;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      dateController.text = DateFormat('MMMM d, y').format(picked);
      return picked;
    }
    return null;
  }
}

enum DateType { start, end }

class ChartData {
  final String description;
  final double spentAmount;
  final double budgetAmount;
  final bool isMaxed;
  final Color color;

  ChartData(this.description, this.spentAmount, this.budgetAmount, this.color)
      : isMaxed = (spentAmount / budgetAmount) * 100 >= 100;
}
