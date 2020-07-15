import 'package:flutter/material.dart';
import 'package:lockdown_diaries/utils/Classes.dart';
import 'package:lockdown_diaries/utils/Constants.dart';

class ShaderMaskProvider extends ChangeNotifier {

  Filter _filter = Constants.filters[0];

  Filter get filter => _filter;

  updateFilter(Filter updatedFilter) {
    _filter = updatedFilter;
  }
}