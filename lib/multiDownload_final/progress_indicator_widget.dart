import 'package:flutter/material.dart';

class CircularProgressIndicatorWidget extends StatelessWidget {
  final Future<double> future;

  const CircularProgressIndicatorWidget({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the future is still in progress, show the CircularProgressIndicator
          return const CircularProgressIndicator(
            value: null, // Since it's still loading, we set value to null
            backgroundColor: Colors.green,
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          );
        } else if (snapshot.hasError) {
          // If there was an error while fetching the progress, handle it here
          // For example, show a placeholder or error message
          return const CircularProgressIndicator(
            value: null, // Since it's still loading, we set value to null
            backgroundColor: Colors.orange,
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          // Use the completed value of the future in CircularProgressIndicator
          double progressValue = snapshot.data ?? 0.0;
          debugPrint('snapshot success ${snapshot.data}');

          return CircularProgressIndicator(
            value: progressValue,
            backgroundColor: Colors.green,
            strokeWidth: 4,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
          );
        } else {
          // Use the completed value of the future in CircularProgressIndicator
          double progressValue = snapshot.data ?? 0.0;
          debugPrint('snapshot else ${snapshot.data}');

          return CircularProgressIndicator(
            value: progressValue,
            backgroundColor: Colors.green,
            strokeWidth: 4,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
          );
        }
      },
    );
  }
}
