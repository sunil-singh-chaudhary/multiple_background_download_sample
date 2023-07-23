import 'package:background_download_sample/sharedPreferences/sharedpref_helper.dart';
import 'package:background_download_sample/sharedPreferences/sharedpreferenceprovider.dart';
import 'package:flutter/material.dart';

import 'multiDownload_final/multidownload_list.dart';

SharedPreferencesHelper? sharedPreferencesHelper;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferencesHelper
  sharedPreferencesHelper = SharedPreferencesHelper();
  await sharedPreferencesHelper!.init();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SharedPreferencesProvider(
          sharedPreferencesHelper: sharedPreferencesHelper!,
          child: const MultiDonwloadListview()),
    );
  }
}
