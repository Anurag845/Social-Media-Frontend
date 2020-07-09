import 'package:flutter/material.dart';

class ShaderMaskProvider extends ChangeNotifier {

  Color _color1 = Colors.transparent;
  Color _color2 = Colors.transparent;

  Color get firstcolor => _color1;
  Color get secondcolor => _color2;

  updateColors(Color c1, Color c2) {
    _color1 = c1;
    _color2 = c2;
    notifyListeners();
  }
}