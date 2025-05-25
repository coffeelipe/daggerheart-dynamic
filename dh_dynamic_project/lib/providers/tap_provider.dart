import 'package:flutter/material.dart';

class StatTapProvider extends ChangeNotifier {
  String? tappedStat;
  int modifier = 0;

  void tapStat(String statName, int modifierValue) {
    tappedStat = statName;
    modifier = modifierValue;
    notifyListeners();
  }

  void clear() {
    tappedStat = null;
    modifier = 0;
    notifyListeners();
  }
}
