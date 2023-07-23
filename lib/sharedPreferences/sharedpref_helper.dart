import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _progressKeyPrefix = 'progress_';
  static SharedPreferencesHelper? _instance;
  late SharedPreferences _prefs;

  factory SharedPreferencesHelper() {
    _instance ??= SharedPreferencesHelper._();
    return _instance!;
  }

  SharedPreferencesHelper._();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveProgress(String taskId, double progress) async {
    debugPrint('saving pref --$progress');
    await _prefs.setDouble(_progressKeyPrefix + taskId, progress);
  }

  Future<double?> fetchProgress(String taskId) async {
    debugPrint('fetching --${_prefs.getDouble(_progressKeyPrefix + taskId)}');
    return _prefs.getDouble(_progressKeyPrefix + taskId);
  }
}
