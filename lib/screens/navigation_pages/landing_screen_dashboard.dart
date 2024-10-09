import 'package:finedger/constants/constants.dart';
import 'package:finedger/screens/getting_started/login_page.dart';
import 'package:finedger/screens/navigation_pages/profile_settings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LandingScreenDashboard extends StatefulWidget {
  const LandingScreenDashboard({super.key});

  @override
  State<LandingScreenDashboard> createState() => _LandingScreenDashboardState();
}

class _LandingScreenDashboardState extends State<LandingScreenDashboard> {
  int currentPageIndex = 0;
  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.alwaysShow;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        //backgroundColor: Colors.greenAccent,
        forceMaterialTransparency: true,
        title: const Text('Thu, Nov 19'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              onPressed: () {}, icon: const Icon(FontAwesomeIcons.comment)),
          IconButton(onPressed: () {}, icon: const Icon(FontAwesomeIcons.bell)),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
          children: [
            const DrawerHeader(
              child: Text('Header'),
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return const ProfileSettings();
                  }));
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return const ProfileSettings();
                  }));
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return const ProfileSettings();
                  }));
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return const ProfileSettings();
                  }));
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return const ProfileSettings();
                  }));
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return const ProfileSettings();
                  }));
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return const LoginPage();
                  }));
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: screenHeight * 0.12,
        width: screenWidth,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                      color: Color(0xFFe1e3e6), fontSize: 14);
                } else {
                  return const TextStyle(color: Colors.grey, fontSize: 14);
                }
              },
            ),
            iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(
                      color: Color(0xFFe1e3e6), size: 30);
                } else {
                  return const IconThemeData(color: Colors.grey, size: 24);
                }
              },
            ),
          ),
          child: NavigationBar(
            backgroundColor: kBlueColor,
            indicatorColor: kBlueColor,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            labelBehavior: labelBehavior,
            selectedIndex: currentPageIndex,
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            destinations: const <Widget>[
              NavigationDestination(
                icon: Icon(FontAwesomeIcons.moneyBill1, color: kIconColor),
                label: 'Budget',
              ),
              NavigationDestination(
                  icon: Icon(FontAwesomeIcons.piggyBank, color: kIconColor),
                  label: 'Goals'),
              NavigationDestination(
                  icon: Icon(FontAwesomeIcons.squarePollVertical,
                      color: kIconColor),
                  label: 'Dashboard'),
              NavigationDestination(
                  icon: Icon(FontAwesomeIcons.dollarSign, color: kIconColor),
                  label: 'Expenses'),
              NavigationDestination(
                  icon: Icon(FontAwesomeIcons.graduationCap, color: kIconColor),
                  label: 'Articles'),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
          child: Column(
            children: <Widget>[
              Container(
                //color: Colors.greenAccent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Expenses',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(40.0),
                                topRight: Radius.circular(40.0),
                              ),
                              child: Container(
                                height: screenHeight * 0.8,
                                width: double.infinity,
                                child: Column(children: [
                                  Row(
                                      // A Row widget
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween, // Free space will be equally divided and will be placed between the children.
                                      children: [
                                        Opacity(
                                            // A Opacity widget
                                            opacity:
                                                0.0, // setting opacity to zero will make its child invisible
                                            child: IconButton(
                                              icon: Icon(Icons
                                                  .clear), // some random icon
                                              onPressed:
                                                  null, // making the IconButton disabled
                                            )),
                                        Flexible(
                                          // A Flexible widget that will make its child flexible
                                          child: Text(
                                            'Add new budget',
                                            overflow: TextOverflow
                                                .ellipsis, // handles overflowing of text
                                          ),
                                        ),
                                        IconButton(
                                            // A normal IconButton
                                            icon: Icon(
                                              FontAwesomeIcons.xmark,
                                              color: kGrayColor,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            }),
                                      ]),
                                ]),
                              ),
                            );
                          },
                        );
                      },
                      child: const Text('+ add new'),
                    )
                  ],
                ),
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
              Container(
                //color: Colors.greenAccent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Budget',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('+ add new'),
                    )
                  ],
                ),
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
              Container(
                //color: Colors.greenAccent,
                child: Row(
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
    );
  }
}
