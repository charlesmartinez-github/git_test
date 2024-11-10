import 'package:finedger/screens/getting_started/login_page.dart';
import 'package:flutter/material.dart';
import 'package:finedger/constants/constants.dart';

class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.only(left: 34.0, right: 34.0, top: 64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 84.0),
              child: const Column(
                children: <Widget>[
                  Image(
                    image: AssetImage('images/onboarding_image3.png'),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Goals realized, dreams unlocked',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 23.0),
                  ),
                  Text(
                    'Your journey to success begins now',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: kGrayColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40.0),
            Padding(
              padding: const EdgeInsets.only(top: 19.0),
              child: SizedBox(
                width: double.infinity,
                height: 40.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    backgroundColor: const Color(0xff30437a),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return const LoginPage();
                      }),
                    );
                  },
                  child: const Text(
                    'Get started',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
