import 'package:appli_v2/EntryPage.dart';
import 'package:appli_v2/main.dart';
import 'package:flutter/material.dart';
import 'package:boardview/board_item.dart';
import 'package:boardview/board_list.dart';
import 'package:boardview/boardview_controller.dart';
import 'package:boardview/boardview.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Entry {
  String? name;
  String? date;
  String? content;

  Entry({this.name, this.date, this.content});
}

class MyEntries extends StatefulWidget {
  const MyEntries({Key? key}) : super(key: key);

  @override
  MyEntriesState createState() => MyEntriesState();
}

class MyEntriesState extends State<MyEntries> {
  final entries = <Entry>[];
  final entriesSeparated = <String>[]; // [name, date, name, date]

  void loadEntries() {
    var box = Hive.box('entryBox');

    if (box.length != 0) {
      for (int i = 0; i < box.length; i++) {
        var itemTitle = box.getAt(i).name;
        var itemDateTime = dateInString(box.getAt(i).date);
        var itemContent = box.getAt(i).content;

        entries.add(
            Entry(name: itemTitle, date: itemDateTime, content: itemContent));

        entriesSeparated.add(itemTitle);
        entriesSeparated.add(itemDateTime);
      }
    }
  }

  Widget _buildDates(String date) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        margin: const EdgeInsets.all(10),
        child: Padding(
            padding: EdgeInsets.all(5),
            child: Align(alignment: Alignment.centerLeft, child: Text(date))));
  }

  Widget _buildNames(String name) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: () {
              pageController.jumpToPage(4);

              setState(() {
                entryIsNew = false;
                /*entryName = entry.name!;
                entryDate = DateTime.parse(entry.date!);
                entryContent = entry.content!;
                

                oldEntryName = entry.name!;
                oldEntryDate = DateTime.parse(entry.date!);
                entryContent = entry.content!;*/
              });
            },
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                margin: const EdgeInsets.all(10),
                child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Align(
                        alignment: Alignment.centerLeft, child: Text(name))))));
  }

  Widget _buildList() {
    if (entries.isEmpty) {
      return Container(
        child: Text('No entries found'),
      );
    }
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 100.0, childAspectRatio: 5),
        controller: listScrollController,
        itemCount: entriesSeparated.length,
        itemBuilder: ((context, index) {
          int indexToEntries;
          /*if (index != 0) {
            indexToEntries = index - 1;
            return _buildNames(
                entriesSeparated[index], entries[indexToEntries]);
          }*/
          if (index.isOdd) return _buildDates(entriesSeparated[index]);
          return _buildNames(entriesSeparated[index]);
        }));
  }

  @override
  Widget build(BuildContext context) {
    loadEntries();

    return Container(
        color: Colors.transparent,
        child:
            Padding(padding: const EdgeInsets.all(16.0), child: _buildList()));
  }
}
