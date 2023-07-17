import 'package:background_downloader/background_downloader.dart';

class MyDownloadTask {
  bool downloadInProgress;
  bool downloadComplete;
  double listProgress;
  DownloadTask? downloadTask;
  bool isPaused;

  MyDownloadTask({
    required this.downloadInProgress,
    required this.downloadComplete,
    required this.listProgress,
    required this.downloadTask,
    required this.isPaused,
  });
}
