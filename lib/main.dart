import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:squared_away/journal.dart';
import 'package:squared_away/statistics.dart';
import 'squares.dart';
import 'list.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:squared_away/options.dart';

void main() {
  runApp(const SquaredAway());
}

class SquaredAway extends StatelessWidget {
  const SquaredAway({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Squared Away',
      home: const HomePage(title: 'Squared Away'),
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green[800],
        colorScheme: const ColorScheme.dark(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
      ),
    )
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    directory.create(recursive: true);
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    File newFile = File('$path/local.sqr');
    if(await newFile.exists()){
      print("File exists continue...");
    } else {
      newFile.create(recursive: true);
    }
    return newFile;
  }

  Future<File> writeTaskList(List<Map<String, dynamic>> tasks, List<Map<String, dynamic>> squareData) async {
    final file = await _localFile;
    Map<String, List> allData = {
      "tasks": tasks.map(
          (Map<String, dynamic> task){
            return {
              "name": task['name'],
              "index": task['index'],
              "hidden": task['hidden'],
              "color": task['color'].value,
            };
          }
      ).toList(),
      "squareData": squareData.map(
          (Map<String, dynamic> square){
            return {
              'date': square["date"].toString(),
              'month': square["month"],
              'isMonth': square["isMonth"],
              'tasks': square["tasks"],
            };
          }
      ).toList(),
    };
    String jsonTaskList = jsonEncode(allData);
    return file.writeAsString(jsonTaskList);
  }


  List<List<int>> getTasksPairs(List<Map<String, dynamic>> tasks){
    List<List<int>> result = [];
    for(Map<String, dynamic> item in tasks){
      if(item["hidden"]){
        continue;
      }
      List<int> pair = [];
      pair.add(0);
      pair.add(item['index']);
      result.add(pair);
    }
    return result;
  }

  List<Map<String, dynamic>> fillMissingSquares(DateTime startDate) {
    List<Map<String, dynamic>> result = [];
    DateTime current = DateTime.now();
    int count = current.difference(startDate).inDays + 1;
    for (int i = 0; i < count; i++) {
      DateTime date = startDate.add(Duration(days: i));
      result.add({
        'date': date,
        'month': DateFormat("MMMM").format(DateTime(date.year, date.month)),
        'isMonth': date.day == 1,
        'tasks': getTasksPairs(tasks),
      });
    }
    return result;
  }

  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> squareData = [];

  Future<Map<String, dynamic>> _readData() async {
    try{
      final file = await _localFile;
      String contents = await file.readAsString();
      return jsonDecode(contents);
    } catch(e) {
      //debugString = e.toString();
      return {};
    }
  }

  void getData() async {
    Map<String, dynamic> allData = await _readData();
    setState(() {
      if (allData['tasks'] == null) {
        tasks = [
          {
            'name': 'Workout',
            'index': 0,
            'hidden': false,
            'color': Colors.pink
          },
          {
            'name': 'Read',
            'index': 1,
            'hidden': false,
            'color': Colors.brown
          },
          {
            'name': 'Study',
            'index': 2,
            'hidden': false,
            'color': Colors.green
          },
          {
            'name': 'Clean',
            'index': 3,
            'hidden': false,
            'color': Colors.blue
          },
          {
            'name': 'Create',
            'index': 4,
            'hidden': false,
            'color': Colors.yellow
          },
        ];
      }
      else{
        for(int i = 0; i < allData['tasks'].length; i++){
          tasks.add({
            'name': allData['tasks'][i]['name'],
            'index': allData['tasks'][i]['index'],
            'hidden': allData['tasks'][i]['hidden'],
            'color': Color(allData['tasks'][i]['color']),
          });
        }
      }
      if(allData['squareData'] == null){
        squareData = fillMissingSquares(DateTime(DateTime.now().year, DateTime.now().month - 1));
      }
      else {
       for(int i = 0; i < allData['squareData'].length; i++){
         List<List<int>> taskList = [];
         for(int j = 0; j < allData['squareData'][i]['tasks'].length; j++){
           taskList.add([allData['squareData'][i]['tasks'][j][0],allData['squareData'][i]['tasks'][j][1]]);
         }
         squareData.add({
           'date': DateTime.parse(allData['squareData'][i]['date']),
           'month': allData['squareData'][i]['month'],
           'isMonth': allData['squareData'][i]['isMonth'],
           'tasks': taskList,
         });
       }
       if(DateTime.now().difference(squareData.last['date']).inDays > 0){
           squareData.addAll(fillMissingSquares(squareData.last['date'].add(Duration(days: 1))));
       }
      }

    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  int _pageIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _pageIndex = index; // Update the selected index
    });
  }

