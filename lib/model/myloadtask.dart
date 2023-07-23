import 'package:background_downloader/background_downloader.dart';

class MyDownloadTask {
  bool downloadInProgress;
  bool downloadComplete; //not needed
  bool isCanceled; //not needed
  double listProgress;
  DownloadTask? downloadTask;

  MyDownloadTask({
    required this.isCanceled,
    required this.downloadInProgress,
    required this.downloadComplete,
    required this.listProgress,
    required this.downloadTask,
  });
}
