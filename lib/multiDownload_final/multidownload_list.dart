import 'dart:convert';

import 'package:background_download_sample/multiDownload_final/download_Utils.dart';
import 'package:background_download_sample/multiDownload_final/listmodel.dart';
import 'package:background_download_sample/multiDownload_final/progress_indicator_widget.dart';
import 'package:background_download_sample/multiDownload_final/sharedpreferenceprovider.dart';
import 'package:background_download_sample/multiDownload_final/taskwidget.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';

import '../model/video_model.dart';
import 'Utils.dart';
import 'VideoUtils.dart';
import 'button_state_notifier.dart';
import 'myloadtask.dart';
import 'permission_handler.dart';
import 'sharedpref_helper.dart';

class MultiDonwloadListview extends StatefulWidget {
  const MultiDonwloadListview({super.key});

  @override
  State<MultiDonwloadListview> createState() => _MultiDonwloadListviewState();
}

class _MultiDonwloadListviewState extends State<MultiDonwloadListview> {
  SharedPreferencesHelper? sharedPreferencesHelper;
  ValueNotifier<String> taskIDprogress = ValueNotifier<String>('');
  ValueNotifier<double> taskProgress = ValueNotifier<double>(0.0);
  List<VideoModel> model = [];
  DownloadTask? backgroundDownloadTask;
  DownloadModel? donloadModel;
  List<ValueNotifier<ButtonState>> buttonStateNotifiers = [];
  ValueNotifier<int> progressIndexNotifier = ValueNotifier<int>(0);
  bool _isInitialized = false;
  MyDownloadTask? listModelTaskList;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Access the SharedPreferencesHelper using SharedPreferencesProvider
      sharedPreferencesHelper =
          SharedPreferencesProvider.of(context)!.sharedPreferencesHelper;
      _isInitialized = true;
    }
  }

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
      appBar: AppBar(
        title: const Text('Support MultiDownload'),
      ),
      body: ListView.builder(
        itemCount: model.length,
        itemBuilder: (context, index) {
          listModelTaskList = donloadModel!.downloadTaskList[index];

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
                  listModelTaskList!.downloadInProgress //need progressindex
                      ? CircularProgressIndicatorWidget(
                          future: DonwloadUtils.getProgressValue(
                              listModelTaskList!.listProgress,
                              listModelTaskList!,
                              buttonStateNotifiers[index],
                              sharedPreferencesHelper),
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
                                listModelTaskList!.downloadInProgress = false;
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
                            color: listModelTaskList!.downloadComplete
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
    // Listen to updates and process
    FileDownloader().updates.listen((update) {
      if (update is TaskStatusUpdate) {
        for (int i = 0; i < donloadModel!.downloadTaskList.length; i++) {
          DownloadTask task = donloadModel!.downloadTaskList[i].downloadTask!;
          if (task == update.task) {
            TaskStatus status = update.status;
            updateButtonState(i, status);
            break;
          }
        }
      } else if (update is TaskProgressUpdate) {
        //find the index of taskid saved in list
        int taskIndex = donloadModel!.downloadTaskList
            .indexWhere((task) => task.downloadTask == update.task);

        progressIndexNotifier.value = taskIndex;
        MyDownloadTask? modellist;
        setState(() {
          modellist = donloadModel!.downloadTaskList[
              progressIndexNotifier.value]; //update for circular
          modellist!.listProgress = update.progress;
        });

        if (update.progress >= 1) {
          // Download completed
          modellist!.downloadInProgress = false;
          modellist!.downloadComplete = true;
          buttonStateNotifiers[progressIndexNotifier.value].value =
              ButtonState.completed;
        }
        if (update.progress > 0) {
          //this is important because it return - value on pause
          taskProgress.value = update.progress;
          debugPrint('adding is ${update.progress}');
          taskIDprogress.value = modellist!.downloadTask!.taskId;
        }
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
    MyDownloadTask? listModel;

    // Start the download
    setState(() {
      listModel = donloadModel!
          .downloadTaskList[progressIndexNotifier.value]; //update for circular
      listModel!.downloadInProgress = true;
      listModel!.downloadComplete = false;
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
          listModel!.downloadTask = backgroundDownloadTask;
          // Update button state to pause
        });
      },
    );
  }

  void updateButtonState(int taskIndex, TaskStatus status) {
    if (status == TaskStatus.running || status == TaskStatus.enqueued) {
      buttonStateNotifiers[taskIndex].value = ButtonState.pause;
    } else if (status == TaskStatus.paused) {
      debugPrint('id is ${taskIDprogress.value}');
      debugPrint('progress is ${taskProgress.value}');
      // Save the progress to SharedPreferences whenever it is updated
      sharedPreferencesHelper?.saveProgress(
        taskIDprogress.value,
        taskProgress.value,
      );
      buttonStateNotifiers[taskIndex].value = ButtonState.resume;
    } else if (status == TaskStatus.canceled) {
      buttonStateNotifiers[taskIndex].value = ButtonState.download;
    }
  }
}
