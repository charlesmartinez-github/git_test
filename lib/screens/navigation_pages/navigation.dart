import 'package:finedger/screens/navigation_pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    currentPageIndex = 0;
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
                  icon: Icon(FontAwesomeIcons.squarePollVertical,
                      color: kIconColor),
                  label: 'Dashboard'),
              NavigationDestination(
                icon: Icon(FontAwesomeIcons.moneyBill1, color: kIconColor),
                label: 'Budget',
              ),
              NavigationDestination(
                  icon: Icon(FontAwesomeIcons.piggyBank, color: kIconColor),
                  label: 'Goals'),
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
    );
  }
}
