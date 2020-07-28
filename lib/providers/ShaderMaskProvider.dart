import 'package:flutter/material.dart';
import 'package:navras/utils/Classes.dart';
import 'package:navras/utils/Constants.dart';

class ShaderMaskProvider extends ChangeNotifier {

  Filter _filter = Constants.filters[0];

  Filter get filter => _filter;

  updateFilter(Filter updatedFilter) {
    _filter = updatedFilter;
    notifyListeners();
  }
}