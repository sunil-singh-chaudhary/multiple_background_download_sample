import 'dart:convert';

import 'package:background_download_sample/DownloadServices/download_Utils.dart';
import 'package:background_download_sample/model/listmodel.dart';
import 'package:background_download_sample/multiDownload_final/progress_indicator_widget.dart';
import 'package:background_download_sample/multiDownload_final/taskwidget.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';

import '../model/video_model.dart';
import '../sharedPreferences/sharedpref_helper.dart';
import '../sharedPreferences/sharedpreferenceprovider.dart';
import '../utils/Utils.dart';
import '../utils/VideoUtils.dart';
import '../utils/button_state_notifier.dart';
import 'buttonstate.dart';
import '../DownloadServices/downloadManager.dart';
import '../model/myloadtask.dart';
import '../permissonHandler/permission_handler.dart';

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
  late MyDownloadTask listModelTaskList;
  late DownloadManager downloadManager;
  late ButtonStateCallBack buttonStateCallBack;

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
    buttonStateCallBack = ButtonStateCallBack(
      //handling button state
      onButtonStateChanged: (buttonstate, index) =>
          handleButtonStateChanged(buttonstate, index),
    );

    initDonwloadeManager(); //init downloader

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
        title: const Text('Support Multi-Download'),
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
                  listModelTaskList.downloadInProgress //need progressindex
                      ? CircularProgressIndicatorWidget(
                          isCanceled: listModelTaskList.isCanceled,
                          future: DonwloadUtils.getProgressValue(
                              listModelTaskList,
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
                                listModelTaskList.downloadInProgress = false;
                              });
                            } else {
                              // Pass the index of the tapped item
                              onDonwloadStart(index);
                            }
                          },
                          child: Icon(
                            MyDownloadIcon.getIconData(
                                buttonStateNotifiers[index].value, () {
                              setState(() {});
                            }),
                            color: listModelTaskList.downloadComplete
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
                                  progressIndexNotifier.value = index;
                                  VideoUtils.pauseDownload(pauseResumetaskID);
                                } else if (buttonStateNotifiers[index].value ==
                                    ButtonState.resume) {
                                  buttonStateNotifiers[index].value =
                                      ButtonState.pause;

                                  progressIndexNotifier.value = index;

                                  VideoUtils.resumeDownload(pauseResumetaskID);
                                } else if (buttonStateNotifiers[index].value ==
                                    ButtonState.download) {
                                  debugPrint('start donwonlaod');
                                  onDonwloadStart(index);
                                } else if (buttonStateNotifiers[index].value ==
                                    ButtonState.canceled) {
                                  setState(() {
                                    listModelTaskList.downloadInProgress =
                                        false; //reset progressbar
                                    listModelTaskList.isCanceled = true;
                                  });
                                }
                              },
                              child: Icon(
                                MyDownloadIcon.getIconData(
                                    buttonStateNotifiers[index].value, () {
                                  setState(() {});
                                }),
                                //state as per in list
                                color: Colors.black,
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

  void onDonwloadStart(int index) async {
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
      listModel!.isCanceled = false;
    });
// start donwloading
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

  void initDonwloadeManager() {
    downloadManager = DownloadManager(
      onTaskStatusUpdates: (update) {
        for (int i = 0; i < donloadModel!.downloadTaskList.length; i++) {
          DownloadTask task = donloadModel!.downloadTaskList[i].downloadTask!;
          if (task == update.task) {
            TaskStatus status = update.status;
            buttonStateCallBack.updateButtonState(i, status);
            break;
          }
        }
      },
      onTaskProgressUpdates: (update) {
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
              ButtonState.completed; //change button state when completed task
        }
        if (update.progress > 0) {
          //this is important because it return (- negative value)  on pause
          taskProgress.value = update.progress;
          debugPrint('adding is ${update.progress}');
          taskIDprogress.value = modellist!.downloadTask!.taskId;
        }
      },
    );
    // Call the initDownloader method to start listening for updates
    downloadManager.initDownloader();
  }

  void handleButtonStateChanged(ButtonState buttonState, int taskIndex) {
    debugPrint('caneceld  $buttonState');

    if (buttonState == ButtonState.pause) {
      buttonStateNotifiers[taskIndex].value = ButtonState.pause;
    } else if (buttonState == ButtonState.resume) {
      // Save the progress to SharedPreferences whenever it is updated
      sharedPreferencesHelper?.saveProgress(
        taskIDprogress.value,
        taskProgress.value,
      );
      buttonStateNotifiers[taskIndex].value = ButtonState.resume;
    } else if (buttonState == ButtonState.canceled) {
      debugPrint('caneceld');
      setState(() {
        listModelTaskList.downloadInProgress = false; //reset progressbar
        donloadModel!.downloadTaskList[taskIndex].isCanceled = true;
      });
      buttonStateNotifiers[taskIndex].value =
          ButtonState.download; //dont need setstate using notifier
    }
  }
}
