import 'dart:math';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';

class DonwloadUtils {
  static Future<void> processButtonPress({
    required String url,
    required String filename,
    required String direactoryname,
    void Function(DownloadTask backgroundDownloadTask)? backgroundtask,
  }) async {
    debugPrint('download started with url $url');
    // start download
    DownloadTask backgroundDownloadTask = DownloadTask(
      url: url,
      filename: filename, //'zipfile.zip',
      directory: direactoryname, // 'my/directory',
      baseDirectory: BaseDirectory.applicationDocuments,
      updates: Updates.statusAndProgress,
      allowPause: true,
      metaData: '<example metaData>',
    );

    await FileDownloader().enqueue(
      backgroundDownloadTask,
    );
    debugPrint(
        'download completed with taskid ${backgroundDownloadTask.taskId}');

    backgroundtask!(backgroundDownloadTask);
  }

  static String generateRandomFileName(String extension) {
    final random = Random();
    String randomString = DateTime.now().millisecondsSinceEpoch.toString() +
        random.nextInt(1000).toString();
    return '$randomString.$extension';
  }
}
