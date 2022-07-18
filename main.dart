import 'package:appli/taskmanager.dart';
import 'package:flutter/material.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'Models/board.dart';
import 'dataservice.dart';
import 'dart:async';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.blue[300]),
      home: MyHome(title: 'Appli'),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key, required this.title});

  final String title;

  @override
  MyHomeState createState() => MyHomeState();
}

class MyHomeState extends State<MyHome> {
  PageController page = PageController();

  Container _pageLayout(Widget? pageContent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      margin: const EdgeInsets.all(10),
      child: pageContent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[400],
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/background.jpg"),
                  fit: BoxFit.cover)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SideMenu(
                controller: page,
                style: SideMenuStyle(
                  displayMode: SideMenuDisplayMode.auto,
                  hoverColor: Colors.white.withOpacity(0.5),
                  selectedColor: Colors.blue[400],
                  selectedTitleTextStyle: const TextStyle(color: Colors.white),
                  selectedIconColor: Colors.white,
                ),
                title: Column(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 150,
                        maxWidth: 150,
                      ),
                    ),
                    const Divider(
                      indent: 8.0,
                      endIndent: 8.0,
                    ),
                  ],
                ),
                items: [
                  SideMenuItem(
                    priority: 0,
                    title: 'Home',
                    onTap: () => page.jumpToPage(0),
                    icon: const Icon(Icons.home),
                  ),
                  SideMenuItem(
                    priority: 1,
                    title: 'To-do',
                    onTap: () => page.jumpToPage(1),
                    icon: const Icon(Icons.calendar_month),
                  ),
                  SideMenuItem(
                    priority: 2,
                    title: 'My Entries',
                    onTap: () => page.jumpToPage(2),
                    icon: const Icon(Icons.book),
                  ),
                  SideMenuItem(
                      priority: 3,
                      title: 'My Trackers',
                      onTap: () => page.jumpToPage(3),
                      icon: const Icon(Icons.timelapse)),
                ],
              ),
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: page,
                  children: [
                    _pageLayout(const Center(child: Text('Home'))),
                    _pageLayout(Scaffold(
                        backgroundColor: Colors.transparent,
                        body: const MyBoard(),
                        floatingActionButtonLocation:
                            FloatingActionButtonLocation.endDocked,
                        floatingActionButton: Padding(
                            padding: const EdgeInsets.all(10),
                            child: FloatingActionButton(
                                shape: const CircleBorder(),
                                onPressed: (() {
                                  page.jumpToPage(4);
                                }),
                                child: const Icon(Icons.add))))),
                    _pageLayout(const Center(child: Text('coming soon'))),
                    _pageLayout(const Center(child: Text('coming soon'))),
                    _pageLayout(TaskPage(storage: TaskStorage()))
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
