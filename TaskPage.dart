import 'package:appli_v2/Models/MyBoard.dart';
import 'package:boardview/board_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'Models/MyBoard.dart';
import 'Models/MyTask.dart';

String taskName = '';
String taskType = '';
DateTime taskDate = DateTime.now();

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

void loadList() {
  int numOfBox = 3;
  // clear list first
  //boardData.clear();
  for (int k = 0; k < 3; k++) {
    //add headers;
  }
  for (int i = 0; i < 3; i++) {
    var box = Hive.box('toDoBox');

    switch (i) {
      case 1:
        box = Hive.box('inProgressBox');
        break;
      case 2:
        box = Hive.box('doneBox');
        break;
    }
    if (box.length != 0) {
      for (int j = 0; j < box.length; j++) {
        var itemTitle = box.getAt(i).name;
        var thisDate = box.getAt(i).date;
        String itemDateTime = DateFormat('dd/mm/yyyy').format(thisDate);

        boardData[i]
            .items
            ?.add(BoardItemObject(title: itemTitle, date: itemDateTime));
      }
    }
  }
}

class _TaskPageState extends State<TaskPage> {
  final _toDoBox = Hive.box('toDoBox');
  final _inProgressBox = Hive.box('inProgressBox');
  final _doneBox = Hive.box('doneBox');

  String dropdownValue = 'To-Do';

  final nameController = TextEditingController();

  void setTaskType(String type) => setState(() => taskType = type);
  void setTaskName() => setState(() => taskName = nameController.text);
  // has task name been changed? check box

  void saveTask() {
    // need to check for changes, remove from previous box?
    var thisTask = MyTask(name: taskName, type: taskType, date: taskDate);
    var box = _toDoBox;

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
    box.add(thisTask);
  }

  void printStorage() {
    for (int i = 0; i < _toDoBox.length; i++) {
      print(_toDoBox.getAt(i).name);
      print(_toDoBox.getAt(i).date);
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
                      setTaskType(dropdownValue);
                      setTaskName();
                      printStorage();
                    })),
                SpeedDialChild(
                    label: 'SAVE TASK',
                    child: const Icon(Icons.save),
                    onTap: (() => {
                          setTaskType(dropdownValue),
                          setTaskName(),
                          saveTask()
                        }))
              ],
            )));
  }
}
