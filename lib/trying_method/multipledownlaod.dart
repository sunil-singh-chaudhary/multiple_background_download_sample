import 'dart:async';

import 'package:background_download_sample/trying_method/value_notifier.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';

import 'download_const.dart';

enum ButtonState { download, cancel, pause, resume, reset }

class MultipleDonwloadPauseResume extends StatefulWidget {
  const MultipleDonwloadPauseResume({super.key});

  @override
  State<MultipleDonwloadPauseResume> createState() =>
      _MultipleDonwloadPauseResumeState();
}

class _MultipleDonwloadPauseResumeState
    extends State<MultipleDonwloadPauseResume> {
  final buttonTexts = ['Download', 'Cancel', 'Pause', 'Resume', 'Reset'];

  ButtonState buttonState = ButtonState.download;

  TaskStatus? downloadTaskStatus;
  DownloadTask? backgroundDownloadTask;
  // MyValueNotifier myData = MyValueNotifier(0.0);

  /// Process the user tapping on a notification by printing a message
  void myNotificationTapCallback(Task task, NotificationType notificationType) {
    debugPrint(
        'Tapped notification $notificationType for taskId ${task.taskId}');
  }

  @override
  void initState() {
    super.initState();

    FileDownloader()
        .registerCallbacks(
            taskNotificationTapCallback: myNotificationTapCallback)
        .configureNotificationForGroup(FileDownloader.defaultGroup,
            // For the main download button
            // which uses 'enqueue' and a default group
            running: const TaskNotification(
                'Download {filename}', 'File: {filename} - {progress}'),
            complete: const TaskNotification(
                'Download {filename}', 'Download complete'),
            error: const TaskNotification(
                'Download {filename}', 'Download failed'),
            paused: const TaskNotification(
                'Download {filename}', 'Paused with metadata {metadata}'),
            progressBar: true)
        .configureNotification(
            // for the 'Download & Open' dog picture
            // which uses 'download' which is not the .defaultGroup
            // but the .await group so won't use the above config
            complete: const TaskNotification(
                'Download {filename}', 'Download complete'),
            tapOpensFile: true); // dog can also open directly from tap

    // Listen to updates and process
    FileDownloader().updates.listen((update) {
      switch (update) {
        case TaskStatusUpdate _:
          if (update.task == backgroundDownloadTask) {
            buttonState = switch (update.status) {
              TaskStatus.running || TaskStatus.enqueued => ButtonState.pause,
              TaskStatus.paused => ButtonState.resume,
              _ => ButtonState.reset
            };
            setState(() {
              downloadTaskStatus = update.status;
            });
          }

        case TaskProgressUpdate _:
        // myData.updateValue(update.progress);
// pass on to widget for indicator
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('background_downloader example app'),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: ElevatedButton(
              onPressed: processButtonPress,
              child: Text(
                buttonTexts[buttonState.index],
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.white),
              ),
            )),
            // ValueListenableBuilder<double>(
            //   valueListenable: myData,
            //   builder: (context, value, child) {
            //     return SizedBox(
            //       height: 40,
            //       width: 40,
            //       child: CircularProgressIndicator(
            //         backgroundColor: Colors.green,
            //         value: value,
            //         valueColor:
            //             const AlwaysStoppedAnimation<Color>(Colors.black),
            //       ),
            //     );
            //   },
            // )
          ],
        ),
      )),
    );
  }

  // Existing processButtonPress() function
  Future<void> processButtonPress() async {
    // await DownloadUtils.processButtonPress(
    //   buttonState,
    //   downloadTaskStatus,
    //   backgroundDownloadTask,
    //   (states) {
    //     setState(() {
    //       buttonState = states;
    //     });
    //   },
    // );
  }
}
