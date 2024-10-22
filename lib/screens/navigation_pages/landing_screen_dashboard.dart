import 'package:finedger/constants/constants.dart';
import 'package:finedger/screens/getting_started/login_page.dart';
import 'package:finedger/screens/navigation_pages/profile_settings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

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

    TextEditingController date = TextEditingController();

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
                  Navigator.push(
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
              setState(
                () {
                  currentPageIndex = index;
                },
              );
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
                                              suffixIcon: const Icon(Icons.calendar_month_outlined, color: kGrayColor,),
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
                                            onTap: () async{
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
                                              prefixIcon: const Icon(FontAwesomeIcons.dollarSign, color: kGrayColor,),
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
                                            borderRadius: BorderRadius.circular(11),
                                          ),
                                          backgroundColor: kBlueColor,
                                        ),
                                        onPressed: (){},
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
                                              suffixIcon: const Icon(Icons.calendar_month_outlined, color: kGrayColor,),
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
                                            onTap: () async{
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
                                              prefixIcon: const Icon(FontAwesomeIcons.dollarSign, color: kGrayColor,),
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
                                                borderRadius: BorderRadius.circular(11),
                                              ),
                                              backgroundColor: kBlueColor,
                                            ),
                                            onPressed: (){},
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
    );
  }
}
