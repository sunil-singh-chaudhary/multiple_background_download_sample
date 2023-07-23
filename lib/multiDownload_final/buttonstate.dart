import 'package:background_downloader/background_downloader.dart';

import '../utils/button_state_notifier.dart';

class ButtonStateCallBack {
  final Function(ButtonState buttonstate, int index) onButtonStateChanged;

  ButtonStateCallBack({
    required this.onButtonStateChanged,
  });

  void updateButtonState(int taskIndex, TaskStatus status) {
    if (status == TaskStatus.running || status == TaskStatus.enqueued) {
      onButtonStateChanged(ButtonState.pause, taskIndex);
    } else if (status == TaskStatus.paused) {
      onButtonStateChanged(ButtonState.resume, taskIndex);
    } else if (status == TaskStatus.canceled) {
      onButtonStateChanged(ButtonState.canceled, taskIndex);
    }
  }
}
