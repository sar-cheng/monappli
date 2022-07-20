import 'main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';
import 'dart:io';
import 'Models/board.dart';
import 'package:hive/hive.dart';
import 'package:hive_generator/hive_generator.dart';

import 'package:path_provider/path_provider.dart';

part 'taskmanager.g.dart';

String taskName = '';
String taskType = '';
DateTime taskDate = DateTime.now();

void addItem(String itemTitle, DateTime itemDateTime) {
  boardData[0]
      .items
      ?.add(BoardItemObject(title: itemTitle, dateTime: itemDateTime));
}

@HiveType(typeId: 1)
class MyTask {
  MyTask({required this.name, required this.type, required this.date});

  @HiveField(0)
  String name;

  @HiveField(1)
  String type;

  @HiveField(2)
  DateTime date;
}

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  /*var _toDoBox = Hive.box('toDoBox');
  var _inProgressBox = Hive.box('inProgressBox');
  var _doneBox = Hive.box('doneBox');*/

  String dropdownValue = 'To-Do';

  final nameController = TextEditingController();

  void setTaskType(String type) => setState(() => taskType = type);
  void setTaskName() => setState(() => taskName = nameController.text);

  /*void saveTask() {
    // need to check for changes, remove from previous box?

    switch (taskType) {
      case 'To-Do':
        setState(() {
          _toDoBox.add(MyTask(name: taskName, type: taskType, date: taskDate));
        });
        break;
      case 'In Progress':
        setState(() {
          _inProgressBox
              .add(MyTask(name: taskName, type: taskType, date: taskDate));
        });
        break;
      case 'Done':
        setState(() {
          _doneBox.add(MyTask(name: taskName, type: taskType, date: taskDate));
        });
        break;
    }
  }*/

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
                      value: dropdownValue,
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
                          dropdownValue = newValue!;
                        });
                      },
                    )),
                const Divider(),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "NEW TASK",
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
                      //setTaskType(dropdownValue);
                      //setTaskName();
                      //print(_toDoBox.length);
                      //print(_toDoBox.getAt(1));
                    })),
                SpeedDialChild(
                    label: 'SAVE TASK',
                    child: const Icon(Icons.save),
                    onTap: (() => {
                          //saveTask()
                        }))
              ],
            )));
  }
}
