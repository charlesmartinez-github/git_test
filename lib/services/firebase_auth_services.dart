import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = credential.user;
      await _db.collection('users').doc(user!.uid).set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
      });
      return credential.user;
    } catch (e) {
      log('Something went wrong');
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
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

  Future<void> addExpense(
    double amount,
    String? category,
    String description,
    int date,
  ) async {
    String userId = _auth.currentUser!.uid;

    // Add the expense document
    await _db.collection('users').doc(userId).collection('expenses').add({
      'description': description,
      'category': category,
      'date': date,
      'amount': amount,
      'timeStamp': FieldValue.serverTimestamp(),
    });

    // Check if the expense category matches a budget's description
    if (category != null) {
      final budgetQuerySnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .where('description', isEqualTo: category)
          .get();

      // If a matching budget document is found
      if (budgetQuerySnapshot.docs.isNotEmpty) {
        final budgetDoc = budgetQuerySnapshot.docs.first;

        // Get the current spentAmount
        double currentSpentAmount = budgetDoc['spentAmount'] ?? 0.00;

        // Update the spentAmount by adding the expense amount
        await _db.collection('users').doc(userId).collection('budgets').doc(budgetDoc.id).update({
          'spentAmount': currentSpentAmount + amount,
        });
      }
    }
  }

  Stream<List<Map<String, dynamic>>> getUserExpenses() {
    String userId = _auth.currentUser!.uid;
    return _db
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addBudget(String description, int startDate, int endDate, double amount) async {
    String userId = _auth.currentUser!.uid;
    _db.collection('users').doc(userId).collection('budgets').add({
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'amount': amount,
      'spentAmount': 0.0,
      'timeStamp': FieldValue.serverTimestamp(),
    });
  }

  void addGoalFunds(String goalId, double amountToAdd) async {
    // Reference to the specific goal document in Firestore
    String userId = _auth.currentUser!.uid;
    DocumentReference goalRef = _db.collection('users').doc(userId).collection('goals').doc(goalId);

    try {
      // Get the current "Saved" amount
      DocumentSnapshot snapshot = await goalRef.get();
      double currentSavedAmount = snapshot.get('amountSaved') ?? 0.00;

      // Calculate the new "Saved" amount
      double newSavedAmount = currentSavedAmount + amountToAdd;

      // Update Firestore with the new amount
      await goalRef.update({'amountSaved': newSavedAmount});
      log("Funds added successfully!");
    } catch (error) {
      log("Failed to add funds: $error");
    }
  }

  Stream<List<Map<String, dynamic>>> getUserBudgets() {
    String userId = _auth.currentUser!.uid;
    return _db
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addGoal(String description, int startDate, int endDate, double targetAmount) async {
    String userId = _auth.currentUser!.uid;
    _db.collection('users').doc(userId).collection('goals').add({
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'amountSaved': 0.00,
      'targetAmount': targetAmount,
      'timeStamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<DocumentSnapshot>> getUserGoals() async {
    String userId = _auth.currentUser!.uid;
    QuerySnapshot snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('goals')
        .orderBy('timeStamp', descending: true)
        .get();

    return snapshot.docs;  // Return the list of DocumentSnapshots directly
  }

  Future<Map<String, dynamic>?> getUserFirstName() async {
    String userId = _auth.currentUser!.uid;
    DocumentSnapshot snapshot = await _db.collection('users').doc(userId).get();
    return snapshot.data() as Map<String, dynamic>?;
  }
  
  Stream<QuerySnapshot> expenseData() {
    String userId = _auth.currentUser!.uid;
    return _db
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('timeStamp', descending: true)
        .snapshots();
  }

  Future<void> createInitialAccount(String accountName) async {
    String userId = _auth.currentUser!.uid;
    _db.collection('users').doc(userId).collection('accounts').add({
      'accountName' : accountName,
      'funds': 0.0,
      'timeStamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<double> streamFunds(String accountId) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(accountId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return snapshot.get('funds')?.toDouble() ?? 0.0;
      } else {
        return 0.0;
      }
    });
  }
  Future<void> addAccountFunds(String accountId, double amount) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentReference accountRef = _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(accountId);

    await _db.runTransaction((transaction) async {
      DocumentSnapshot accountSnapshot = await transaction.get(accountRef);

      if (!accountSnapshot.exists) {
        throw Exception("Account does not exist!");
      }

      double currentFunds = accountSnapshot.get('funds')?.toDouble() ?? 0.0;
      double newFunds = currentFunds + amount;

      transaction.update(accountRef, {'funds': newFunds});
    }).catchError((error) {
      log("Failed to add funds: $error");
    });
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
