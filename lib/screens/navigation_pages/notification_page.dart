import 'package:finedger/constants/constants.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Map to manage the state of each switch
  Map<String, bool> switchStates = {
    'generalNotification': false,
    'sound': false,
    'vibrate': false,
    'appUpdates': false,
    'budgetReminder': false,
    'expenseReminder': false,
    'goalsReminder': false,
    'newService': false,
    'newTips': false,
  };

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('Notification'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: screenWidth * 0.08,
          right: screenWidth * 0.08,
          top: screenWidth * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Common',
              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
            ),
            _buildSwitchRow('General Notification', 'generalNotification'),
            _buildSwitchRow('Sound', 'sound'),
            _buildSwitchRow('Vibrate', 'vibrate'),
            const Divider(
              color: kGrayColor,
            ),
            const Text(
              'System & Services update',
              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
            ),
            _buildSwitchRow('App updates', 'appUpdates'),
            _buildSwitchRow('Budget reminder', 'budgetReminder'),
            _buildSwitchRow('Expense reminder', 'expenseReminder'),
            _buildSwitchRow('Goals reminder', 'goalsReminder'),
            const Divider(
              color: kGrayColor,
            ),
            const Text(
              'Others',
              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
            ),
            _buildSwitchRow('New Service Available', 'newService'),
            _buildSwitchRow('New Tips Available', 'newTips'),
          ],
        ),
      ),
    );
  }

  // Helper method to build a switch row
  Widget _buildSwitchRow(String label, String switchKey) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label),
        SizedBox(
          height: 35.0,
          width: 60.0,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Switch(
              activeTrackColor: kLightBlueColor,
              value: switchStates[switchKey] ?? false,
              onChanged: (bool newValue) {
                setState(() {
                  switchStates[switchKey] = newValue;
                });
              },
            ),
          ),
        )
      ],
    );
  }
}
