import 'package:finedger/providers/page_provider.dart';
import 'package:finedger/screens/navigation_pages/navigation.dart';
import 'package:finedger/screens/onboarding_pages/onboarding_page1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Some error occurred.'),
            );
          } else {
            if (snapshot.data == null) {
              return const OnboardingPage1();
            } else {
              return Consumer<PageProvider>(
                builder: (context, pageProvider, child) {
                  return Navigation(passedPageIndex: pageProvider.currentPageIndex);
                },
              );
            }
          }
        },
      ),
    );
  }
}
