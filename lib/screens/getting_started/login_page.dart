import 'package:finedger/screens/navigation_pages/edit_profile_page.dart';
import 'package:finedger/screens/navigation_pages/landing_screen_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:finedger/widgets/for_gettingstarted.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'signup_page.dart';
import 'package:finedger/constants/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              //color: Colors.redAccent,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.10,
                vertical: screenHeight * 0.05,
              ),
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'images/finedger_logo.png',
                    width: 200.0,
                    height: 200.0,
                  ),
                  const LoginForm(
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false),
                  SizedBox(height: screenHeight * 0.025),
                  const LoginForm(
                      hintText: 'Password',
                      keyboardType: TextInputType.text,
                      obscureText: true),
                  SizedBox(height: screenHeight * 0.025),
                  LargeButton(
                    //Login Button
                    onPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const LandingScreenDashboard();
                          },
                        ),
                      );
                    },
                    buttonLabel: 'Login',
                    backgroundColor: kBlueColor,
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  const Text('or Sign up to get started'),
                  SizedBox(height: screenHeight * 0.005),
                  LargeButton(
                      //SignUp Button
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const SignupPage();
                            },
                          ),
                        );
                      },
                      buttonLabel: 'Sign Up',
                      backgroundColor: kGreenColor),
                  SizedBox(height: screenHeight * 0.005),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: CheckboxListTile(
                          checkColor: Colors.white,
                          activeColor: const Color(0xff30437a),
                          title: const Text(
                            'Remember me',
                            style: TextStyle(fontSize: 11.0),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(
                              () {
                                isChecked = value!;
                              },
                            );
                          },
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                              color: Color(0xff30437a), fontSize: 11.0),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                    child: const FederatedIdentitySignInButton(
                      icon: Icon(FontAwesomeIcons.google),
                      label: 'Continue with Google',
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                    child: const FederatedIdentitySignInButton(
                      icon: Icon(FontAwesomeIcons.apple),
                      label: 'Continue with Apple',
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                    child: const FederatedIdentitySignInButton(
                      icon: Icon(FontAwesomeIcons.facebook),
                      label: 'Continue with Facebook',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
