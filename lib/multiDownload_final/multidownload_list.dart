import 'dart:convert';

import 'package:background_download_sample/multiDownload_final/download_Utils.dart';
import 'package:background_download_sample/multiDownload_final/listmodel.dart';
import 'package:background_download_sample/multiDownload_final/taskwidget.dart';
import 'package:background_download_sample/trying_method/multipledownlaod.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/video_model.dart';
import 'myloadtask.dart';
import 'permission_handler.dart';

class MultiDonwloadListview extends StatefulWidget {
  const MultiDonwloadListview({super.key});

  @override
  State<MultiDonwloadListview> createState() => _MultiDonwloadListviewState();
}

class _MultiDonwloadListviewState extends State<MultiDonwloadListview> {
  List<VideoModel> model = [];
  TaskStatus? downloadTaskStatus;
  DownloadTask? backgroundDownloadTask;
  double _kprogress = 0.0;
  int progressIndex = 0;
  DownloadModel? donloadModel;
  // ButtonState buttonState = ButtonState.download;
  // MyValueNotifier myData = MyValueNotifier();

  /// Process the user tapping on a notification by printing a message

  @override
  void initState() {
    super.initState();
    initDonwloader(); //init downloader
    loadjsonfromAssets().then(
      //load json from assets
      (value) {
        List<dynamic> list = json.decode(value);
        model = list.map((e) => VideoModel.fromJson(e)).toList();
        setState(
          () {
            donloadModel = DownloadModel(itemCount: model.length);
          },
        );
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
        itemCount: model.length,
        itemBuilder: (context, index) {
          MyDownloadTask listModel = donloadModel!.downloadTaskList[index];
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
                            if (listModel.buttonstate ==
                                ButtonState.completed) {
                              debugPrint('completed video $index');
                              setState(() {
                                listModel.downloadInProgress = false;
                                listModel.buttonstate = ButtonState.completed;
                                progressIndex = index;
                              });
                            } else {
                              onItemTap(index);
                            }
                            // Pass the index of the tapped item
                          },
                          child: Icon(
                            MyDownloadIcon.getIconData(listModel.buttonstate),
                            color: listModel.downloadComplete
                                ? Colors.black
                                : Colors.green,
                          ),
                        ),
                  listModel.downloadInProgress
                      ? Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            // Make the Material widget invisible

                            child: InkWell(
                              onTap: () async {
                                DownloadTask pauseResumetaskID = donloadModel!
                                    .downloadTaskList[index].downloadTask!;
                                debugPrint(
                                    'index click-- $index and ${listModel.buttonstate}');
                                debugPrint('id is $pauseResumetaskID');
                                if (listModel.buttonstate ==
                                    ButtonState.pause) {
                                  setState(() {
                                    //error here on pause and resume on multiple list dodwnload
                                    listModel.buttonstate = ButtonState.resume;
                                    progressIndex = index;
                                  });
                                  pauseDownload(pauseResumetaskID);
                                  //resume download
                                } else if (listModel.buttonstate ==
                                    ButtonState.resume) {
                                  setState(() {
                                    //error here on pause and resume on multiple list dodwnload
                                    listModel.buttonstate = ButtonState.pause;
                                    progressIndex = index;
                                  });
                                  resumeDownload(pauseResumetaskID);
                                  //pause download
                                }
                              },
                              child: Icon(
                                MyDownloadIcon.getIconData(donloadModel!
                                    .downloadTaskList[index].buttonstate),
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
            debugPrint('status task ${update.task}');

            debugPrint('status bg $backgroundDownloadTask');
            // Find the index of the task in the downloadTaskList
            int taskIndex = donloadModel!.downloadTaskList
                .indexWhere((task) => task.downloadTask == update.task);

            //get the index of taskid when click frm notification otherwise it will return always o

            if (update.task == backgroundDownloadTask) {
              if (taskIndex != -1) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    progressIndex = taskIndex; //update circular from this index

                    downloadTaskStatus = update.status;
                    debugPrint(
                        'status index $taskIndex with progress $downloadTaskStatus');

                    switch (update.status) {
                      case TaskStatus.running:
                      case TaskStatus.enqueued:
                        setState(() {
                          donloadModel!.downloadTaskList[progressIndex]
                              .buttonstate = ButtonState.pause;
                        });
                        //when it is running show pause button with state set for check

                        break;
                      case TaskStatus.paused:
                        debugPrint(
                            'when pause click ${donloadModel!.downloadTaskList[progressIndex].buttonstate}');
                        setState(() {
                          donloadModel!.downloadTaskList[progressIndex]
                              .buttonstate = ButtonState.resume;
                        });

                        break;
                      case TaskStatus.canceled:
                        donloadModel!.downloadTaskList[progressIndex]
                            .buttonstate = ButtonState.download;

                        break;
                      default:
                        donloadModel!.downloadTaskList[progressIndex]
                            .buttonstate = ButtonState.completed;
                        break;
                    }
                  });
                });
              }
            }

          case TaskProgressUpdate _:
            int taskIndex = donloadModel!.downloadTaskList
                .indexWhere((task) => task.downloadTask == update.task);

            // myData.updateValue(update.progress);
            debugPrint('progress taskIndex $taskIndex');
            setState(() {
              progressIndex = taskIndex;
              donloadModel!.downloadTaskList[progressIndex].listProgress =
                  update.progress;
              donloadModel!.downloadTaskList[progressIndex].buttonstate =
                  ButtonState.pause;

              if (update.progress >= 1) {
                //value in 0 and complete is 1 not 100
                //dwonload completed
                donloadModel!
                    .downloadTaskList[progressIndex].downloadInProgress = false;
                donloadModel!.downloadTaskList[progressIndex].downloadComplete =
                    true;
              }
            });
        }
      },
    );
  }

  void onItemTap(int index) async {
    setState(() {
      progressIndex = index;
    });
    String url = model[progressIndex].videoUrl;
    String randomefilename = DonwloadUtils.generateRandomFileName('mp4');
    bool hasPermission = await PermissionHandler.requestPermission();
    if (!hasPermission) {
      debugPrint('storage Permission denied');
      return;
    }

    // Get the corresponding MyDownloadTask
    MyDownloadTask listModel = donloadModel!.downloadTaskList[progressIndex];

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
        setState(() {
          backgroundDownloadTask = backgroundtaskid;
          listModel.downloadTask = backgroundDownloadTask;
          listModel.buttonstate =
              ButtonState.pause; // Update button state to pause
        });
      },
    );
  }

  void pauseDownload(DownloadTask pausetaskID) async {
    debugPrint('pausing $pausetaskID');

    // Implement the pause functionality here
    await FileDownloader().pause(pausetaskID);
  }

  void resumeDownload(DownloadTask pausetaskID) async {
    debugPrint('res8mming $pausetaskID');
    // Implement the resume functionality here
    await FileDownloader().resume(pausetaskID);
  }

  void deleteOrPlay() {
    // Implement the delete or play functionality here
    debugPrint('delete or play');
  }
}
