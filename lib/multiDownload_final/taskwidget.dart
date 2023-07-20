import 'package:flutter/material.dart';

import 'button_state_notifier.dart';

class MyDownloadIcon {
  static IconData getIconData(ButtonState state, Function() onchnagestate) {
    switch (state) {
      case ButtonState.download:
        onchnagestate;
        return Icons.download;

      case ButtonState.pause:
        onchnagestate;

        return Icons.pause;
      case ButtonState.resume:
        onchnagestate;

        return Icons.play_arrow;
      case ButtonState.completed:
        onchnagestate;

        return Icons.delete;
      default:
        onchnagestate;

        return Icons.download; // You can set a default icon here.
    }
  }
}
