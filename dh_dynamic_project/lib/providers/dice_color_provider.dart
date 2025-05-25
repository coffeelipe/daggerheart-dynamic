// dice_color_provider.dart
import 'package:flutter/material.dart';
import 'package:daggerheart_dynamic_dice/core/theme/app_pallete.dart';

class DiceColorProvider extends ChangeNotifier {
  Color _hopeColor = Pallete.defaultDieColor;
  Color _fearColor = Pallete.defaultDieColor;

  Color get hopeColor => _hopeColor;
  Color get fearColor => _fearColor;

  void setHopeColor(Color color) {
    _hopeColor = color;
    notifyListeners();
  }

  void setFearColor(Color color) {
    _fearColor = color;
    notifyListeners();
  }
}
