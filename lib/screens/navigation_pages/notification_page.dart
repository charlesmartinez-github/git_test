import 'package:finedger/constants/constants.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.sizeOf(context).height;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('General Notification'),
                SizedBox(
                  height: 28.0,
                  width: 60.0,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      activeTrackColor: kLightBlueColor,
                      value: isChecked,
                      onChanged: (bool newValue) {
                        setState(() {
                          isChecked = newValue;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Sound'),
                SizedBox(
                  height: 28.0,
                  width: 60.0,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      activeTrackColor: kLightBlueColor,
                      value: isChecked,
                      onChanged: (bool newValue) {
                        setState(() {
                          isChecked = newValue;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Vibrate'),
                SizedBox(
                  height: 28.0,
                  width: 60.0,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      activeTrackColor: kLightBlueColor,
                      value: isChecked,
                      onChanged: (bool newValue) {
                        setState(() {
                          isChecked = newValue;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
            const Divider(
              color: kGrayColor,
            ),
            const Text(
              'System & Services update',
              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('App updates'),
                SizedBox(
                  height: 28.0,
                  width: 60.0,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      activeTrackColor: kLightBlueColor,
                      value: isChecked,
                      onChanged: (bool newValue) {
                        setState(() {
                          isChecked = newValue;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Budget reminder'),
                SizedBox(
                  height: 28.0,
                  width: 60.0,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      activeTrackColor: kLightBlueColor,
                      value: isChecked,
                      onChanged: (bool newValue) {
                        setState(() {
                          isChecked = newValue;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Expense reminder'),
                SizedBox(
                  height: 28.0,
                  width: 60.0,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      activeTrackColor: kLightBlueColor,
                      value: isChecked,
                      onChanged: (bool newValue) {
                        setState(() {
                          isChecked = newValue;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Goals reminder'),
                SizedBox(
                  height: 28.0,
                  width: 60.0,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      activeTrackColor: kLightBlueColor,
                      value: isChecked,
                      onChanged: (bool newValue) {
                        setState(() {
                          isChecked = newValue;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
            const Divider(
              color: kGrayColor,
            ),
            const Text(
              'Others',
              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('New Service Available'),
                SizedBox(
                  height: 28.0,
                  width: 60.0,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      activeTrackColor: kLightBlueColor,
                      value: isChecked,
                      onChanged: (bool newValue) {
                        setState(() {
                          isChecked = newValue;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('New Tips Available'),
                SizedBox(
                  height: 28.0,
                  width: 60.0,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      activeTrackColor: kLightBlueColor,
                      value: isChecked,
                      onChanged: (bool newValue) {
                        setState(() {
                          isChecked = newValue;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
