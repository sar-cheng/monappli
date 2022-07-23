import 'package:appli_v2/Models/MyEntries.dart';
import 'package:appli_v2/Models/MyTask.dart';
import 'package:flutter/material.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'Models/MyBoard.dart';
import 'package:intl/intl.dart';
import 'NewTask.dart';

void main() async {
  // initialise Hive - local storage
  await Hive.initFlutter();
  Hive.registerAdapter(MyTaskAdapter());

  // open boxes (storage for to-do board)
  var toDoBox = await Hive.openBox('toDoBox');
  var inProgressBox = await Hive.openBox('inProgressBox');
  var doneBox = await Hive.openBox('doneBox');

  runApp(const MyApp());
}

String getDate(DateTime dateTime) => DateFormat('yyyy-MM-dd').format(dateTime);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
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

PageController pageController = PageController();

class MyHomeState extends State<MyHome> {
  Widget _pageLayout(Widget? pageContent) {
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

  Widget _buildCol() {
    return ListTile(
      title: Text('data'),
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
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.cover)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SideMenu(
                controller: pageController,
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
                    onTap: () => pageController.jumpToPage(0),
                    icon: const Icon(Icons.home),
                  ),
                  SideMenuItem(
                    priority: 1,
                    title: 'To-do',
                    onTap: () => pageController.jumpToPage(1),
                    icon: const Icon(Icons.calendar_month),
                  ),
                  SideMenuItem(
                    priority: 2,
                    title: 'My Entries',
                    onTap: () => pageController.jumpToPage(2),
                    icon: const Icon(Icons.book),
                  ),
                ],
              ),
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
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
                                  taskIsNew = true;
                                  taskName = '';
                                  taskType = 'To-Do';
                                  taskDate = DateTime.now();

                                  pageController.jumpToPage(3);
                                }),
                                child: const Icon(Icons.add))))),
                    CustomScrollView(
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                ListTile(title: Text('index $index')),
                            childCount: 20,
                          ),
                        )
                      ],
                    ),
                    _pageLayout(const TaskPage())
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
