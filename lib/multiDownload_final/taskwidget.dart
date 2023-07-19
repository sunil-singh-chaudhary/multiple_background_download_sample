import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';

import '../trying_method/multipledownlaod.dart';

class MyDownloadIcon {
  static IconData getIconData(ButtonState state) {
    switch (state) {
      case ButtonState.download:
        return Icons.download;
      case ButtonState.pause:
        return Icons.pause;
      case ButtonState.resume:
        return Icons.play_arrow;
      case ButtonState.completed:
        return Icons.delete;
      default:
        return Icons.download; // You can set a default icon here.
    }
  }
}