  void setTaskCallback(int squareIndex, int taskIndex, int value){
    setState(() {
      squareData[squareIndex]['tasks'][taskIndex][0] = value;
    });
    writeTaskList(tasks, squareData);
  }

  void addTaskCallback(String taskName, Color newColor){
    setState(() {
      squareData.last['tasks'].add([0,tasks.length]);
      tasks.add({
        'name':  taskName,
        'index': tasks.length,
        'hidden': false,
        'color': newColor
      });
    });
    writeTaskList(tasks, squareData);
  }
  
  removeTaskCallback(int index){
    setState(() {
      int numVisible = 0;
      for(int i = 0; i < tasks.length; i++){
        if(!tasks[i]['hidden']){
          numVisible += 1;
          if(numVisible > 1){
           break;
          }
        }
      }
      if(numVisible > 1){
        tasks[index]['hidden'] = true;
        for(int i = 0; i < squareData.last['tasks'].length; i++){
          if(squareData.last['tasks'][i][1] == index){
            squareData.last['tasks'].removeAt(i);
          }
        }
      }
    });
  }
  bool _isJournal = false;


  @override
  Widget build(BuildContext context) {
    Widget currentWidget;
    switch (_pageIndex) {
      case 0:
        DateTime now = DateTime.now();
        currentWidget = Scaffold(
          appBar: AppBar(title: _isJournal? Text("Journal"): Text("Squares"), toolbarHeight: 20.0,
            leading: _isJournal? Icon(Icons.chrome_reader_mode) : Icon(Icons.dataset_outlined)),
          body: _isJournal? Journal(squareData: squareData, taskList: tasks, setTaskCallback: setTaskCallback)
              : Squares(squareData: squareData, taskList: tasks, setTaskCallback: setTaskCallback),
          floatingActionButton:  Switch(
            activeColor: Colors.white,
            value: _isJournal,
            onChanged: (value) {
              setState(() {
                _isJournal = value;
              });
            },
          ),
        );
        break;
      case 1:
        currentWidget = TaskList(taskList: tasks, addNewTask: addTaskCallback, deleteTaskCallback: removeTaskCallback,);
        break;
      case 2:
        currentWidget = Statistics(taskList: tasks, squareData: squareData);
        break;
      case 3:
        currentWidget = Options();
        break;
      default:
        currentWidget = const SizedBox.shrink(); // Handle any unexpected index
    }

    return Scaffold(
      body: Center(
        child: currentWidget,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        elevation: 20.0,
        backgroundColor: Color.fromARGB(200, 34, 34, 34),
        selectedIconTheme: const IconThemeData(
          color: Colors.yellow,
        ),
        items: [
          BottomNavigationBarItem(
              icon:  _isJournal? const Icon(Icons.chrome_reader_mode, color: Colors.white) :
                                 const Icon(Icons.dataset_outlined, color: Colors.white),
              label: _isJournal? "Journal": "Squares"
          ),
          const BottomNavigationBarItem(
              icon:  Icon(Icons.auto_awesome_outlined, color: Colors.white),
              label: "Habits"
          ),
          const BottomNavigationBarItem(
              icon:  Icon(Icons.bar_chart_outlined, color: Colors.white),
              label: "Statistics"
          ),
          const BottomNavigationBarItem(
              icon:  Icon(Icons.blender_outlined, color: Colors.white),
              label: "Blender!!"
          ),
        ],
      ),
    );
  }
}
