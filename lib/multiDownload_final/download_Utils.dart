import 'dart:math';

import 'package:background_download_sample/multiDownload_final/sharedpref_helper.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';

import 'button_state_notifier.dart';
import 'myloadtask.dart';

class DonwloadUtils {
  static Future<void> processButtonPress({
    required String url,
    required String filename,
    required String direactoryname,
    void Function(DownloadTask backgroundDownloadTask)? backgroundtask,
  }) async {
    debugPrint('download started with url $url');
    // start download
    DownloadTask backgroundTaskid = DownloadTask(
      url: url,
      filename: filename, //'zipfile.zip',
      directory: direactoryname, // 'my/directory',
      baseDirectory: BaseDirectory.applicationDocuments,
      updates: Updates.statusAndProgress,
      allowPause: true,
      metaData: '<example metaData>',
    );

    await FileDownloader().enqueue(
      backgroundTaskid,
    );

    backgroundtask!(backgroundTaskid);
  }

  static String generateRandomFileName(String extension) {
    final random = Random();
    String randomString = DateTime.now().millisecondsSinceEpoch.toString() +
        random.nextInt(1000).toString();
    return '$randomString.$extension';
  }

  static ButtonState getButtonState(TaskStatus status) {
    if (status == TaskStatus.running || status == TaskStatus.enqueued) {
      return ButtonState.pause;
    } else if (status == TaskStatus.paused) {
      return ButtonState.resume;
    } else if (status == TaskStatus.complete) {
      return ButtonState.completed;
    } else {
      return ButtonState.download;
    }
  }

  static Future<double> getProgressValue(
    double pGress,
    MyDownloadTask listModel,
    ValueNotifier<ButtonState> buttonState,
    SharedPreferencesHelper? sharedPreferencesHelper,
  ) async {
    if (buttonState.value == ButtonState.resume) {
      // Return the progress from shared preferences when the button is in 'pause' or 'resume' state
      debugPrint('buttonstate pause resume -${listModel.downloadTask!.taskId}');
      return await sharedPreferencesHelper!
              .fetchProgress(listModel.downloadTask!.taskId) ??
          0.0;
    } else if (listModel.downloadComplete && listModel.downloadTask != null) {
      // Return the progress from shared preferences when the download is complete
      debugPrint('buttonstate shared -');
      return await sharedPreferencesHelper!
              .fetchProgress(listModel.downloadTask!.taskId) ??
          0.0;
    } else {
      // Return the progress from the current task when it's not paused, resumed, or complete
      debugPrint('buttonstate progress  $pGress');
      return pGress;
    }
  }
}
