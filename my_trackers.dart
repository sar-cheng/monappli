import 'dart:async';
import 'package:appli_v2/Models/habit_tile.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MyTrackers extends StatefulWidget {
  const MyTrackers({Key? key}) : super(key: key);

  @override
  State<MyTrackers> createState() => _MyTrackersState();
}

class _MyTrackersState extends State<MyTrackers> {
  // default habits
  List habitList = [
    // [ habitName, habitStarted, timeSpent, timeGoal ]
    ['Exercise', false, 0, 30],
    ['Study', false, 0, 45],
  ];

  Box<dynamic> getBox() => Hive.box('trackerTimeBox');

  void habitStarted(int index) {
    // get start time
    var startTime = DateTime.now();

    // already elapsed
    int elapsedTime = habitList[index][2];

    // change state start/stop
    setState(() {
      habitList[index][1] = !habitList[index][1];
    });

    // if habit active
    if (habitList[index][1]) {
      // timer
      Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          // check when user stops timer
          if (!habitList[index][1]) {
            timer.cancel();
          }

          // time elapsed
          var currentTime = DateTime.now();
          habitList[index][2] = elapsedTime +
              currentTime.second -
              startTime.second +
              60 * (currentTime.minute - startTime.minute) +
              60 * 60 * (currentTime.hour - startTime.hour);
        });
      });
    }
  }

  void settingsOpened(int index) {
    Duration? selectedDuration = Duration(minutes: habitList[index][3]);
    showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
              title: Text('Settings for ${habitList[index][0]}'),

              // Duration selecter
              content: ElevatedButton(
                  onPressed: (() async {
                    selectedDuration = (await showDurationPicker(
                        context: context, initialTime: selectedDuration!));
                    setState(() {
                      habitList[index][3] = selectedDuration!.inMinutes;
                    });
                    saveTimeGoal();
                  }),
                  child: const Text('Select duration')));
        }));
  }

  void saveTimeGoal() async {
    var box = getBox();
    //box.clear();

    // exercise tracker
    await box.putAt(0, habitList[0][3]);
    // study tracker
    await box.putAt(1, habitList[1][3]);
  }

  void loadTimeGoal() {
    var box = getBox();

    try {
      print(box.getAt(0));
      print(box.getAt(1));
      habitList[0][3] = box.getAt(0);
      habitList[1][3] = box.getAt(1);
    } catch (e) {}
  }

  Widget _buildList() {
    return ListView.builder(
        itemCount: habitList.length,
        itemBuilder: ((context, index) {
          return HabitTile(
              habitName: habitList[index][0],
              timerTapped: () => habitStarted(index),
              settingsTapped: () => settingsOpened(index),
              timeSpent: habitList[index][2],
              timeGoal: habitList[index][3],
              habitStarted: habitList[index][1]);
        }));
  }

  @override
  Widget build(BuildContext context) {
    loadTimeGoal();
    return Container(
        color: Colors.transparent,
        child:
            Padding(padding: const EdgeInsets.all(16.0), child: _buildList()));
  }
}
