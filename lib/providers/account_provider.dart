import 'package:flutter/material.dart';

class AccountProvider with ChangeNotifier {
  String? _selectedAccount;

  String? get selectedAccount => _selectedAccount;

  void setSelectedAccount(String account) {
    _selectedAccount = account;
    notifyListeners();
  }
}
