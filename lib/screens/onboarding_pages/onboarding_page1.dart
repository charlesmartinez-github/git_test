import 'package:finedger/constants/constants.dart';
import 'package:finedger/screens/onboarding_pages/onboarding_page2.dart';
import 'package:finedger/screens/onboarding_pages/onboarding_page3.dart';
import 'package:flutter/material.dart';

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

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
              padding: const EdgeInsets.only(top: 80.0),
              child: const Column(
                children: [
                  Image(
                    image: AssetImage('images/onboarding_image1.png'),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Empower your financial future',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 23.0),
                  ),
                  Text(
                    'Securing and managing your money',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: kGrayColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40.0),
            Container(
              padding: const EdgeInsets.only(top: 19.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
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
                            return const OnboardingPage2();
                          }),
                        );
                      },
                      child: const Text(
                        'Next',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const OnboardingPage3();
                          },
                        ),
                      );
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Color(0xff30437a)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
