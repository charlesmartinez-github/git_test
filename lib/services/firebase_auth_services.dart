import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:finedger/providers/account_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
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
      print('Something went wrong');
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      print('Something went wrong');
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Something went wrong');
    }
  }

  Future<void> addExpense(
      BuildContext context,
      double amount,
      String? category,
      String description,
      int date,
      ) async {
    String userId = _auth.currentUser!.uid;
    String? selectedAccount = context.read<AccountProvider>().selectedAccount;

    if (selectedAccount == null) {
      throw Exception('No account selected');
    }

    // Add the expense document to the selected account
    await _db.collection('users').doc(userId).collection('accounts').doc(selectedAccount).collection('expenses').add({
      'description': description,
      'category': category,
      'date': date,
      'amount': amount,
      'timeStamp': FieldValue.serverTimestamp(),
    });

    // Deduct the expense amount from the account funds
    await _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .update({'funds': FieldValue.increment(-amount)});

    // Check if the expense category matches a budget's description in the selected account
    if (category != null) {
      final budgetQuerySnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .doc(selectedAccount)
          .collection('budgets')
          .where('description', isEqualTo: category)
          .get();

      // If a matching budget document is found
      if (budgetQuerySnapshot.docs.isNotEmpty) {
        final budgetDoc = budgetQuerySnapshot.docs.first;

        // Get the current spentAmount
        double currentSpentAmount = (budgetDoc['spentAmount'] as num).toDouble() ?? 0.00;

        // Update the spentAmount by adding the expense amount
        await _db
            .collection('users')
            .doc(userId)
            .collection('accounts')
            .doc(selectedAccount)
            .collection('budgets')
            .doc(budgetDoc.id)
            .update({
          'spentAmount': currentSpentAmount + amount,
        });
      }
    }
  }

  Stream<List<Map<String, dynamic>>> getUserExpenses(BuildContext context) {
    String userId = _auth.currentUser!.uid;
    String? selectedAccount = context.read<AccountProvider>().selectedAccount;

    if (selectedAccount == null) {
      throw Exception('No account selected');
    }

    return _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('expenses')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addBudget(
    BuildContext context,
    String description,
    int startDate,
    int endDate,
    double amount,
  ) async {
    String userId = _auth.currentUser!.uid;
    String? selectedAccount = context.read<AccountProvider>().selectedAccount;
    Random random = Random();
    int colorValue = Color.fromARGB(
      255,
      random.nextInt(256), // Random Red value (0-255)
      random.nextInt(256), // Random Green value (0-255)
      random.nextInt(256), // Random Blue value (0-255)
    ).value;

    if (selectedAccount == null) {
      throw Exception('No account selected');
    }

    // Add the budget document to the selected account
    await _db.collection('users').doc(userId).collection('accounts').doc(selectedAccount).collection('budgets').add({
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'amount': amount,
      'spentAmount': 0.0,
      'color': colorValue,
      'timeStamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addGoalFunds(BuildContext context, String goalId, double amountToAdd) async {
    String userId = _auth.currentUser!.uid;
    String? selectedAccount = context.read<AccountProvider>().selectedAccount;

    if (selectedAccount == null) {
      throw Exception('No account selected');
    }

    DocumentReference goalRef = _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('goals')
        .doc(goalId);

    try {
      // Get the current "Saved" amount
      DocumentSnapshot snapshot = await goalRef.get();
      double currentSavedAmount = (snapshot.get('amountSaved') as num).toDouble() ?? 0.00;

      // Calculate the new "Saved" amount
      double newSavedAmount = currentSavedAmount + amountToAdd;

      // Update Firestore with the new amount
      await goalRef.update({'amountSaved': newSavedAmount});

      // Deduct the added amount from the account funds
      await _db
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .doc(selectedAccount)
          .update({'funds': FieldValue.increment(-amountToAdd)});

      print("Funds added successfully!");
    } catch (error) {
      print("Failed to add funds: \$error");
    }
  }

  Stream<List<Map<String, dynamic>>> getUserBudgets(BuildContext context) {
    String userId = _auth.currentUser!.uid;
    String? selectedAccount = context.read<AccountProvider>().selectedAccount;

    if (selectedAccount == null) {
      throw Exception('No account selected');
    }

    return _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('budgets')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addGoal(
    BuildContext context,
    String description,
    int startDate,
    int endDate,

    double targetAmount,
  ) async {
    String userId = _auth.currentUser!.uid;
    String? selectedAccount = context.read<AccountProvider>().selectedAccount;
    Random random = Random();
    int colorValue = Color.fromARGB(
      255,
      random.nextInt(256), // Random Red value (0-255)
      random.nextInt(256), // Random Green value (0-255)
      random.nextInt(256), // Random Blue value (0-255)
    ).value;

    if (selectedAccount == null) {
      throw Exception('No account selected');
    }

    // Add the goal document to the selected account
    await _db.collection('users').doc(userId).collection('accounts').doc(selectedAccount).collection('goals').add({
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'amountSaved': 0.00,
      'color': colorValue,
      'targetAmount': targetAmount,
      'timeStamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<DocumentSnapshot>> getUserGoals(BuildContext context) {
    String userId = _auth.currentUser!.uid;
    String? selectedAccount = context.read<AccountProvider>().selectedAccount;

    if (selectedAccount == null) {
      throw Exception('No account selected');
    }

    return _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('goals')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }



  Future<Map<String, dynamic>?> getUserFirstName() async {
    String userId = _auth.currentUser!.uid;
    DocumentSnapshot snapshot = await _db.collection('users').doc(userId).get();
    return snapshot.data() as Map<String, dynamic>?;
  }

  Stream<QuerySnapshot> expenseData(BuildContext context) {
    String userId = _auth.currentUser!.uid;
    String? selectedAccount = context.read<AccountProvider>().selectedAccount;

    if (selectedAccount == null) {
      throw Exception('No account selected');
    }

    return _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('expenses')
        .orderBy('timeStamp', descending: true)
        .snapshots();
  }

  Future<void> createInitialAccount(String accountName) async {
    String userId = _auth.currentUser!.uid;
    _db.collection('users').doc(userId).collection('accounts').add({
      'accountName': accountName,
      'funds': 0.0,
      'timeStamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<double> streamFunds(String accountId) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return _db.collection('users').doc(userId).collection('accounts').doc(accountId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.get('funds')?.toDouble() ?? 0.0;
      } else {
        return 0.0;
      }
    });
  }

  Future<void> addAccountFunds(String accountId, double amount) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentReference accountRef = _db.collection('users').doc(userId).collection('accounts').doc(accountId);

    await _db.runTransaction((transaction) async {
      DocumentSnapshot accountSnapshot = await transaction.get(accountRef);

      if (!accountSnapshot.exists) {
        throw Exception("Account does not exist!");
      }

      double currentFunds = accountSnapshot.get('funds')?.toDouble() ?? 0.0;
      double newFunds = currentFunds + amount;

      transaction.update(accountRef, {'funds': newFunds});
    }).catchError((error) {
      print("Failed to add funds: $error");
    });
  }
}


