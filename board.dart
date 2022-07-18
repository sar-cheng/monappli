import 'package:flutter/material.dart';
import 'package:boardview/board_item.dart';
import 'package:boardview/board_list.dart';
import 'package:boardview/boardview_controller.dart';
import 'package:boardview/boardview.dart';

final List<BoardListObject> listData = [
  BoardListObject(title: "To-Do", items: [
    BoardItemObject(
      title: 'Example 1',
    ),
  ]),
  BoardListObject(title: "In Progress"),
  BoardListObject(title: "Done"),
];

void addItem(String itemTitle, DateTime itemDateTime) {
  listData[0]
      .items
      ?.add(BoardItemObject(title: itemTitle, dateTime: itemDateTime));
}

class BoardItemObject {
  String? title;
  DateTime? dateTime;

  BoardItemObject({this.title, this.dateTime}) {
    title ??= "";
    dateTime ??= dateTime;
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

  @override
  Widget build(BuildContext context) {
    List<BoardList> lists = [];

    for (int i = 0; i < listData.length; i++) {
      lists.add(_createBoardList(listData[i]) as BoardList);
    }

    return Container(
      color: Colors.transparent,
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BoardView(
            lists: lists,
            boardViewController: boardViewController,
          )),
    );
  }

  Widget buildBoardItem(BoardItemObject itemObject) {
    return BoardItem(
        item: Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(itemObject.title!),
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
                    style: const TextStyle(fontSize: 20),
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
