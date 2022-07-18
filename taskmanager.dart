import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class TaskStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt'); //path needs to be a variable
  }

  Future<String> readTask() async {
    final file = await _localFile;

    //read
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

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  String taskName = ''; //limit no. of characters and only to alphanum
  String taskDetails = '';

  Future<File> _saveTask() {
    setState(() {
      taskName = nameController.text;
      taskDetails = descriptionController.text;
    });
    return widget.storage.writeTask(taskDetails);
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
                            initialDate: DateTime.now(),
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
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "NEW TASK",
                    border: InputBorder.none,
                  ),
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
                    onTap: (() => _saveTask()))
              ],
            )));
  }
}
