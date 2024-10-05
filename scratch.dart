import 'package:flutter/material.dart';

class Page extends StatelessWidget {
  const Page({super.key});

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
                    horizontal: screenWidth * 0.02, // 2% padding for responsiveness
                  ),
                  width: double.infinity,
                  height: screenHeight * 0.08, // Button height as 8% of screen height
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      // Handle login action
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
                      // Navigate to register page
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
}

void main() {
  runApp(const MaterialApp(
    home: Page(),
  ));
}
