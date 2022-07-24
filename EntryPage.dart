import 'package:appli_v2/util/MyEntry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'main.dart';

// global task details
String entryName = '';
DateTime entryDate = DateTime.now();
String entryContent = '';
bool entryIsNew = false;

String oldEntryName = '';
DateTime oldEntryDate = DateTime.now();
String oldEntryContent = '';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<EntryPage> {
  final nameController = TextEditingController(text: entryName);
  final contentController = TextEditingController(text: entryContent);

  Box<dynamic> getBox() => Hive.box('entryBox');

  void setEntryName() => setState(() => entryName = nameController.text);
  void setEntryContent() =>
      setState(() => entryContent = contentController.text);

  bool nameIsValid() {
    var box = getBox();
    bool isValid = true;
    for (int i = 0; i < box.length; i++) {
      if (entryName == box.getAt(i).name) {
        final notif = SnackBar(
            content: Text(
                'Cannot be saved - there is already an entry named $entryName'));
        ScaffoldMessenger.of(context).showSnackBar(notif);
        isValid = false;
      }
    }
    return isValid;
  }

  void updateEntry() {
    var box = getBox();
    var thisEntry =
        MyEntry(name: entryName, date: entryDate, content: entryContent);
    var oldTask = box.get(oldEntryName);
    bool canSave = nameIsValid();

    if (canSave) {
      for (int i = 0; i < box.length; i++) {
        if (oldTask == box.getAt(i)) {
          box.deleteAt(i);
          box.put(entryName, thisEntry);

          const notif = SnackBar(
              content: Text('Saved - restart the app to view changes'));
          ScaffoldMessenger.of(context).showSnackBar(notif);
          pageController.jumpToPage(1);
        }
      }
    }
  }

  void saveEntry() {
    var thisEntry =
        MyEntry(name: entryName, date: entryDate, content: entryContent);
    var box = getBox();
    bool canSave = nameIsValid();

    if (canSave) {
      box.put(entryName, thisEntry);

      const notif =
          SnackBar(content: Text('Saved - restart the app to view changes'));
      ScaffoldMessenger.of(context).showSnackBar(notif);
      pageController.jumpToPage(1);
    }
  }

  void clearStorage() {
    var box = Hive.box('entryBox');
    box.clear();
  }

  void printStorage() {
    var box = Hive.box('entryBox');
    for (int i = 0; i < box.length; i++) {
      print(box.getAt(i));
      print(box.getAt(i).name);
      print(box.getAt(i).date);
      print(box.getAt(i).content);
    }
  }

  void deleteEntry() {
    var box = getBox();
    box.delete(oldEntryName);
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
                            initialDate: entryDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100));

                        if (newDate == null) return;
                        setState(() => entryDate = newDate);
                      },
                    )),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      textAlign: TextAlign.left,
                      '${entryDate.day}/${entryDate.month}/${entryDate.year}'),
                ),
                const Divider(),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "ENTRY NAME",
                    border: InputBorder.none,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]"))
                  ],
                  maxLength: 200,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                ),
                const Divider(),
                Expanded(child: LayoutBuilder(builder: (context, constraints) {
                  return SizedBox(
                    height: constraints.maxHeight / 2,
                    child: TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        hintText: "ENTRY DETAILS",
                        border: InputBorder.none,
                      ),
                      expands: true,
                      maxLines: null,
                      maxLength: 2000000,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    ),
                  );
                }))
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
                    label: 'DELETE ENTRY',
                    child: const Icon(Icons.delete),
                    onTap: (() {
                      //clearStorage();
                      printStorage();
                      //deleteEntry();
                      //pageController.jumpToPage(2);
                    })),
                SpeedDialChild(
                    label: 'SAVE ENTRY',
                    child: const Icon(Icons.save),
                    onTap: (() => {
                          setEntryName(),
                          setEntryContent(),
                          updateEntry(),
                          if (entryIsNew) {saveEntry()} else {updateEntry()},
                          pageController.jumpToPage(2)
                        }))
              ],
            )));
  }
}
