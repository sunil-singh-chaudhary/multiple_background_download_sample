import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';

class VideoUtils {
  static void pauseDownload(DownloadTask pausetaskID) async {
    debugPrint('pausing $pausetaskID');

    // Implement the pause functionality here
    await FileDownloader().pause(pausetaskID);
  }

  static void resumeDownload(DownloadTask pausetaskID) async {
    debugPrint('res8mming $pausetaskID');
    // Implement the resume functionality here
    await FileDownloader().resume(pausetaskID);
  }

  static void deleteOrPlay() {
    // Implement the delete or play functionality here
    debugPrint('delete or play');
  }
}
