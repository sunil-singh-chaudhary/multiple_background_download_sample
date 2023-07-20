import 'dart:convert';

import 'package:background_download_sample/multiDownload_final/download_Utils.dart';
import 'package:background_download_sample/multiDownload_final/listmodel.dart';
import 'package:background_download_sample/multiDownload_final/taskwidget.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/video_model.dart';
import 'Utils.dart';
import 'VideoUtils.dart';
import 'button_state_notifier.dart';
import 'myloadtask.dart';
import 'permission_handler.dart';

class MultiDonwloadListview extends StatefulWidget {
  const MultiDonwloadListview({super.key});

  @override
  State<MultiDonwloadListview> createState() => _MultiDonwloadListviewState();
}

class _MultiDonwloadListviewState extends State<MultiDonwloadListview> {
  List<VideoModel> model = [];
  DownloadTask? backgroundDownloadTask;
  double _kprogress = 0.0;
  ValueNotifier<int> progressIndexNotifier = ValueNotifier<int>(0);
  DownloadModel? donloadModel;
  List<ValueNotifier<ButtonState>> buttonStateNotifiers = [];

  // ButtonState buttonState = ButtonState.download;
  // MyValueNotifier myData = MyValueNotifier();

  @override
  void initState() {
    super.initState();
    initDonwloader(); //init downloader
    Utils.loadjsonfromAssets().then(
      //load json from assets
      (value) {
        List<dynamic> list = json.decode(value);
        model = list.map((e) => VideoModel.fromJson(e)).toList();
        setState(
          () {
            donloadModel = DownloadModel(itemCount: model.length);
            buttonStateNotifiers = List.generate(model.length,
                (_) => ValueNotifier<ButtonState>(ButtonState.download));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: model.length,
        itemBuilder: (context, index) {
          MyDownloadTask listModel = donloadModel!.downloadTaskList[index];
          debugPrint('list index is $index-- ${buttonStateNotifiers[index]}');

          return ListTile(
            leading: CircleAvatar(
              radius: 24,
              child: Center(
                child: Text('$index'),
              ),
            ),
            title: Text(model[index].author),
            subtitle: Text(model[index].description),
            trailing: SizedBox(
              height: 40,
              width: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  listModel.downloadInProgress //need progressindex
                      ? CircularProgressIndicator(
                          value: (listModel.listProgress),
                          //track progress from notification click or list click imp
                          backgroundColor: Colors.green,
                          strokeWidth: 4,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.red),
                        )
                      : GestureDetector(
                          onTap: () async {
                            if (buttonStateNotifiers[index].value ==
                                ButtonState.completed) {
                              // debugPrint('completed video $index');
                              buttonStateNotifiers[progressIndexNotifier.value]
                                  .value = ButtonState.completed;
                              setState(() {
                                progressIndexNotifier.value = index;
                                listModel.downloadInProgress = false;
                              });
                            } else {
                              // Pass the index of the tapped item
                              onItemTap(index);
                            }
                          },
                          child: Icon(
                            MyDownloadIcon.getIconData(
                                buttonStateNotifiers[index].value, () {
                              setState(() {});
                            }),
                            color: listModel.downloadComplete
                                ? Colors.black
                                : Colors.green,
                          ),
                        ),
                  donloadModel!.downloadTaskList[index].downloadInProgress
                      ? Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            // Make the Material widget invisible
                            child: InkWell(
                              onTap: () async {
                                DownloadTask pauseResumetaskID = donloadModel!
                                    .downloadTaskList[index].downloadTask!;

                                if (buttonStateNotifiers[index].value ==
                                    ButtonState.pause) {
                                  buttonStateNotifiers[
                                          progressIndexNotifier.value]
                                      .value = ButtonState.resume;
                                  //error here on pause and resume on multiple list dodwnload
                                  progressIndexNotifier.value = index;
                                  VideoUtils.pauseDownload(pauseResumetaskID);
                                } else if (buttonStateNotifiers[index].value ==
                                    ButtonState.resume) {
                                  // debugPrint('RESUME ELSE-- $ListbuttonStates');
                                  buttonStateNotifiers[index].value =
                                      ButtonState.pause;
                                  //error here on pause and resume on multiple list dodwnload

                                  progressIndexNotifier.value = index;

                                  VideoUtils.resumeDownload(pauseResumetaskID);
                                }
                              },
                              child: Icon(
                                MyDownloadIcon.getIconData(
                                    buttonStateNotifiers[index].value, () {
                                  setState(() {});
                                }),
                                //state as per in list
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void myNotificationTapCallback(Task task, NotificationType notificationType) {
    debugPrint('notification $notificationType for taskId ${task.taskId}');
  }

  void initDonwloader() {
    FileDownloader()
        .registerCallbacks(
            taskNotificationTapCallback: myNotificationTapCallback)
        .configureNotificationForGroup(FileDownloader.defaultGroup,
            tapOpensFile: true,
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
            complete: const TaskNotification(
                'Download {filename}', 'Download complete'),
            tapOpensFile: true); // dog can also open directly from tap
    // Listen to updates and process
    FileDownloader().updates.listen((update) {
      if (update is TaskStatusUpdate) {
        for (int i = 0; i < donloadModel!.downloadTaskList.length; i++) {
          DownloadTask task = donloadModel!.downloadTaskList[i].downloadTask!;
          if (task == update.task) {
            TaskStatus status = update.status;

            // Update button state directly based on TaskStatus
            if (status == TaskStatus.running || status == TaskStatus.enqueued) {
              buttonStateNotifiers[i].value = ButtonState.pause;
            } else if (status == TaskStatus.paused) {
              buttonStateNotifiers[i].value = ButtonState.resume;
            } else if (status == TaskStatus.canceled) {
              buttonStateNotifiers[i].value = ButtonState.download;
            }
            break; // Break loop once the corresponding task is found and updated
          }
        }
      } else if (update is TaskProgressUpdate) {
        int taskIndex = donloadModel!.downloadTaskList
            .indexWhere((task) => task.downloadTask == update.task);

        setState(() {
          progressIndexNotifier.value = taskIndex;

          MyDownloadTask modellist =
              donloadModel!.downloadTaskList[progressIndexNotifier.value];

          modellist.listProgress = update.progress;

          if (update.progress >= 1) {
            // Download completed
            modellist.downloadInProgress = false;
            modellist.downloadComplete = true;
            buttonStateNotifiers[progressIndexNotifier.value].value =
                ButtonState.completed;
          }
        });
      }
    });
  }

  void onItemTap(int index) async {
    progressIndexNotifier.value = index;

    String url = model[progressIndexNotifier.value].videoUrl;
    String randomefilename = DonwloadUtils.generateRandomFileName('mp4');
    bool hasPermission = await PermissionHandler.requestPermission();
    if (!hasPermission) {
      debugPrint('storage Permission denied');
      return;
    }

    // Get the corresponding MyDownloadTask
    MyDownloadTask listModel =
        donloadModel!.downloadTaskList[progressIndexNotifier.value];

    // Start the download
    setState(() {
      listModel.downloadInProgress = true;
      listModel.downloadComplete = false;
    });

    DonwloadUtils.processButtonPress(
      url: url,
      filename: randomefilename,
      direactoryname: 'Myvideo/Direactory',
      backgroundtask: (backgroundtaskid) {
        buttonStateNotifiers[progressIndexNotifier.value].value =
            ButtonState.pause;

        setState(() {
          backgroundDownloadTask = backgroundtaskid;
          listModel.downloadTask = backgroundDownloadTask;
          // Update button state to pause
        });
      },
    );
  }

  void updateButtonState(int taskIndex, TaskStatus status) {
    if (status == TaskStatus.running || status == TaskStatus.enqueued) {
      buttonStateNotifiers[taskIndex].value = ButtonState.pause;
    } else if (status == TaskStatus.paused) {
      buttonStateNotifiers[taskIndex].value = ButtonState.resume;
    } else if (status == TaskStatus.canceled) {
      buttonStateNotifiers[taskIndex].value = ButtonState.download;
    }

    debugPrint(
        'adding in list index $taskIndex and value is $buttonStateNotifiers');
  }
}
