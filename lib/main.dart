import 'dart:async';
import 'dart:math';

import 'package:background_download_sample/trying_method/multipledownlaod.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';

import 'multiDownload_final/multidownload_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MultiDonwloadListview(),
    );
  }
}
