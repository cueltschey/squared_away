import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:squared_away/statistics.dart';
import 'squares.dart';
import 'list.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
    File newFile = File('$path/test_b.sqr');
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
        tasks  = List.generate(5, (index) {
          return {
            'name': 'Example Task',
            'index': index,
            'hidden': false,
            'color': Colors.indigo
          };
        });
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
       if(squareData.last['date'].difference(DateTime.now()).inDays > 0){
           squareData.addAll(fillMissingSquares(squareData.last['date']));
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
      tasks[index]['hidden'] = true;
      for(int i = 0; i < squareData.last['tasks'].length; i++){
        if(squareData.last['tasks'][i][1] == index){
          squareData.last['tasks'].removeAt(i);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentWidget;

    switch (_pageIndex) {
      case 0:
        DateTime now = DateTime.now();
        currentWidget = Squares(squareData: squareData, taskList: tasks, setTaskCallback: setTaskCallback); // Replace with your widget for index 0
        break;
      case 1:
        //currentWidget = Text("text");
        currentWidget = Statistics(taskList: tasks, squareData: squareData);
        break;
      case 2:
        currentWidget = TaskList(taskList: tasks, addNewTask: addTaskCallback, deleteTaskCallback: removeTaskCallback,);
        break;
      case 3:
        currentWidget = GestureDetector(
          onTap: () =>
          {
            writeTaskList(tasks, squareData)
          },
          child: Text("Debug:    " + tasks.last.toString())
        );
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
        items: const [
          BottomNavigationBarItem(
              icon:  Icon(Icons.square, color: Colors.white),
              label: "Squares"
          ),
          BottomNavigationBarItem(
              icon:  Icon(Icons.stacked_bar_chart, color: Colors.white),
              label: "Statistics"
          ),
          BottomNavigationBarItem(
              icon:  Icon(Icons.list, color: Colors.white),
              label: "Habits"
          ),
          BottomNavigationBarItem(
              icon:  Icon(Icons.star, color: Colors.white),
              label: "Categories"
          ),
        ],
      ),
    );
  }
}
