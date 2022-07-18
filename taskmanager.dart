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
String taskDetails = '';

void addItem(String itemTitle, DateTime itemDateTime, String itemDetails) {
  boardData[0].items?.add(BoardItemObject(
      title: itemTitle, dateTime: itemDateTime, details: itemDetails));
}

class TaskStorage {
  Future<String> get _localPath async {
    final directory = (await getApplicationDocumentsDirectory()).path;

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
  DateTime date = DateTime.now();
  String dropdownValue = 'To-Do';

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void setTaskType(String type) {
    setState(() => taskType = type);
  }

  Future<File> _saveTask() {
    setState(() {
      taskName = nameController.text;
      taskDetails = descriptionController.text;
    });
    var file = widget.storage.writeTask(taskDetails);

    return widget.storage.writeTask(taskDetails);
  }

  void _showPath() {
    setState(() {
      TaskStorage()._localPath.then((value) {
        nameController.text = value;
      });
    });
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
                            initialDate: date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100));

                        if (newDate == null) return;
                        setState(() => date = newDate);
                      },
                    )),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      textAlign: TextAlign.left,
                      '${date.day}/${date.month}/${date.year}'),
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
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "DESCRIPTION",
                    border: InputBorder.none,
                  ),
                ),
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
                    onTap: (() {})),
                SpeedDialChild(
                    label: 'SAVE TASK',
                    child: const Icon(Icons.save),
                    onTap: (() => {
                          setTaskType(dropdownValue),
                          //addItem(taskName, date, taskDetails),
                          _saveTask(),
                          pageController.jumpToPage(1)
                        }))
              ],
            )));
  }
}
