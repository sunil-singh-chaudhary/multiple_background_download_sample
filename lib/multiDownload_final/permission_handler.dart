import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      var status = await Permission.photos.status;
      if (!status.isGranted) {
        status = await Permission.photos.request();
        return status.isGranted;
      }
    }
    return true;
  }
}
