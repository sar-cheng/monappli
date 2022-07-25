import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HabitTile extends StatelessWidget {
  final String habitName;
  final VoidCallback timerTapped;
  final VoidCallback settingsTapped;
  final int timeSpent;
  final int timeGoal;
  final bool habitStarted;

  const HabitTile(
      {Key? key,
      required this.habitName,
      required this.timerTapped,
      required this.settingsTapped,
      required this.timeSpent,
      required this.timeGoal,
      required this.habitStarted})
      : super(key: key);

  // format timer
  String formatToMinSec(int totalSeconds) {
    int totalMins = (totalSeconds / 60).truncate();

    String secs = (totalSeconds % 60).toString();
    String mins = (totalMins % 60).toString().padLeft(2, '0');

    if (secs.length == 1) secs = '0$secs';

    return '$mins:$secs';
  }

  double percentCompleted() => timeSpent / (timeGoal * 60);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: timerTapped,
                      child: SizedBox(
                        height: 60,
                        width: 60,
                        child: Stack(
                          children: [
                            // percentage circle
                            CircularPercentIndicator(
                              radius: 60,
                              percent: percentCompleted() < 1
                                  ? percentCompleted()
                                  : 1,
                              progressColor: percentCompleted() > 0.5
                                  ? (percentCompleted() > 0.75
                                      ? Colors.green
                                      : Colors.orange)
                                  : Colors.red,
                            ),

                            // start button
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Center(
                                  child: Icon(habitStarted
                                      ? Icons.pause
                                      : Icons.play_arrow)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // habit name
                        Text(
                          habitName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        // progress
                        Text(
                            '${formatToMinSec(timeSpent)} / $timeGoal = ${(percentCompleted() * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Colors.grey[400],
                            ))
                      ],
                    ),
                  ],
                ),
                // habit settings
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: settingsTapped,
                    child: const Icon(Icons.settings),
                  ),
                )
              ],
            )));
  }
}
