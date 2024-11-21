import 'package:finedger/providers/page_provider.dart';
import 'package:finedger/screens/getting_started/login_page.dart';
import 'package:finedger/screens/navigation_pages/dashboard_page.dart';
import 'package:finedger/screens/navigation_pages/profile_settings.dart';
import 'package:finedger/services/firebase_auth_services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:finedger/constants/constants.dart';
import 'articles_page.dart';
import 'budget_page.dart';
import 'expenses_page.dart';
import 'goals_page.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key, required this.passedPageIndex});

  final int passedPageIndex;

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final _firebaseServices = FirebaseAuthService();
  String formatter = DateFormat('E, MMM d').format(DateTime.now());
  List<String> budgetCategories = ['Not on budget'];

  void addItemToDropdown(String newItem) {
    setState(() {
      budgetCategories.add(newItem);
    });
  }

  @override
  void initState() {
    super.initState();
    // Use post frame callback to access context after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PageProvider>().setCurrentPageIndex(widget.passedPageIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> body = [
      const DashboardPage(),
      BudgetPage(onAddItems: addItemToDropdown),
      const GoalsPage(),
      ExpensesPage(budgetCategories: budgetCategories),
      const ArticlesPage(),
    ];

    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Consumer<PageProvider>(
      builder: (BuildContext context, PageProvider pageProvider, Widget? child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: body.elementAt(pageProvider.currentPageIndex),
          bottomNavigationBar: Container(
            height: screenHeight * 0.10, // Reduced height for better fitting
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
                      return TextStyle(color: const Color(0xFFe1e3e6), fontSize: screenWidth * 0.03); // Responsive text size
                    } else {
                      return TextStyle(color: Colors.grey, fontSize: screenWidth * 0.03); // Responsive text size
                    }
                  },
                ),
                iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                      (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return IconThemeData(color: const Color(0xFFe1e3e6), size: screenWidth * 0.08); // Responsive icon size
                    } else {
                      return IconThemeData(color: Colors.grey, size: screenWidth * 0.06); // Responsive icon size
                    }
                  },
                ),
              ),
              child: NavigationBar(
                backgroundColor: kBlueColor,
                indicatorColor: kBlueColor,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                selectedIndex: pageProvider.currentPageIndex,
                onDestinationSelected: (int index) {
                  pageProvider.setCurrentPageIndex(index);
                },
                destinations: const <Widget>[
                  NavigationDestination(
                    icon: Icon(FontAwesomeIcons.squarePollVertical, color: kIconColor),
                    label: 'Dashboard',
                  ),
                  NavigationDestination(
                    icon: Icon(FontAwesomeIcons.moneyBill1, color: kIconColor),
                    label: 'Budget',
                  ),
                  NavigationDestination(
                    icon: Icon(FontAwesomeIcons.piggyBank, color: kIconColor),
                    label: 'Goals',
                  ),
                  NavigationDestination(
                    icon: Icon(FontAwesomeIcons.pesoSign, color: kIconColor),
                    label: 'Expenses',
                  ),
                  NavigationDestination(
                    icon: Icon(FontAwesomeIcons.graduationCap, color: kIconColor),
                    label: 'Articles',
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
                DrawerHeader(
                  child: FutureBuilder(
                      future: _firebaseServices.getUserFirstName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: LinearProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(child: Text("Error: \${snapshot.error}"));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text("No data found"));
                        } else {
                          final userData = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 30,
                                child: Text('${userData['firstName'][0]}'),
                              ),
                              const SizedBox(height: 5.0),
                              Text(
                                'Hi, ${userData['firstName']}!',
                                style: const TextStyle(fontSize: 16.0, color: kBlueColor),
                              ),
                              Text(
                                '${userData['label']}',
                                style: const TextStyle(fontSize: 12.0, color: kGrayColor),
                              ),
                            ],
                          );
                        }
                      }),
                ),
                _buildDrawerItem(
                  icon: FontAwesomeIcons.user,
                  text: 'Profile & Settings',
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
                _buildDrawerItem(
                  icon: FontAwesomeIcons.coins,
                  text: 'Manage Expenses',
                  onTap: () {
                    context.read<PageProvider>().setCurrentPageIndex(3);
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: FontAwesomeIcons.moneyBills,
                  text: 'Manage Budget',
                  onTap: () {
                    context.read<PageProvider>().setCurrentPageIndex(1);
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: FontAwesomeIcons.piggyBank,
                  text: 'Manage Goals',
                  onTap: () {
                    context.read<PageProvider>().setCurrentPageIndex(2);
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: FontAwesomeIcons.squarePollVertical,
                  text: 'Dashboard',
                  onTap: () {
                    context.read<PageProvider>().setCurrentPageIndex(0);
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: FontAwesomeIcons.arrowRightFromBracket,
                  text: 'Sign out',
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return Container(
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
        leading: Icon(icon, size: 16),
        title: Text(text),
        onTap: onTap,
      ),
    );
  }
}
