import 'dart:developer';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:finedger/services/firebase_auth_services.dart';

// class Page extends StatefulWidget {
//   Page({super.key});
//
//   @override
//   State<Page> createState() => _PageState();
// }
//
// class _PageState extends State<Page> {
//   final TextEditingController emailController = TextEditingController();
//
//   final TextEditingController otpController = TextEditingController();
//
//   EmailOTP myOTP = EmailOTP();
//
//   String _initialDropDownValue = 'Not on the budget';
//
//   var _dropDownItems = [
//     'Food',
//     'Transp',
//     'Naild',
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     // Screen size
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SingleChildScrollView(
//           child: Container(
//             color: Colors.greenAccent,
//             padding: EdgeInsets.symmetric(
//               horizontal: screenWidth * 0.10, // 10% of screen width
//               vertical: screenHeight * 0.05, // 5% of screen height
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: screenHeight * 0.10),
//                 DropdownButton(
//                     items: _dropDownItems.map((String item){
//                       return DropdownMenuItem(value: item, child: Text(item));
//                     }).toList(),
//                     onChanged: (String? newValue){
//                       setState(() {
//                         _initialDropDownValue = newValue!;
//                       });
//                     },
//                   value: _initialDropDownValue,
//                 ),
//
//                 // Title or Logo
//                 Center(
//                   child: Text(
//                     "Login",
//                     style: TextStyle(
//                       fontSize: screenHeight * 0.05, // Responsive font size
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: screenHeight * 0.05),
//
//                 // Email TextField
//                 TextField(
//                   controller: emailController,
//                   decoration: InputDecoration(
//                     labelText: "Email",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: screenHeight * 0.02),
//
//                 // Password TextField
//                 TextField(
//                   controller: otpController,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     labelText: "Password",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: screenHeight * 0.02),
//
//                 // Login Button (Full Width, Responsive Padding)
//                 Container(
//                   color: Colors.redAccent,
//                   padding: EdgeInsets.symmetric(
//                     horizontal:
//                         screenWidth * 0.02, // 2% padding for responsiveness
//                   ),
//                   width: double.infinity,
//                   height: screenHeight *
//                       0.08, // Button height as 8% of screen height
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.blue,
//                     ),
//                     onPressed: () {
//                       sentOTP(emailController.text);
//                     },
//                     child: Text(
//                       "Login",
//                       style: TextStyle(
//                         fontSize: screenHeight * 0.025, // Responsive font size
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: screenHeight * 0.05),
//                 // Register link
//                 Center(
//                   child: TextButton(
//                     onPressed: () {
//                       verifyOTP(otpController.text);
//                     },
//                     child: Text(
//                       "Don't have an account? Register",
//                       style: TextStyle(fontSize: screenHeight * 0.02),
//                     ),
//                   ),
//                 ),
//
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> sentOTP(String email) async {
//     EmailOTP.config(
//       appEmail: 'finedger@email.com',
//       appName: 'FinEdger',
//       otpLength: 6,
//       emailTheme: EmailTheme.v1,
//     );
//     var sendOTP = await EmailOTP.sendOTP(email: email);
//     if (sendOTP) {
//       log('OTP Sent');
//     } else {
//       log('Error');
//     }
//   }
//
//   Future<void> verifyOTP(String otp) async {
//     EmailOTP.verifyOTP(otp: otp);
//   }
// }

void main() {
  runApp(MaterialApp(
    home: ListViewTest(),
  ));
}

class ListViewTest extends StatefulWidget {
  const ListViewTest({super.key});

  @override
  State<ListViewTest> createState() => _ListViewTestState();
}

class _ListViewTestState extends State<ListViewTest> {
  List<String> products = ['Bed', 'Sofa', 'Chair'];
  List<String> productDetails = [
    'King Size Bed',
    'King Size Sofa',
    'Wooden Chair'
  ];
  List<int> price = [3000, 2500, 1860];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.greenAccent,
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                child: ListTile(
                  leading: CircleAvatar(child: Text(products[index][0]),),
                  title: Text(products[index]),
                  subtitle: Text(productDetails[index]),
                  trailing: Text('P${price[index]}'),
                ),
              );
            }),
      ),
    );
  }
}
