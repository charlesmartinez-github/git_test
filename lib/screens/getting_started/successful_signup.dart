import 'package:finedger/main.dart';
import 'package:finedger/screens/getting_started/login_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SuccessfulSignup extends StatelessWidget {
  const SuccessfulSignup({super.key});

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.10,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                FontAwesomeIcons.circleCheck,
                size: 120.0,
                color: Colors.green,
              ),
              const SizedBox(height: 10.0,),
              const Text(
                'Successful',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 25.0,
                ),
              ),
              const SizedBox(height: 18.0,),
              Container(
                margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55.0,
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
                          return const FinEdger();
                        }),
                      );
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
