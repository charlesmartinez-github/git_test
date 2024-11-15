import 'package:finedger/screens/getting_started/login_page.dart';
import 'package:finedger/screens/navigation_pages/change_password_page.dart';
import 'package:finedger/screens/navigation_pages/dashboard_page.dart';
import 'package:finedger/screens/navigation_pages/profile_settings.dart';
import 'package:finedger/services/firebase_auth_services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../constants/constants.dart';
import 'articles_page.dart';
import 'budget_page.dart';
import 'expenses_page.dart';
import 'goals_page.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final _firebaseServices = FirebaseAuthService();
  String formatter = DateFormat('E, MMM d').format(DateTime.now());
  int currentPageIndex = 0;
  List<String> budgetCategories = ['Not on budget'];

  void addItemToDropdown(String newItem) {
    setState(() {
      budgetCategories.add(newItem);
    });
  }

  @override
  void initState() {
    super.initState();
    // Reset page index on init to ensure it starts from the first tab
    currentPageIndex = 3;
  }

  @override
  Widget build(BuildContext context) {
    final List body = [
      const DashboardPage(),
      BudgetPage(onAddItems: addItemToDropdown),
      const GoalsPage(),
      ExpensesPage(budgetCategories: budgetCategories),
      const ArticlesPage(),
    ];
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: body.elementAt(currentPageIndex),
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
                  return const TextStyle(color: Color(0xFFe1e3e6), fontSize: 14);
                } else {
                  return const TextStyle(color: Colors.grey, fontSize: 14);
                }
              },
            ),
            iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: Color(0xFFe1e3e6), size: 30);
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
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: currentPageIndex,
            onDestinationSelected: (int index) {
              setState(
                () {
                  currentPageIndex = index;
                },
              );
            },
            destinations: const <Widget>[
              NavigationDestination(
                  icon: Icon(FontAwesomeIcons.squarePollVertical, color: kIconColor), label: 'Dashboard'),
              NavigationDestination(
                icon: Icon(FontAwesomeIcons.moneyBill1, color: kIconColor),
                label: 'Budget',
              ),
              NavigationDestination(icon: Icon(FontAwesomeIcons.piggyBank, color: kIconColor), label: 'Goals'),
              NavigationDestination(icon: Icon(FontAwesomeIcons.dollarSign, color: kIconColor), label: 'Expenses'),
              NavigationDestination(icon: Icon(FontAwesomeIcons.graduationCap, color: kIconColor), label: 'Articles'),
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
            DrawerHeader(
              child: FutureBuilder(
                  future: _firebaseServices.getUserFirstName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: LinearProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No expense found"));
                    } else {
                      final userData = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CircleAvatar(
                              radius: 30,
                              child: Text(
                                  '${userData['firstName'][0]}',
                              ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                              'Hi, ${userData['firstName']}!',
                            style: const TextStyle(
                                fontSize: 16.0,
                                color: kBlueColor
                            ),
                          ),
                          Text(
                            '${userData['label']}',
                            style: const TextStyle(fontSize: 12.0, color: kGrayColor),
                          )
                        ],
                      );
                    }
                  }),
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
                  setState(() {
                    currentPageIndex = 3;
                    Navigator.pop(context);
                  });
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
                  setState(() {
                    currentPageIndex = 1;
                    Navigator.pop(context);
                  });
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
                  setState(() {
                    currentPageIndex = 2;
                    Navigator.pop(context);
                  });
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
                  setState(() {
                    currentPageIndex = 0;
                    Navigator.pop(context);
                  });
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
}
