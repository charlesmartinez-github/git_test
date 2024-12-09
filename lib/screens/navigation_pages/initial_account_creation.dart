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
  final _accountFundsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _firebase = FirebaseAuthService();
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.075,
            vertical: screenHeight * 0.10,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _initialAccountAndFunds(controller: _accountNameController, hintText: 'Create initial account', keyboardType: TextInputType.text),
                    const SizedBox(height: 10.0,),
                    _initialAccountAndFunds(controller: _accountFundsController, hintText: 'Enter your desired funds', keyboardType: TextInputType.number)
                  ],
                )
              ),
              const SizedBox(height: 15.0),
              SmallButton(
                  buttonLabel: 'Create',
                  onPress: () {
                    if (_formKey.currentState!.validate()) {
                      double accountFunds = double.tryParse(_accountFundsController.text.replaceAll(',', '')) ?? 0.0;
                      _firebase.createInitialAccount(context, _accountNameController.text, accountFunds);
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget _initialAccountAndFunds({required TextEditingController controller, required String hintText, required TextInputType keyboardType}) {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return 'This field cannot be empty!';
        }
        return null;
      },
      controller: controller,
      enableSuggestions: true,
      autocorrect: true,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: kBlueColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: kBlueColor,
          ),
        ),
        fillColor: Colors.white,
        filled: true,
        border: const OutlineInputBorder(),
        hintText: hintText,
        hintStyle: const TextStyle(color: kGrayColor, fontSize: 15.0),
        contentPadding: const EdgeInsets.fromLTRB(15.0, 8.0, 8.0, 8.0),
      ),
    );
  }
}
