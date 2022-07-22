import 'package:appli_v2/Models/MyBoard.dart';
import 'package:appli_v2/TaskPage.dart';
import 'package:appli_v2/main.dart';
import 'package:flutter/material.dart';
import 'package:boardview/board_item.dart';
import 'package:boardview/board_list.dart';
import 'package:boardview/boardview_controller.dart';
import 'package:boardview/boardview.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

final List<BoardListObject> boardData = [
  BoardListObject(title: "To-Do"),
  BoardListObject(title: "In Progress"),
  BoardListObject(title: "Done"),
];

final List<BoardItemObject> toDoItems = [];

class BoardItemObject {
  String? title;
  String? date;

  BoardItemObject({this.title, this.date}) {
    title ??= "";
    date ??= "";
  }
}

class BoardListObject {
  String? title;
  List<BoardItemObject>? items;

  BoardListObject({this.title, this.items}) {
    title ??= "";
    items ??= [];
  }
}

class MyBoard extends StatefulWidget {
  const MyBoard({Key? key}) : super(key: key);

  @override
  MyBoardState createState() => MyBoardState();
}

class MyBoardState extends State<MyBoard> {
  final BoardViewController boardViewController = BoardViewController();

  void loadList() {
    int numOfBox = 3;

    for (int i = 0; i < numOfBox; i++) {
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
          var itemTitle = box.getAt(j).name;
          var itemDateTime = getDate(box.getAt(j).date);

          /*boardData[i]
              .items!
              .add(BoardItemObject(title: itemTitle, date: itemDateTime));*/
          toDoItems.add(BoardItemObject(title: itemTitle, date: itemDateTime));
        }
      }
    }
  }

  Widget _buildList() {
    return ListView.builder(
        padding: const EdgeInsets.all(5),
        itemCount: toDoItems.length,
        itemBuilder: (context, index) {
          return _buildColumn(toDoItems[index]);
        });
  }

  Widget _buildColumn(BoardItemObject itemObject) {
    return Container(
        child: GestureDetector(
      onTap: (() {}),
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [Text(itemObject.title!), Text(itemObject.date!)],
              ))),
    ));
  }

  @override
  Widget build(BuildContext context) {
    loadList();
    /*List<BoardList> lists = [];

    for (int i = 0; i < boardData.length; i++) {
      lists.add(_createBoardList(boardData[i]) as BoardList);
    }

    return Container(
      color: Colors.transparent,
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BoardView(
            lists: lists,
            boardViewController: boardViewController,
          )),
    );*/

    return Scaffold(body: _buildList());
  }

  Widget buildBoardItem(BoardItemObject itemObject) {
    return BoardItem(
        draggable: false,
        item: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {},
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [Text(itemObject.title!), Text(itemObject.date!)],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _createBoardList(BoardListObject list) {
    List<BoardItem> items = [];
    for (int i = 0; i < list.items!.length; i++) {
      items.insert(i, buildBoardItem(list.items![i]) as BoardItem);
    }

    return BoardList(
      draggable: false,
      headerBackgroundColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      header: [
        Expanded(
            child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(children: [
                  Text(
                    list.title!,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const Divider(
                    color: Colors.black,
                    indent: 10.0,
                    endIndent: 10.0,
                  )
                ]))),
      ],
      items: items,
    );
  }
}
