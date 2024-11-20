import 'package:flutter/material.dart';

class PageProvider with ChangeNotifier {
  int _currentPageIndex = 0;
  bool _showLatestOnly = true; // Add this line

  int get currentPageIndex => _currentPageIndex;

  // Getter for showLatestOnly
  bool get showLatestOnly => _showLatestOnly;

  // Method to set showLatestOnly
  void setShowLatestOnly(bool value) {
    _showLatestOnly = value;
    notifyListeners();
  }

  void setCurrentPageIndex(int index) {
    _currentPageIndex = index;
    notifyListeners();
  }
}
