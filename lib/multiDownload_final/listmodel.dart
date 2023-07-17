// import 'package:background_downloader/background_downloader.dart';

// class DownloadModel {
//   List<bool> downloadInProgress = [];
//   List<bool> downloadComplete = [];
//   List<double> listProgress = [];
//   List<DownloadTask> downloadTaskList = [];
//   List<bool> pauseList = [];

//   DownloadModel({
//     required int itemCount,
//   }) {
//     // Initialize the lists with the given number of items
//     for (int i = 0; i < itemCount; i++) {
//       downloadInProgress.add(false);
//       downloadComplete.add(false);
//       listProgress.add(0.0);
//       downloadTaskList.add(DownloadTask(
//         url: '',
//         filename: 'randoms',
//         directory: 'mydireactory',
//         baseDirectory: BaseDirectory.applicationDocuments,
//         updates: Updates.statusAndProgress,
//         allowPause: true,
//         metaData: '<example metaData>',
//       ));
//       pauseList.add(false);
//     }
//   }
// }
