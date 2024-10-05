import 'package:flutter/material.dart';
import 'package:finedger/constants/constants.dart';
import 'onboarding_page3.dart';

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.only(left: 34.0, right: 34.0, top: 64.0),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 73.0),
              child: const Column(
                children: [
                  Image(
                    image: AssetImage('images/onboarding_image2.png'),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Save today, thrive tomorrow',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 23.0
                    ),
                  ),
                  Text(
                    'Your path to financial freedom starts with every coin saved',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) {
                      return const OnboardingPage3();
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
                Navigator.push(
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
    );
  }
}
