import 'package:flutter/material.dart';

// Define the ButtonState enum
enum ButtonState { download, pause, resume, completed, canceled }

class ButtonStateNotifier extends ValueNotifier<List<ButtonState>> {
  ButtonStateNotifier(List<ButtonState> value) : super(value);

  void updateValue(List<ButtonState> newValue) {
    value = newValue;
    notifyListeners();
  }
}
