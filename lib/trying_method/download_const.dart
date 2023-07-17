// import 'package:background_downloader/background_downloader.dart';

// import 'multipledownlaod.dart';

// class DownloadUtils {
//   static Future<void> processButtonPress(
//       ButtonState buttonState,
//       TaskStatus? downloadTaskStatus,
//       DownloadTask? backgroundDownloadTask,
//       void Function(ButtonState buttonState) setStateCallback) async {
//     switch (buttonState) {
//       case ButtonState.download:
//         // start download
//         backgroundDownloadTask = DownloadTask(
//           url:
//               'https://storage.googleapis.com/approachcharts/test/5MB-test.ZIP',
//           filename: 'zipfile.zip',
//           directory: 'my/directory',
//           baseDirectory: BaseDirectory.applicationDocuments,
//           updates: Updates.statusAndProgress,
//           allowPause: true,
//           metaData: '<example metaData>',
//         );
//         setStateCallback(ButtonState.pause); // Update button text

//         await FileDownloader().enqueue(backgroundDownloadTask);
//         break;
//       case ButtonState.cancel:
//         // cancel download
//         if (backgroundDownloadTask != null) {
//           await FileDownloader()
//               .cancelTasksWithIds([backgroundDownloadTask.taskId]);
//         }
//         setStateCallback(ButtonState.download); // Update button text

//         break;
//       case ButtonState.reset:
//         downloadTaskStatus = null;
//         setStateCallback(ButtonState.download); // Update button text
//         break;
//       case ButtonState.pause:
//         if (backgroundDownloadTask != null) {
//           await FileDownloader().pause(backgroundDownloadTask);
//         }
//         setStateCallback(ButtonState.resume); // Update button text

//         break;
//       case ButtonState.resume:
//         if (backgroundDownloadTask != null) {
//           await FileDownloader().resume(backgroundDownloadTask);
//         }
//         setStateCallback(ButtonState.pause);

//         break;
//     }
//   }
// }
