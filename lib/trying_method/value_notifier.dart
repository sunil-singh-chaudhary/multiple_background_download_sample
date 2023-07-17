import 'package:flutter/material.dart';

class MyValueNotifier extends ValueNotifier<List<double>> {
  MyValueNotifier(List<double> value) : super(value);

  void updateValue(List<double> newValue) {
    value = newValue;
  }
}
