import 'package:finedger/constants/constants.dart';
import 'package:finedger/main.dart';
import 'package:finedger/providers/account_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../screens/navigation_pages/goals_page.dart';

class FirebaseAuthService {
  final _auth = FirebaseAuth.instance;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
        'label': 'Welcome to FindEdger!'
      });
      return credential.user;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in process
        return null;
      }

      // Obtain the Google Sign-In authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the obtained credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check if the user already exists in Firestore
      final userDoc = await _db.collection('users').doc(userCredential.user!.uid).get();
      if (!userDoc.exists) {
        // If the user is signing in for the first time, add them to Firestore
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'firstName': googleUser.displayName?.split(' ')[0] ?? '',
          'lastName': googleUser.displayName?.split(' ').skip(1).join(' ') ?? '',
          'phoneNumber': userCredential.user!.phoneNumber ?? '',
          'label': 'Welcome to FindEdger!'
        });
      }

      return userCredential.user;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print(e);
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

  Stream<List<Map<String, dynamic>>> getUserExpenses(String? selectedAccount) {
    String userId = _auth.currentUser!.uid;

    return _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('budgets')
        .get()
        .asStream()
        .asyncExpand((budgetSnapshot) {
      // Cache budget data
      final Map<String, int> budgetColors = {};
      for (var doc in budgetSnapshot.docs) {
        budgetColors[doc['description']] = doc['color'] ?? kBlueColor;
      }

      // Fetch expenses
      return _db
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .doc(selectedAccount)
          .collection('expenses')
          .orderBy('timeStamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          var data = doc.data();
          if (data['category'] != null && budgetColors.containsKey(data['category'])) {
            data['color'] = budgetColors[data['category']];
          } else {
            data['color'] = kBlueColor;
          }
          return data;
        }).toList();
      });
    });
  }

  Future<void> addBudget(
    String selectedAccount,
    String description,
    int startDate,
    int endDate,
    double amount,
  ) async {
    String userId = _auth.currentUser!.uid;
    Random random = Random();
    int colorValue = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    ).value;

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

  Future<void> updateBudget(
    String selectedAccount,
    String budgetId,
    Map<String, dynamic> updatedFields,
  ) async {
    String userId = _auth.currentUser!.uid;

    // Update the budget document in the selected account
    await _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('budgets')
        .doc(budgetId)
        .update(updatedFields);
  }

  Stream<List<DocumentSnapshot>> getArchivedGoalsListView(String selectedAccount) {
    String userId = _auth.currentUser!.uid;
    return _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('archived_goals')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<void> deleteGoal(String selectedAccount, String goalId) async {
    String userId = _auth.currentUser!.uid;
    await _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('goals')
        .doc(goalId)
        .delete();
  }

  Future<void> deleteArchivedGoal(String selectedAccount, String goalId) async {
    String userId = _auth.currentUser!.uid;
    await _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('archived_goals')
        .doc(goalId)
        .delete();
  }

  Future<void> archiveGoal(String selectedAccount, String goalId) async {
    String userId = _auth.currentUser!.uid;
    DocumentSnapshot goalSnapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('goals')
        .doc(goalId)
        .get();

    if (goalSnapshot.exists) {
      Map<String, dynamic> goalData = goalSnapshot.data() as Map<String, dynamic>;
      await _db
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .doc(selectedAccount)
          .collection('archived_goals')
          .doc(goalId)
          .set(goalData);
      await deleteGoal(selectedAccount, goalId);
    }
  }

  Future<DocumentSnapshot> getGoalById(String selectedAccount, String goalId) {
    String userId = _auth.currentUser!.uid;
    return _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('goals')
        .doc(goalId)
        .get();
  }

  Future<void> addGoalFunds(String selectedAccount, String goalId, double amountToAdd) async {
    String userId = _auth.currentUser!.uid;

    DocumentReference goalRef =
        _db.collection('users').doc(userId).collection('accounts').doc(selectedAccount).collection('goals').doc(goalId);

    try {
      // Get the current goal details
      DocumentSnapshot snapshot = await goalRef.get();
      double currentSavedAmount = (snapshot.get('amountSaved') as num).toDouble() ?? 0.00;
      String goalName = snapshot.get('description') ?? 'Unknown Goal';

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

      // Add the transaction to goalFundsHistory
      await _db
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .doc(selectedAccount)
          .collection('goalFundsHistory')
          .add({
        'goalId': goalId,
        'goalName': goalName,
        'addedAmount': amountToAdd,
        'date': DateTime.now().millisecondsSinceEpoch,
        'timeStamp': FieldValue.serverTimestamp(),
      });

      print("Funds added successfully!");
    } catch (error) {
      print("Failed to add funds: $error");
    }
  }

  Stream<List<Map<String, dynamic>>> getUserBudgets(String selectedAccount) {
    String userId = _auth.currentUser!.uid;

    return _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('budgets')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              // Map document data and include document ID
              return {
                ...doc.data(),
                'id': doc.id,
              };
            }).where((doc) {
              // Ensure expired budgets are also retrieved
              final endDate = (doc['endDate'] as num?)?.toInt();
              return endDate != null; // Return all budgets, expired or not
            }).toList());
  }

  Future<double> getAccountFunds(String selectedAccount) async {
    String userId = _auth.currentUser!.uid;

    try {
      // Get the account document for the selected account
      DocumentSnapshot accountSnapshot =
          await _db.collection('users').doc(userId).collection('accounts').doc(selectedAccount).get();

      if (accountSnapshot.exists) {
        // Retrieve the funds value from the account document
        double funds = accountSnapshot.get('funds')?.toDouble() ?? 0.0;
        return funds;
      } else {
        return 0.0; // Return 0 if the account document does not exist
      }
    } catch (e) {
      // Handle any errors (e.g., if the document does not exist or another issue occurs)
      print('Error fetching account funds: $e');
      return 0.0;
    }
  }

  Future<void> deleteBudget(String selectedAccount, String budgetId) async {
    String userId = _auth.currentUser!.uid;

    await _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('budgets')
        .doc(budgetId)
        .delete();
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

  Stream<List<DocumentSnapshot>> getUserGoalsListView(String selectedAccount) {
    String userId = _auth.currentUser!.uid;

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

  Stream<List<DocumentSnapshot>> getGoalFundsHistory(String selectedAccount) {
    String userId = _auth.currentUser!.uid;

    return _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('goalFundsHistory')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Stream<List<GoalData>> getUserGoalsChart(String? selectedAccount) {
    String userId = _auth.currentUser!.uid;
    return _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('goals')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return GoalData(
          description: data['description'] ?? 'No description',
          targetAmount: (data['targetAmount'] ?? 1.0).toDouble(), // Default to avoid division by zero
          savedAmount: (data['amountSaved'] ?? 0.0).toDouble(),
          color: Color(data['color'] ?? Colors.grey.value),
        );
      }).toList();
    });
  }

  Future<Map<String, dynamic>?> getUserFirstName() async {
    String userId = _auth.currentUser!.uid;
    DocumentSnapshot snapshot = await _db.collection('users').doc(userId).get();
    return snapshot.data() as Map<String, dynamic>?;
  }

  Stream<Map<String, dynamic>?> getUserFirstNameStream() {
    String userId = _auth.currentUser!.uid;
    return _db.collection('users').doc(userId).snapshots().map((snapshot) {
      return snapshot.data() as Map<String, dynamic>?;
    });
  }

  Stream<QuerySnapshot> expenseData(String selectedAccount) {
    String userId = _auth.currentUser!.uid;

    return _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('expenses')
        .orderBy('timeStamp', descending: true)
        .snapshots();
  }

  Future<void> createInitialAccount(BuildContext context, String accountName) async {
    String userId = _auth.currentUser!.uid;
    DocumentReference accountRef = _db.collection('users').doc(userId).collection('accounts').doc();

    // Add the account to Firestore
    await accountRef.set({
      'accountName': accountName,
      'funds': 0,
      'timeStamp': FieldValue.serverTimestamp(),
    });

    // Set the newly created account as selected
    context.read<AccountProvider>().setSelectedAccount(accountRef.id);

    // Navigate to the dashboard after successful creation
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const FinEdger();
        },
      ),
    );
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
