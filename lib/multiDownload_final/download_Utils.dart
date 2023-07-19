import 'dart:math';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';

import '../trying_method/multipledownlaod.dart';

class DonwloadUtils {
  static Future<void> processButtonPress({
    required String url,
    required String filename,
    required String direactoryname,
    void Function(DownloadTask backgroundDownloadTask)? backgroundtask,
  }) async {
    debugPrint('download started with url $url');
    // start download
    DownloadTask background_taskid = DownloadTask(
      url: url,
      filename: filename, //'zipfile.zip',
      directory: direactoryname, // 'my/directory',
      baseDirectory: BaseDirectory.applicationDocuments,
      updates: Updates.statusAndProgress,
      allowPause: true,
      metaData: '<example metaData>',
    );

    await FileDownloader().enqueue(
      background_taskid,
    );
    debugPrint('download completed with taskid ${background_taskid.taskId}');

    backgroundtask!(background_taskid);
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
}
