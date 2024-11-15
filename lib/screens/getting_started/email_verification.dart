import 'dart:developer';
import 'package:finedger/constants/constants.dart';
import 'package:finedger/screens/getting_started/phone_verification.dart';
import 'package:finedger/screens/getting_started/successful_signup.dart';
import 'package:finedger/services/firebase_auth_services.dart';
import 'package:finedger/widgets/for_gettingstarted.dart';
import 'package:flutter/material.dart';

class EmailVerification extends StatefulWidget {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const EmailVerification(
      {super.key,
      required this.email,
      required this.password,
      required this.firstName,
      required this.lastName,
      required this.phoneNumber
      });

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  final _auth = FirebaseAuthService();
  final _otp = EmailOTPSender();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _otp.sendOTPto(widget.email);
    print(_otp.getOTP());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

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
                      Text(
                        'Emailed to ${widget.email}',
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
                  OTPForm(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    labelText: 'enter verification code',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your OTP here';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25.0),
                  LargeButton(
                    onPress: () async {
                      log(_otpController.text);
                      log(_otp.getOTP().toString());
                      if (_formKey.currentState!.validate()) {
                        bool isVerified =
                            await _otp.verifyOTP(_otpController.text);
                        if (isVerified) {
                          _signUp();
                          _auth.createInitialAccount();
                        }
                      }
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
                        onPressed: () {_otp.sendOTPto(widget.email);},
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
                      },
                      buttonLabel: 'Choose a different way to receive it',
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  _signUp() async {
    final user = await _auth.createUserWithEmailAndPassword(widget.email,
        widget.password, widget.firstName, widget.lastName, widget.phoneNumber);
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) {
            return const SuccessfulSignup();
          },
        ),
      );
    }
  }
}
