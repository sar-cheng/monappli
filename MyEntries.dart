import 'package:appli_v2/main.dart';
import 'package:flutter/material.dart';
import 'package:boardview/board_item.dart';
import 'package:boardview/board_list.dart';
import 'package:boardview/boardview_controller.dart';
import 'package:boardview/boardview.dart';
import 'package:hive_flutter/hive_flutter.dart';

final List<BoardListObject> boardData = [
  BoardListObject(title: "To-Do"),
];

class Entry {
  String? title;
  String? date;
  String? content;

  Entry({this.title, this.date, this.content}) {
    title ??= "";
    date ??= "";
    content ??= "";
  }
}

class BoardListObject {
  String? title;
  List<Entry>? items;

  BoardListObject({this.title, this.items}) {
    title ??= "";
    items ??= [];
  }
}

class MyEntries extends StatefulWidget {
  const MyEntries({Key? key}) : super(key: key);

  @override
  MyEntriesState createState() => MyEntriesState();
}

class MyEntriesState extends State<MyEntries> {
  List<String> entries = [];

  Widget _buildDates() {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        color: Colors.blue,
      ),
    );
  }

  Widget _buildNames() {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: () {
              pageController.jumpToPage(3);

              setState(() {});
            },
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                margin: const EdgeInsets.all(10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('data'),
                ))));
  }

  Widget _buildList() {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 100.0, childAspectRatio: 5),
        itemCount: 5,
        controller: listScrollController,
        itemBuilder: ((context, index) {
          if (index.isOdd) return _buildDates();
          return _buildNames();
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        child:
            Padding(padding: const EdgeInsets.all(16.0), child: _buildList()));
  }
}
