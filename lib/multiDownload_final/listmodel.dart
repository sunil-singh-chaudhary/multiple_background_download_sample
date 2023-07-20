import 'package:background_downloader/background_downloader.dart';

import 'myloadtask.dart';

class DownloadModel {
  List<MyDownloadTask> downloadTaskList = [];

  DownloadModel({
    required int itemCount,
  }) {
    // Initialize the lists with the given number of items
    for (int i = 0; i < itemCount; i++) {
      downloadTaskList.add(
        MyDownloadTask(
          // buttonstate: ButtonState.download,
          downloadInProgress: false,
          downloadComplete: false,
          listProgress: 0.0,
          downloadTask: DownloadTask(
            url: '',
            allowPause: true,
            baseDirectory: BaseDirectory.applicationDocuments,
            filename: 'test',
            directory: 'my/directory',
          ),
          isPaused: false,
        ),
      );
    }
  }
}
