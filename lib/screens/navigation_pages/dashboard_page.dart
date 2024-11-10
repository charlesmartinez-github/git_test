import 'package:finedger/constants/constants.dart';
import 'package:finedger/screens/getting_started/login_page.dart';
import 'package:finedger/screens/navigation_pages/articles_page.dart';
import 'package:finedger/screens/navigation_pages/budget_page.dart';
import 'package:finedger/screens/navigation_pages/expenses_page.dart';
import 'package:finedger/screens/navigation_pages/goals_page.dart';
import 'package:finedger/screens/navigation_pages/profile_settings.dart';
import 'package:finedger/services/firebase_auth_services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _firebaseServices = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();
  final _expenseNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _selectedDateController = TextEditingController();
  final _amountController = TextEditingController();
  String formatter = DateFormat('E, MMM d').format(DateTime.now());
  String? selectedValue;
  DateTime? selectedDate;
  final _dropDownItems = [
    'Not on the budget',
    'Food',
    'Transportation',
    'Nails',
  ];
  void clearFormFields() {
    // Clear the form fields
    _expenseNameController.clear();
    _categoryController.clear();
    _selectedDateController.clear();
    _amountController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _expenseNameController.dispose();
    _amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    TextEditingController date = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                          'Add new expenses',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 17.0),
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
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Expenses name',
                                            style: TextStyle(
                                                color: kGrayColor,
                                                fontSize: 15.0),
                                          ),
                                          const SizedBox(height: 3.0),
                                          SizedBox(
                                            height: 40.0,
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "This field is required";
                                                }
                                                return null;
                                              },
                                              controller:
                                                  _expenseNameController,
                                              decoration: InputDecoration(
                                                hintText: 'Description',
                                                hintStyle: const TextStyle(
                                                    color: kGrayColor,
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 15.0),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        borderSide:
                                                            const BorderSide(
                                                                color:
                                                                    kGrayColor)),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        borderSide:
                                                            const BorderSide(
                                                                color:
                                                                    kGrayColor)),
                                                border:
                                                    const OutlineInputBorder(),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6.0),
                                          const Text(
                                            'Categories',
                                            style: TextStyle(
                                                color: kGrayColor,
                                                fontSize: 15.0),
                                          ),
                                          const SizedBox(height: 3.0),
                                          Container(
                                            height: 40.0,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              border: Border.all(
                                                  color:
                                                      kGrayColor), // Your custom border color
                                            ),
                                            child: DropdownButtonFormField(
                                              validator: (value) {
                                                if (value == null) {
                                                  return "This field is required";
                                                }
                                                return null;
                                              },
                                              hint: const Text(
                                                'Select category',
                                                style: TextStyle(
                                                    color: kGrayColor,
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 15.0),
                                              ),
                                              icon: const Visibility(
                                                  visible: false,
                                                  child: Icon(
                                                      Icons.arrow_downward)),
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 10.0),
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                              ),
                                              isExpanded: true,
                                              items: _dropDownItems
                                                  .map((String item) {
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
                                            style: TextStyle(
                                                color: kGrayColor,
                                                fontSize: 15.0),
                                          ),
                                          const SizedBox(height: 3.0),
                                          SizedBox(
                                            height: 40.0,
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "This field is required";
                                                }
                                                return null;
                                              },
                                              controller:
                                                  _selectedDateController,
                                              readOnly: true,
                                              decoration: InputDecoration(
                                                suffixIcon: const Icon(
                                                  Icons.calendar_month_outlined,
                                                  color: kGrayColor,
                                                ),
                                                hintText: 'Date',
                                                hintStyle: const TextStyle(
                                                    color: kGrayColor,
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 15.0),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        borderSide:
                                                            const BorderSide(
                                                                color:
                                                                    kGrayColor)),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        borderSide:
                                                            const BorderSide(
                                                                color:
                                                                    kGrayColor)),
                                                border:
                                                    const OutlineInputBorder(),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                              onTap: () async {
                                                selectedDate =
                                                    await _selectDate();
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 6.0),
                                          const Text(
                                            'Select an icon',
                                            style: TextStyle(
                                                color: kGrayColor,
                                                fontSize: 15.0),
                                          ),
                                          const SizedBox(height: 3.0),
                                          SizedBox(
                                            height: 40.0,
                                            child: TextFormField(
                                              // validator: (value) {
                                              //   if (value == null ||
                                              //       value.isEmpty) {
                                              //     return "This field is required";
                                              //   }
                                              //   return null;
                                              // },
                                              decoration: InputDecoration(
                                                hintText: 'Icon',
                                                hintStyle: const TextStyle(
                                                    color: kGrayColor,
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 15.0),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        borderSide:
                                                            const BorderSide(
                                                                color:
                                                                    kGrayColor)),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        borderSide:
                                                            const BorderSide(
                                                                color:
                                                                    kGrayColor)),
                                                border:
                                                    const OutlineInputBorder(),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6.0),
                                          const Text(
                                            'Amount',
                                            style: TextStyle(
                                                color: kGrayColor,
                                                fontSize: 15.0),
                                          ),
                                          const SizedBox(height: 3.0),
                                          SizedBox(
                                            height: 40.0,
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "This field is required";
                                                }
                                                return null;
                                              },
                                              controller: _amountController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                  FontAwesomeIcons.dollarSign,
                                                  color: kGrayColor,
                                                ),
                                                hintText: '00.00',
                                                hintStyle: const TextStyle(
                                                    color: kGrayColor,
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 15.0),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        borderSide:
                                                            const BorderSide(
                                                                color:
                                                                    kGrayColor)),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        borderSide:
                                                            const BorderSide(
                                                                color:
                                                                    kGrayColor)),
                                                border:
                                                    const OutlineInputBorder(),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
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
                                                  borderRadius:
                                                      BorderRadius.circular(11),
                                                ),
                                                backgroundColor: kBlueColor,
                                              ),
                                              onPressed: () {
                                                int expenseDate = selectedDate!
                                                    .millisecondsSinceEpoch;
                                                double amount = double.parse(
                                                    _amountController.text
                                                        .replaceAll(",", ""));
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  _firebaseServices.addExpense(
                                                      amount,
                                                      selectedValue,
                                                      _expenseNameController
                                                          .text,
                                                      expenseDate);
                                                  setState(() {
                                                    selectedValue = null;
                                                  });
                                                  clearFormFields();
                                                  Navigator.pop(context);
                                                }
                                              },
                                              child: const Text(
                                                'Add Expenses',
                                                style: TextStyle(
                                                    color: Colors.white),
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
              GestureDetector(
                onTap: () {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: screenHeight *
                      0.3, // Adjust height for expanded/collapsed state
                  decoration: BoxDecoration(
                    color: const Color(0xFFfbfcfb),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.arrowsRotate,
                        color: kGrayColor,
                      ),
                      SizedBox(height: 15.0),
                      Text(
                        'Your transaction details will be displayed here',
                        style: TextStyle(color: kGrayColor),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 17.0),
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
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Expenses name',
                                          style: TextStyle(
                                              color: kGrayColor,
                                              fontSize: 15.0),
                                        ),
                                        const SizedBox(height: 3.0),
                                        SizedBox(
                                          height: 40.0,
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                              hintText: 'Description',
                                              hintStyle: const TextStyle(
                                                  color: kGrayColor,
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 15.0),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  borderSide: const BorderSide(
                                                      color: kGrayColor)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  borderSide: const BorderSide(
                                                      color: kGrayColor)),
                                              border:
                                                  const OutlineInputBorder(),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 10.0),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6.0),
                                        const Text(
                                          'Expenses date',
                                          style: TextStyle(
                                              color: kGrayColor,
                                              fontSize: 15.0),
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
                                              hintStyle: const TextStyle(
                                                  color: kGrayColor,
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 15.0),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  borderSide: const BorderSide(
                                                      color: kGrayColor)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  borderSide: const BorderSide(
                                                      color: kGrayColor)),
                                              border:
                                                  const OutlineInputBorder(),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 10.0),
                                            ),
                                            onTap: () async {
                                              DateTime? pickeddate =
                                                  await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime(2000),
                                                      lastDate: DateTime(2100));
                                              if (pickeddate != null) {
                                                setState(() {
                                                  date.text =
                                                      DateFormat('EEE, M/ d/ y')
                                                          .format(pickeddate);
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 6.0),
                                        const Text(
                                          'Select an icon',
                                          style: TextStyle(
                                              color: kGrayColor,
                                              fontSize: 15.0),
                                        ),
                                        const SizedBox(height: 3.0),
                                        SizedBox(
                                          height: 40.0,
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                              hintText: 'Icon',
                                              hintStyle: const TextStyle(
                                                  color: kGrayColor,
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 15.0),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  borderSide: const BorderSide(
                                                      color: kGrayColor)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  borderSide: const BorderSide(
                                                      color: kGrayColor)),
                                              border:
                                                  const OutlineInputBorder(),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 10.0),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6.0),
                                        const Text(
                                          'Amount',
                                          style: TextStyle(
                                              color: kGrayColor,
                                              fontSize: 15.0),
                                        ),
                                        const SizedBox(height: 3.0),
                                        SizedBox(
                                          height: 40.0,
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              prefixIcon: const Icon(
                                                FontAwesomeIcons.dollarSign,
                                                color: kGrayColor,
                                              ),
                                              hintText: '00.00',
                                              hintStyle: const TextStyle(
                                                  color: kGrayColor,
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 15.0),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  borderSide: const BorderSide(
                                                      color: kGrayColor)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  borderSide: const BorderSide(
                                                      color: kGrayColor)),
                                              border:
                                                  const OutlineInputBorder(),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 10.0),
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
                                                borderRadius:
                                                    BorderRadius.circular(11),
                                              ),
                                              backgroundColor: kBlueColor,
                                            ),
                                            onPressed: () {},
                                            child: const Text(
                                              'Add Expenses',
                                              style: TextStyle(
                                                  color: Colors.white),
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
                    },
                    child: const Text('+ add new'),
                  )
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: screenHeight *
                      0.3, // Adjust height for expanded/collapsed state
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
                        style: TextStyle(color: kGrayColor),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
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
              GestureDetector(
                onTap: () {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: screenHeight *
                      0.3, // Adjust height for expanded/collapsed state
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
                        style: TextStyle(color: kGrayColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(formatter),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(FontAwesomeIcons.comment),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(FontAwesomeIcons.bell),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
          children: [
            const DrawerHeader(
              child: Text('header'),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFfbfcfb),
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: ListTile(
                dense: true,
                leading: const Icon(
                  FontAwesomeIcons.user,
                  size: 16,
                ),
                title: const Text('Profile & Settings'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const ProfileSettings();
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.007),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFfbfcfb),
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: ListTile(
                dense: true,
                leading: const Icon(
                  FontAwesomeIcons.coins,
                  size: 16,
                ),
                title: const Text('Manage Expenses'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const ProfileSettings();
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.007),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFfbfcfb),
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: ListTile(
                dense: true,
                leading: const Icon(
                  FontAwesomeIcons.moneyBills,
                  size: 16,
                ),
                title: const Text('Manage Budget'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const ProfileSettings();
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.007),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFfbfcfb),
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: ListTile(
                dense: true,
                leading: const Icon(
                  FontAwesomeIcons.piggyBank,
                  size: 16,
                ),
                title: const Text('Manage Goals'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const ProfileSettings();
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.007),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFfbfcfb),
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: ListTile(
                dense: true,
                leading: const Icon(
                  FontAwesomeIcons.squarePollVertical,
                  size: 16,
                ),
                title: const Text('Dashboard'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const ProfileSettings();
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.007),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFfbfcfb),
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: ListTile(
                dense: true,
                leading: const Icon(
                  FontAwesomeIcons.unlock,
                  size: 16,
                ),
                title: const Text('Change Password'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const ProfileSettings();
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.007),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFfbfcfb),
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: ListTile(
                dense: true,
                leading: const Icon(
                  FontAwesomeIcons.arrowRightFromBracket,
                  size: 16,
                ),
                title: const Text('Sign out'),
                onTap: () {
                  _firebaseServices.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const LoginPage();
                      },
                    ),
                  );
                },
              ),
            ),
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
//String formatter = DateFormat('E, MMM d').format(DateTime.now());
