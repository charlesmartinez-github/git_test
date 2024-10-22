import 'dart:developer';

import 'package:email_otp/email_otp.dart';
import 'package:finedger/screens/getting_started/email_verification.dart';
import 'package:finedger/screens/getting_started/login_page.dart';
import 'package:finedger/services/firebase_auth_services.dart';

import 'package:finedger/widgets/for_gettingstarted.dart';
import 'package:flutter/material.dart';
import 'package:finedger/constants/constants.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _auth = FirebaseAuthService();
  final _otp = EmailOTPSender();

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? validateEmail(String? email) {
    RegExp emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    final isEmailValid = emailRegex.hasMatch(email ?? '');
    if (!isEmailValid) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhoneNumber(String? phoneNumber) {
    RegExp phoneNumberRegex = RegExp(
        r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$');
    final isPhoneNumberValid = phoneNumberRegex.hasMatch(phoneNumber ?? '');
    if (phoneNumber!.isEmpty) {
      return 'Please enter a phone number';
    } else if (!isPhoneNumberValid) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _emailController.dispose();
    _phoneNumber.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                  SizedBox(
                    height: screenHeight * 0.030,
                  ),
                  SignUpForm(
                    controller: _firstName,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'First name cannot be empty';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    obscureText: false,
                    labelText: 'First name',
                  ),
                  SizedBox(
                    height: screenHeight * 0.010,
                  ),
                  SignUpForm(
                    controller: _lastName,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Last name cannot be empty';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    obscureText: false,
                    labelText: 'Last Name',
                  ),
                  SizedBox(
                    height: screenHeight * 0.010,
                  ),
                  SignUpForm(
                    controller: _emailController,
                    validator: validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    obscureText: false,
                    labelText: 'Email',
                  ),
                  SizedBox(
                    height: screenHeight * 0.010,
                  ),
                  SignUpForm(
                    controller: _phoneNumber,
                    validator: validatePhoneNumber,
                    keyboardType: TextInputType.phone,
                    obscureText: false,
                    labelText: 'Phone number',
                  ),
                  SizedBox(
                    height: screenHeight * 0.010,
                  ),
                  SignUpForm(
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      }
                      // Perform custom password validation here
                      if (value.length < 8) {
                        return "Password must be at least 8 characters long";
                      }
                      if (!value.contains(RegExp(r'[A-Z]'))) {
                        return "Password must contain at least one uppercase letter";
                      }
                      if (!value.contains(RegExp(r'[a-z]'))) {
                        return "Password must contain at least one lowercase letter";
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return "Password must contain at least one numeric character";
                      }
                      if (!value.contains(RegExp(r'[!@#$%^&*()<>?/|}{~:]'))) {
                        return "Password must contain at least one special character";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    labelText: 'Password',
                  ),
                  SizedBox(
                    height: screenHeight * 0.010,
                  ),
                  SignUpForm(
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Match your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    labelText: 'Confirm password',
                  ),
                  SizedBox(
                    height: screenHeight * 0.020,
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: LargeButton(
                      onPress: () async {
                        if (_formKey.currentState!.validate()) {
                          // await _otp.sendOTPto(_emailController.text);
                          // String? otpCode = _otp.getOTP();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => EmailVerification(
                                email: _emailController.text,
                                password: _passwordController.text,
                              ),
                            ),
                          );
                        }
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
      ),
    );
  }
}
