import 'package:finedger/screens/getting_started/login_page.dart';
import 'package:finedger/screens/navigation_pages/change_password_page.dart';
import 'package:finedger/screens/navigation_pages/contact_us_page.dart';
import 'package:finedger/screens/navigation_pages/edit_profile_page.dart';
import 'package:finedger/screens/navigation_pages/landing_screen_dashboard.dart';
import 'package:finedger/screens/navigation_pages/notification_page.dart';
import 'package:finedger/screens/navigation_pages/privacy_policy_page.dart';
import 'package:finedger/screens/navigation_pages/profile_settings.dart';
import 'package:finedger/screens/onboarding_pages/onboarding_page1.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: FinEdger(),
    ),
  );
}

class FinEdger extends StatelessWidget {
  const FinEdger({super.key});
  @override
  Widget build(BuildContext context) {
    return const OnboardingPage1();
  }
}
