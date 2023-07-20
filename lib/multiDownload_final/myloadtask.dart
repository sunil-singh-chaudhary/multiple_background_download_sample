import 'package:background_downloader/background_downloader.dart';

class MyDownloadTask {
  bool downloadInProgress;
  bool downloadComplete; //not needed
  double listProgress;
  DownloadTask? downloadTask;
  bool isPaused;
  // ButtonState buttonstate;

  MyDownloadTask({
    required this.downloadInProgress,
    required this.downloadComplete,
    required this.listProgress,
    required this.downloadTask,
    required this.isPaused,
    // required this.buttonstate,
  });
}
