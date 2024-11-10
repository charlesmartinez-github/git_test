import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
    String phoneNumber,
  ) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = credential.user;
      await _db.collection('users').doc(user!.uid).set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber
      });
      return credential.user;
    } catch (e) {
      log('Something went wrong');
    }
    return null;
  }

  Future<void> addExpense (
      double amount,
      String? category,
      String description,
      int date
      ) async {
    String userId = _auth.currentUser!.uid;
    _db.collection('users').doc(userId).collection('expenses').add({
      'description':description,
      'category': category,
      'date': date,
      'amount': amount,
      'timeStamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getUserExpenses() async {
    String userId = _auth.currentUser!.uid;
    QuerySnapshot snapshot = await _db
    .collection('users')
    .doc(userId)
    .collection('expenses')
    .orderBy('timeStamp', descending: true)
    .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> addBudget (
      String description,
      int startDate,
      int endDate,
      double amount
      ) async {
    String userId = _auth.currentUser!.uid;
    _db.collection('users').doc(userId).collection('budgets').add({
      'description':description,
      'startDate': startDate,
      'endDate': endDate,
      'amount': amount,
      'timeStamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getUserBudgets() async {
    String userId = _auth.currentUser!.uid;
    QuerySnapshot snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .orderBy('timeStamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Future<bool> checkIfEmailExist(String email, String password) async {
  //   try {
  //     await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return true;
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'email-already-in-use') {
  //       return false;
  //     }
  //   }
  //   return null;
  // }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      log('Something went wrong');
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log('Something went wrong');
    }
  }
}

class EmailOTPSender {
  EmailOTP myOtp = EmailOTP();
  Future<void> sendOTPto(String email) async {
    EmailOTP.config(
      appEmail: 'finedger@email.com',
      appName: 'FinEdger',
      otpLength: 6,
      emailTheme: EmailTheme.v1,
      //expiry: 300000
    );
    var sendOTP = await EmailOTP.sendOTP(email: email);
    if (sendOTP) {
      log('OTP Sent');
    } else {
      log('Error');
    }
  }

  Future<bool> verifyOTP(String otp) async {
    if (EmailOTP.verifyOTP(otp: otp)) {
      return true;
    } else {
      return false;
    }
  }

  String? getOTP() {
    return EmailOTP.getOTP();
  }
}
