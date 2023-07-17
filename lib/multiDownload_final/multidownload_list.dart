import 'dart:convert';

import 'package:background_download_sample/multiDownload_final/download_Utils.dart';
import 'package:background_download_sample/multiDownload_final/listmodel.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/video_model.dart';
import 'permission_handler.dart';

class MultiDonwloadListview extends StatefulWidget {
  const MultiDonwloadListview({super.key});

  @override
  State<MultiDonwloadListview> createState() => _MultiDonwloadListviewState();
}

class _MultiDonwloadListviewState extends State<MultiDonwloadListview> {
  List<VideoModel>? model;
  // DownloadModel? dwomloadmodelist;
  TaskStatus? downloadTaskStatus;
  DownloadTask? backgroundDownloadTask;
  double _kprogress = 0.0;
  int progressIndex = 0;
  List<bool> downloadInProgress = [];
  List<bool> downloadComplete = [];
  List<double> listProgress = [];
  List<DownloadTask> downloadTaskList = [];
  List<bool> pauseList = [];
  // MyValueNotifier myData = MyValueNotifier();

  /// Process the user tapping on a notification by printing a message
  void myNotificationTapCallback(Task task, NotificationType notificationType) {
    debugPrint(
        'Tapped notification $notificationType for taskId ${task.taskId}');
  }

  @override
  void initState() {
    super.initState();
    initDonwloader(); //init downloader
    loadjsonfromAssets().then(
      //load json from assets
      (value) {
        List<dynamic> list = json.decode(value);
        model = list.map((e) => VideoModel.fromJson(e)).toList();
        setState(() {
          downloadInProgress = List.generate(model!.length, (_) => false);
          downloadComplete = List.generate(model!.length, (_) => false);
          listProgress = List.generate(model!.length, (_) => 0.0);
          pauseList = List.generate(model!.length, (_) => false);
          downloadTaskList = List.generate(model!.length, (index) {
            return DownloadTask(
              url: '',
              filename: 'randoms',
              directory: 'mydireactory',
              baseDirectory: BaseDirectory.applicationDocuments,
              updates: Updates.statusAndProgress,
              allowPause: true,
              metaData: '<example metaData>',
            );
          });
        });
      },
    );
  }

  Future<String> loadjsonfromAssets() async {
    return await rootBundle.loadString("assets/video.json");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: model!.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              radius: 24,
              child: Center(
                child: Text('$index'),
              ),
            ),
            title: Text(model![index].author),
            subtitle: Text(model![index].description),
            trailing: SizedBox(
              height: 40,
              width: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  downloadInProgress[index]
                      ? CircularProgressIndicator(
                          value: (listProgress[index]), //track progress
                          backgroundColor: Colors.green,
                          strokeWidth: 4,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.red),
                        )
                      : GestureDetector(
                          onTap: () async {
                            setState(() {
                              progressIndex = index;
                            });
                            debugPrint('clicked $index');
                            String url = model![index].videoUrl;
                            // simulateDownload(index, url, savePath);
                            String randomefilename =
                                DonwloadUtils.generateRandomFileName('mp4');
                            bool hasPermission =
                                await PermissionHandler.requestPermission();
                            if (!hasPermission) {
                              debugPrint('Permission denied');
                              return;
                            }
                            setState(() {
                              downloadInProgress[index] = true;
                              downloadComplete[index] = false;
                            });

                            DonwloadUtils.processButtonPress(
                              //start download
                              url: url,
                              filename: randomefilename,
                              direactoryname: 'Myvideo/Direactory',
                              backgroundtask: (downloadTask) {
                                setState(() {
                                  backgroundDownloadTask =
                                      downloadTask; //task check
                                  downloadTaskList.insert(
                                      index, backgroundDownloadTask!);
                                });
                              },
                            );
                          },
                          child: GestureDetector(
                            onTap: () {
                              debugPrint('click for deleted');
                            },
                            child: Icon(
                              downloadComplete[
                                      index] //next day work from here delete show when download completed
                                  ? Icons.delete
                                  : Icons.download,
                              color: downloadComplete[index]
                                  ? Colors.black
                                  : Colors.green,
                            ),
                          ),
                        ),
                  downloadInProgress[index]
                      ? Positioned.fill(
                          child: GestureDetector(
                          onTap: () async {
                            debugPrint('starting pause video $index');
                            setState(() {
                              pauseList[index] = !pauseList[index];
                              // Toggle the pause state
                            });

                            pauseList[index]
                                ? await FileDownloader()
                                    .pause(downloadTaskList[index])
                                : await FileDownloader()
                                    .resume(downloadTaskList[index]);
                          },
                          child: Icon(
                            pauseList[index] ? Icons.restart_alt : Icons.pause,
                            color: Colors.blue,
                          ),
                        ))
                      : Container()
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void initDonwloader() {
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
    FileDownloader().updates.listen(
      (update) {
        switch (update) {
          case TaskStatusUpdate _:
            if (update.task == backgroundDownloadTask) {
              setState(() {
                downloadTaskStatus = update.status;
              });
            }

          case TaskProgressUpdate _:
            // myData.updateValue(update.progress);
            debugPrint('update progress of is ${update.progress}');
            setState(() {
              listProgress.insert(progressIndex, update.progress);

              if (update.progress >= 1) {
                //value in 0 and complete is 1 not 100
                //dwonload completed

                downloadInProgress[progressIndex] = false;
                downloadComplete[progressIndex] = true;
                debugPrint(
                    'dwonload completed with status progress--${downloadInProgress[progressIndex]}');
              }
            });

          // pass on to widget for indicator
        }
      },
    );
  }
}
