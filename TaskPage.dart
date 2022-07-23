import 'package:appli_v2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'Models/MyBoard.dart';
import 'Models/MyTask.dart';

// global task details
String taskName = '';
String taskType = 'To-Do';
DateTime taskDate = DateTime.now();
bool taskIsNew = false;

String oldTaskName = '';
String oldTaskType = 'To-Do';
DateTime oldTaskDate = DateTime.now();

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _toDoBox = Hive.box('toDoBox');
  final _inProgressBox = Hive.box('inProgressBox');
  final _doneBox = Hive.box('doneBox');

  final nameController = TextEditingController(text: taskName);

  void setTaskName() => setState(() => taskName = nameController.text);

  Box<dynamic> getBox() {
    var box;

    switch (taskType) {
      case 'To-Do':
        box = _toDoBox;
        break;
      case 'In Progress':
        box = _inProgressBox;
        break;
      case 'Done':
        box = _doneBox;
        break;
    }

    return box;
  }

  bool nameIsValid() {
    var box = getBox();
    bool isValid = true;
    for (int i = 0; i < box.length; i++) {
      if (taskName == box.getAt(i).name) {
        final notif = SnackBar(
            content: Text(
                'Cannot be saved - there is already a task named $taskName'));
        ScaffoldMessenger.of(context).showSnackBar(notif);
        isValid = false;
      }
    }
    return isValid;
  }

  void updateTask() {
    var box = getBox();
    var thisTask = MyTask(name: taskName, type: taskType, date: taskDate);
    var oldTask = box.get(oldTaskName);
    bool canSave = nameIsValid();

    if (canSave) {
      for (int i = 0; i < box.length; i++) {
        if (oldTask == box.getAt(i)) {
          box.deleteAt(i);
          box.put(taskName, thisTask);
        }
      }

      const notif =
          SnackBar(content: Text('Saved - restart the app to view changes'));
      ScaffoldMessenger.of(context).showSnackBar(notif);
      pageController.jumpToPage(1);
    }
  }

  void saveTask() {
    var thisTask = MyTask(name: taskName, type: taskType, date: taskDate);
    var box = getBox();
    bool canSave = nameIsValid();

    if (canSave) {
      box.put(taskName, thisTask);

      const notif =
          SnackBar(content: Text('Saved - restart the app to view changes'));
      ScaffoldMessenger.of(context).showSnackBar(notif);
      pageController.jumpToPage(1);
    }
  }

  void deleteTask() {
    var box = getBox();
    box.delete(oldTaskName);
  }

  void clearStorage() {
    _toDoBox.clear();
    _inProgressBox.clear();
    _doneBox.clear();
  }

  void printStorage() {
    for (int i = 0; i < _inProgressBox.length; i++) {
      print(_inProgressBox.getAt(i).name);
      print(_inProgressBox.getAt(i).date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
            padding: const EdgeInsets.all(29),
            child: Column(
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      child: const Text("SELECT DATE"),
                      onPressed: () async {
                        DateTime? newDate = await showDatePicker(
                            context: context,
                            initialDate: taskDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100));

                        if (newDate == null) return;
                        setState(() => taskDate = newDate);
                      },
                    )),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      textAlign: TextAlign.left,
                      '${taskDate.day}/${taskDate.month}/${taskDate.year}'),
                ),
                const Divider(),
                Align(
                    alignment: Alignment.topLeft,
                    child: DropdownButton<String>(
                      value: taskType,
                      alignment: Alignment.topLeft,
                      items: <String>['To-Do', 'In Progress', 'Done']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          taskType = newValue!;
                        });
                      },
                    )),
                const Divider(),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "TASK NAME",
                    border: InputBorder.none,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]"))
                  ],
                  maxLength: 200,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                ),
                const Divider(),
              ],
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: Padding(
            padding: const EdgeInsets.all(10),
            child: SpeedDial(
              icon: Icons.add,
              activeIcon: Icons.close,
              spaceBetweenChildren: 4,
              spacing: 3,
              childPadding: const EdgeInsets.all(5),
              backgroundColor: Colors.blue[400],
              visible: true,
              curve: Curves.bounceIn,
              children: [
                SpeedDialChild(
                    label: 'DELETE TASK',
                    child: const Icon(Icons.delete),
                    onTap: (() {
                      //clearStorage();
                      deleteTask();
                      printStorage();

                      pageController.jumpToPage(1);
                    })),
                SpeedDialChild(
                    label: 'SAVE TASK',
                    child: const Icon(Icons.save),
                    onTap: (() => {
                          setTaskName(),
                          if (taskIsNew) {saveTask()} else {updateTask()},
                        }))
              ],
            )));
  }
}
