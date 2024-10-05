import 'package:finedger/screens/getting_started/email_verification.dart';
import 'package:finedger/screens/getting_started/login_page.dart';
import 'package:finedger/widgets/for_gettingstarted.dart';
import 'package:flutter/material.dart';
import 'package:finedger/constants/constants.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

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
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      'Sign up',
                      style: kTitleTextStyle,
                    ),
                    Text(
                      "Let's get started with your information",
                      style: kSentenceTextStyle,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.030,),
                const SignUpForm(
                    keyboardType: TextInputType.text,
                    labelText: 'Name',
                    obscureText: false,
                ),
                SizedBox(height: screenHeight * 0.010,),
                const SignUpForm(
                    keyboardType: TextInputType.emailAddress,
                    labelText: 'Email',
                    obscureText: false,
                ),
                SizedBox(height: screenHeight * 0.010,),
                const SignUpForm(
                  keyboardType: TextInputType.phone,
                  labelText: 'Phone number',
                  obscureText: false,
                ),
                SizedBox(height: screenHeight * 0.010,),
                const SignUpForm(
                  keyboardType: TextInputType.text,
                  labelText: 'Password',
                  obscureText: true,
                ),
                SizedBox(height: screenHeight * 0.010,),
                const SignUpForm(
                    keyboardType: TextInputType.text,
                    labelText: 'Confirm password',
                    obscureText: true,
                ),
                SizedBox(height: screenHeight * 0.020,),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: LargeButton(
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const EmailVerification();
                            },
                          ),
                        );
                      },
                      buttonLabel: 'Create account',
                      backgroundColor: kBlueColor,
                  ),
                ),
                ButtonText(
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const LoginPage();
                        },
                      ),
                    );
                  },
                  buttonLabel: 'Back to login',
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


