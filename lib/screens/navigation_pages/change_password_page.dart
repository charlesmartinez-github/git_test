import 'package:finedger/constants/constants.dart';
import 'package:finedger/widgets/for_gettingstarted.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('Change Password'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            top: screenWidth * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                ' Current password',
                style: TextStyle(
                  fontSize: 15.0
                ),
              ),
              const SizedBox(height: 4.0),
              Container(
                height: screenHeight * 0.073,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter current password',
                    hintStyle: TextStyle(
                      color: kGrayColor,
                      fontWeight: FontWeight.normal,
                    ),
                    floatingLabelStyle: TextStyle(
                      fontSize: 15.0,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              const Text('New password'),
              const SizedBox(height: 4.0),
              Container(
                height: screenHeight * 0.073,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'min. 8 characters',
                    hintStyle: TextStyle(
                      color: kGrayColor,
                      fontWeight: FontWeight.normal,
                    ),
                    floatingLabelStyle: TextStyle(
                      fontSize: 15.0,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              const Text('Confirm password'),
              const SizedBox(height: 4.0),
              Container(
                height: screenHeight * 0.073,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Confirm password',
                    hintStyle: TextStyle(
                      color: kGrayColor,
                      fontWeight: FontWeight.normal,
                    ),
                    floatingLabelStyle: TextStyle(
                      fontSize: 15.0,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              SmallButton(buttonLabel: 'SAVE', onPress: () {})
            ],
          ),
        ),
      ),
    );
  }
}
