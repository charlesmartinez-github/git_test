import 'package:finedger/screens/getting_started/login_page.dart';
import 'package:finedger/screens/getting_started/signup_page.dart';
import 'package:finedger/screens/onboarding_pages/onboarding_page1.dart';
import 'package:finedger/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyCHGCTEKylw4daavrNDtAgc-4A5TTUab_I",
        appId: "1:217026675332:android:cb225046e2de97368278d1",
        messagingSenderId: "217026675332",
        projectId: "finedger-fed20",
    )
  );
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
    return const Wrapper();
  }
}
