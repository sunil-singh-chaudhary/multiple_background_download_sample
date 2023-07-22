import 'package:background_download_sample/multiDownload_final/sharedpref_helper.dart';
import 'package:flutter/material.dart';

class SharedPreferencesProvider extends InheritedWidget {
  final SharedPreferencesHelper sharedPreferencesHelper;

  SharedPreferencesProvider({
    required this.sharedPreferencesHelper,
    required Widget child,
  }) : super(child: child);

  static SharedPreferencesProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SharedPreferencesProvider>();
  }

  @override
  bool updateShouldNotify(SharedPreferencesProvider oldWidget) {
    return sharedPreferencesHelper != oldWidget.sharedPreferencesHelper;
  }
}
