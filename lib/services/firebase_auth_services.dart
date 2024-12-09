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
        double currentSpentAmount = (budgetDoc['spentAmount'] as num).toDouble();

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

  Future<bool> addBudget(
      BuildContext context,
      String selectedAccount,
      String description,
      int startDate,
      int endDate,
      double amount,
      ) async {
    String userId = _auth.currentUser!.uid;

    // Get the current funds of the account
    DocumentSnapshot accountSnapshot = await _db.collection('users').doc(userId).collection('accounts').doc(selectedAccount).get();
    double currentFunds = (accountSnapshot['funds'] as num).toDouble();

    // Check if there are enough funds for the budget amount
    if (currentFunds < amount) {
      // Show dialog indicating insufficient funds
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Insufficient Funds'),
            content: const Text('You do not have enough funds to create this budget.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return false;
    }

    // If there are enough funds, proceed to add the budget
    Random random = Random();
    int colorValue = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    ).value;

    // Deduct the budget amount from the account's funds
    await _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .update({'funds': FieldValue.increment(-amount)});

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

    return true;
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
    bool isPrioritized
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
      'isPrioritized': isPrioritized,
      'timeStamp': FieldValue.serverTimestamp(),
    });
  }
  Future<void> updateGoal(String selectedAccount, String goalId, Map<String, dynamic> updatedData) async {
    String userId = _auth.currentUser!.uid;

    await _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('goals')
        .doc(goalId)
        .update(updatedData);
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
        .map((snapshot) => snapshot.docs)
        .map((docs) {
      docs.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        final aPriority = aData['isPrioritized'] ?? false;
        final bPriority = bData['isPrioritized'] ?? false;
        if (aPriority && !bPriority) return -1;
        if (!aPriority && bPriority) return 1;
        return 0;
      });
      return docs;
    });
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

  Future<void> createInitialAccount(BuildContext context, String accountName, double? accountFunds) async {
    String userId = _auth.currentUser!.uid;
    DocumentReference accountRef = _db.collection('users').doc(userId).collection('accounts').doc();

    // Add the account to Firestore
    await accountRef.set({
      'accountName': accountName,
      'funds': accountFunds,
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


  Future<void> createAccount(BuildContext context, String accountName) async {
    String userId = _auth.currentUser!.uid;
    DocumentReference accountRef = _db.collection('users').doc(userId).collection('accounts').doc();

    // Add the account to Firestore
    await accountRef.set({
      'accountName': accountName,
      'funds': 0.0,
      'timeStamp': FieldValue.serverTimestamp(),
    });

    // Set the newly created account as selected
    context.read<AccountProvider>().setSelectedAccount(accountRef.id);

    // // Navigate to the dashboard after successful creation
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (BuildContext context) {
    //       return const FinEdger();
    //     },
      //   ),
    // );
  }
  Future<double?> getCurrentFunds(String selectedAccountId) async {
    String userId = _auth.currentUser!.uid;
    DocumentSnapshot accountSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccountId)
        .get();

    if (accountSnapshot.exists) {
      return accountSnapshot['funds']?.toDouble() ?? 0.0;
    }
    return null;
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
extension FirebaseAuthServiceExtension on FirebaseAuthService {
  Future<void> distributeFundsToGoals(String accountId, double remainingFunds, double percentage) async {
    if (accountId.isEmpty) {
      throw ArgumentError("Account ID cannot be null or empty");
    }

    // Get prioritized and non-prioritized goals
    final prioritizedGoals = await getPrioritizedGoals(accountId);
    final nonPrioritizedGoals = await getNonPrioritizedGoals(accountId);

    double prioritizedAmount = remainingFunds * (percentage / 100);
    double nonPrioritizedAmount = remainingFunds - prioritizedAmount;

    // Distribute funds to prioritized goals
    if (prioritizedGoals.isNotEmpty) {
      double amountPerGoal = prioritizedAmount / prioritizedGoals.length;
      for (var goal in prioritizedGoals) {
        if (goal['id'] != null) {
          await updateGoalFunds(accountId, goal['id'], amountPerGoal);
        }
      }
    }

    // Distribute funds to non-prioritized goals
    if (nonPrioritizedGoals.isNotEmpty) {
      double amountPerGoal = nonPrioritizedAmount / nonPrioritizedGoals.length;
      for (var goal in nonPrioritizedGoals) {
        if (goal['id'] != null) {
          await updateGoalFunds(accountId, goal['id'], amountPerGoal);
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> getPrioritizedGoals(String accountId) async {
    // Fetch prioritized goals from Firestore
    final querySnapshot = await _db
        .collection('users')
        .doc(_auth.currentUser?.uid ?? '')
        .collection('accounts')
        .doc(accountId)
        .collection('goals')
        .where('isPrioritized', isEqualTo: true)
        .get();

    return querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Include the document ID
      return data;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getNonPrioritizedGoals(String accountId) async {
    // Fetch non-prioritized goals from Firestore
    final querySnapshot = await _db
        .collection('users')
        .doc(_auth.currentUser?.uid ?? '')
        .collection('accounts')
        .doc(accountId)
        .collection('goals')
        .where('isPrioritized', isEqualTo: false)
        .get();

    return querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Include the document ID
      return data;
    }).toList();
  }

  Future<void> updateGoalFunds(String accountId, String goalId, double amount) async {
    if (goalId.isEmpty) {
      throw ArgumentError("Goal ID cannot be null or empty");
    }

    // Update goal funds in Firestore
    await _db
        .collection('users')
        .doc(_auth.currentUser?.uid ?? '')
        .collection('accounts')
        .doc(accountId)
        .collection('goals')
        .doc(goalId)
        .update({'amountSaved': FieldValue.increment(amount)});
  }
}
