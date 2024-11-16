// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Dynamic Range Chart'),
//         ),
//         body: ChartPage(),
//       ),
//     );
//   }
// }
//
// class ChartPage extends StatefulWidget {
//   @override
//   _ChartPageState createState() => _ChartPageState();
// }
//
// class _ChartPageState extends State<ChartPage> {
//   DateRange _selectedRange = DateRange.sevenDays;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _selectedRange = DateRange.sevenDays;
//                 });
//               },
//               child: Text('7 Days'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _selectedRange = DateRange.thirtyDays;
//                 });
//               },
//               child: Text('30 Days'),
//             ),
//           ],
//         ),
//         Expanded(
//           child: SfCartesianChart(
//             primaryXAxis: DateTimeAxis(
//               name: 'Date',
//               minimum: _selectedRange == DateRange.sevenDays
//                   ? DateTime.now().subtract(Duration(days: 7))
//                   : DateTime.now().subtract(Duration(days: 30)),
//               maximum: DateTime.now(),
//             ),
//             series: <LineSeries<DataPoint, DateTime>>[
//               LineSeries<DataPoint, DateTime>(
//                 name: 'Balance',
//                 dataSource: _getData(),
//                 xValueMapper: (DataPoint data, _) => data.date,
//                 yValueMapper: (DataPoint data, _) => data.value,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   List<DataPoint> _getData() {
//     // Replace with your real data.
//     return [
//       DataPoint(DateTime.now().subtract(Duration(days: 30)), 300),
//       DataPoint(DateTime.now().subtract(Duration(days: 20)), 3500),
//       DataPoint(DateTime.now().subtract(Duration(days: 10)), 1000),
//       DataPoint(DateTime.now().subtract(Duration(days: 5)), 2000),
//       DataPoint(DateTime.now(), 1500),
//     ];
//   }
// }
//
// class DataPoint {
//   final DateTime date;
//   final int value;
//
//   DataPoint(this.date, this.value);
// }
//
// enum DateRange { sevenDays, thirtyDays }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AccountDetailsWidget extends StatefulWidget {
  @override
  _AccountDetailsWidgetState createState() => _AccountDetailsWidgetState();
}

class _AccountDetailsWidgetState extends State<AccountDetailsWidget> {
  String? selectedAccount;
  final List<String> accountList = [];
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _fundsController = TextEditingController();
  final GlobalKey<FormState> _formKeyAccount = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyFund = GlobalKey<FormState>();
  final _firebaseServices = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Account:'),
                StreamBuilder<List<String>>(
                  stream: streamAccounts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No accounts found');
                    }

                    // Update the account list and handle default selection
                    accountList.clear();
                    accountList.addAll(snapshot.data!);
                    if (selectedAccount == null && accountList.isNotEmpty) {
                      selectedAccount = accountList.first; // Set the default selection
                    }

                    return DropdownButton<String>(
                      value: selectedAccount,
                      items: accountList.map((account) {
                        return DropdownMenuItem(
                          value: account,
                          child: Text(account),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedAccount = value!;
                        });
                      },
                    );
                  },
                ),
                TextButton(
                  onPressed: () => _showAddAccountBottomSheet(context, screenHeight),
                  child: const Text('add account'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Funds'),
                TextButton(
                  onPressed: () => _showAddFundsBottomSheet(context, screenHeight),
                  child: const Text('add funds'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Stream<List<String>> streamAccounts() async* {
    var snapshot = await _firebaseServices.collection('accounts').get();
    yield snapshot.docs.map((doc) => doc['accountName'] as String).toList();
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
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 15.0),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Colors.grey)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Colors.grey)),
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
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () {
                              if (_formKeyAccount.currentState!.validate()) {
                                _firebaseServices
                                    .collection('accounts')
                                    .add({'accountName': _accountNameController.text});
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "This field is required";
                              }
                              return null;
                            },
                            controller: _fundsController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                FontAwesomeIcons.pesoSign,
                                color: Colors.grey,
                              ),
                              hintText: 'enter amount',
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 15.0),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Colors.grey)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Colors.grey)),
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
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () {
                              if (_formKeyFund.currentState!.validate()) {
                                _firebaseServices
                                    .collection('accounts')
                                    .doc(selectedAccount)
                                    .update({'funds': _fundsController.text});
                                _fundsController.clear();
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
}
