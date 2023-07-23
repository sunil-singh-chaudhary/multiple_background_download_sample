import 'package:flutter/services.dart';

class Utils {
  static Future<String> loadjsonfromAssets() async {
    return await rootBundle.loadString("assets/video.json");
  }
}
