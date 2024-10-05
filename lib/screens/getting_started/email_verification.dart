import 'package:finedger/constants/constants.dart';
import 'package:finedger/screens/getting_started/phone_verification.dart';
import 'package:finedger/screens/getting_started/successful_signup.dart';
import 'package:finedger/widgets/for_gettingstarted.dart';
import 'package:flutter/material.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({super.key});

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.075,
              vertical: screenHeight * 0.10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Enter your code',
                      style: kTitleTextStyle,
                    ),
                    const Text(
                      'Type the verification code you received at:',
                      style: kSentenceTextStyle,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    const Text(
                      'Emailed to ma....ez@gmail.com',
                      style: kSentenceTextStyle,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    const Text(
                      'It can take a few minutes to get your code',
                      style: TextStyle(color: kGrayColor, fontSize: 12.0),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                const SignUpForm(keyboardType: TextInputType.number, labelText: 'enter verification code', obscureText: false),
                const SizedBox(height: 25.0),
                LargeButton(
                    onPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const SuccessfulSignup();
                          },
                        ),
                      );
                    },
                    buttonLabel: 'Confirm',
                    backgroundColor: kBlueColor,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Still haven\'t got your code?',
                      style: TextStyle(color: kGrayColor, fontSize: 13.0),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Send a new code',
                        style: TextStyle(
                            color: Color(0xff30437a), fontSize: 13.0),
                      ),
                    ),
                  ],
                ),
                const IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                        height: 20.0,
                        width: 145.0,
                        child: Divider(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'or',
                        style: TextStyle(fontSize: 13),
                      ),
                      SizedBox(
                        height: 10.0,
                        width: 145.0,
                        child: Divider(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: ButtonText(
                    onPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const PhoneVerification();
                          },
                        ),
                      );
                    }, buttonLabel: 'Choose a different way to receive it',
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
