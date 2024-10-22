import 'dart:developer';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:finedger/services/firebase_auth_services.dart';

class Page extends StatelessWidget {
  Page({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  EmailOTP myOTP = EmailOTP();
  @override
  Widget build(BuildContext context) {
    // Screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            color: Colors.greenAccent,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.10, // 10% of screen width
              vertical: screenHeight * 0.05, // 5% of screen height
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.10), // Spacer at the top

                // Title or Logo
                Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: screenHeight * 0.05, // Responsive font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),

                // Email TextField
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Password TextField
                TextField(
                  controller: otpController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Login Button (Full Width, Responsive Padding)
                Container(
                  color: Colors.redAccent,
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        screenWidth * 0.02, // 2% padding for responsiveness
                  ),
                  width: double.infinity,
                  height: screenHeight *
                      0.08, // Button height as 8% of screen height
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      sentOTP(emailController.text);
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: screenHeight * 0.025, // Responsive font size
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                // Register link
                Center(
                  child: TextButton(
                    onPressed: () {
                      verifyOTP(otpController.text);
                    },
                    child: Text(
                      "Don't have an account? Register",
                      style: TextStyle(fontSize: screenHeight * 0.02),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> sentOTP(String email) async {
    EmailOTP.config(
        appEmail: 'finedger@email.com',
        appName: 'FinEdger',
        otpLength: 6,
        emailTheme: EmailTheme.v1,
    );
    var sendOTP = await EmailOTP.sendOTP(email: email);
    if (sendOTP) {
      log('OTP Sent');
    } else {
      log('Error');
    }
  }

  Future<void> verifyOTP(String otp) async {
    EmailOTP.verifyOTP(otp: otp);
  }
}



void main() {
  runApp(MaterialApp(
    home: Page(),
  ));
}
