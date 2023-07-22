import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';

class DownloadManager {
  final Function(TaskStatusUpdate update) onTaskStatusUpdates;
  final Function(TaskProgressUpdate update) onTaskProgressUpdates;

  DownloadManager({
    required this.onTaskStatusUpdates,
    required this.onTaskProgressUpdates,
  });

  void myNotificationTapCallback(Task task, NotificationType notificationType) {
    debugPrint('notification $notificationType for taskId ${task.taskId}');
    // Handle notification tap here if needed
  }

  void initDownloader() {
    FileDownloader()
        .registerCallbacks(
            taskNotificationTapCallback: myNotificationTapCallback)
        .configureNotificationForGroup(FileDownloader.defaultGroup,
            tapOpensFile: true,
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
            complete: const TaskNotification(
                'Download {filename}', 'Download complete'),
            tapOpensFile: true);

    FileDownloader().updates.listen((update) {
      if (update is TaskStatusUpdate) {
        onTaskStatusUpdates(update);
      } else if (update is TaskProgressUpdate) {
        onTaskProgressUpdates(update);
      }
    });
  }
}
