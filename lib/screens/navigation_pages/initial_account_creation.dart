import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finedger/main.dart';
import 'package:finedger/providers/account_provider.dart';
import 'package:finedger/services/firebase_auth_services.dart';
import 'package:finedger/widgets/for_gettingstarted.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/constants.dart';

class InitialAccountCreation extends StatefulWidget {
  const InitialAccountCreation({super.key});

  @override
  State<InitialAccountCreation> createState() => _InitialAccountCreationState();
}

class _InitialAccountCreationState extends State<InitialAccountCreation> {
  final _accountNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _firebase = FirebaseAuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
              key: _formKey,
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Match your password';
                  }
                  if (value != _accountNameController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                controller: _accountNameController,
                enableSuggestions: true,
                autocorrect: true,
                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: InputBorder.none,
                  hintText: 'Create an account',
                  hintStyle: TextStyle(color: kGrayColor, fontSize: 15.0),
                  contentPadding: EdgeInsets.fromLTRB(15.0, 8.0, 8.0, 8.0),
                ),
              ),
            ),
            const SizedBox(height: 15.0),
            SmallButton(
                buttonLabel: 'Save',
                onPress: (){
                  if(_formKey.currentState!.validate()){
                    _firebase.createInitialAccount(context, _accountNameController.text);

                  }
                })
          ],
        ),
      ),
    );
  }

}

