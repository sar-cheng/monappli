import 'main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';
import 'dart:io';
import 'Models/board.dart';

import 'package:path_provider/path_provider.dart';

String taskName = '';
String taskType = '';
DateTime taskDate = DateTime.now();

void addItem(String itemTitle, DateTime itemDateTime) {
  boardData[0]
      .items
      ?.add(BoardItemObject(title: itemTitle, dateTime: itemDateTime));
}

class TaskStorage {
  Future<String> get _localPath async {
    final directory = (await getApplicationDocumentsDirectory()).path;

    //determines which folder to go into depending on the task type
    var localpath = await Directory('$directory/Appli/MyTasks/$taskType')
        .create(recursive: true);

    return localpath.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$taskName.txt');
  }

  Future<String> readTask() async {
    final file = await _localFile;

    // Read the file
    final contents = await file.readAsString();
    return contents;
  }

  Future<File> writeTask(String content) async {
    final file = await _localFile;

    return file.writeAsString(content); //line breaks
  }
}

class TaskPage extends StatefulWidget {
  const TaskPage({super.key, required this.storage});

  final TaskStorage storage;

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  String dropdownValue = 'To-Do';

  final nameController = TextEditingController();

  void setTaskType(String type) => setState(() => taskType = type);
  void setTaskName() => setState(() => taskName = nameController.text);

  Future<File> _saveTask() {
    return widget.storage.writeTask(taskDate.toString());
  }

  void testModule() {
    boardData.forEach((element) {});
  }

  void _showPath(File file) {
    setState(() {
      //TaskStorage()._localFile.then((value) {
      //nameController.text = value.toString();
      //});
      nameController.text = file.toString();
    });
  }

  Future<void> deleteTask(var file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('file not found');
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
                      setState(() {
                        TaskStorage()._localFile.then((value) {
                          File file = value;
                          deleteTask(file);
                          pageController.jumpToPage(1);
                        });
                      });
                    })),
                SpeedDialChild(
                    label: 'SAVE TASK',
                    child: const Icon(Icons.save),
                    onTap: (() => {
                          setTaskType(dropdownValue),
                          setTaskName(),
                          _saveTask(),
                          pageController.jumpToPage(1)
                        }))
              ],
            )));
  }
}
