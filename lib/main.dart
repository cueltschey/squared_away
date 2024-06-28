import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:squared_away/statistics.dart';
import 'squares.dart';
import 'list.dart';

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

  List<List<int>> getTasksPairs(List<Map<String, dynamic>> tasks){
    List<List<int>> result = [];
    for(Map<String, dynamic> item in tasks){
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
    int count = current.difference(startDate).inDays + 2;
    for (int i = 0; i < count; i++) {
      DateTime date = startDate.add(Duration(days: i));
      result.add({
        'date': date,
        'month': DateFormat("MMMM").format(DateTime(date.year, date.month)),
        'isMonth': date.day == 1,
        'tasks': getTasksPairs(tasks),
      });
    }
    result.last['isMonth'] = true;
    result.last['month'] = DateFormat("MMMM").format(DateTime.now());
    return result;
  }

  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> squareData = [];
  List<Map<String, dynamic>> categories = [];

  @override
  void initState(){
    super.initState();
    tasks = List.generate(5,(index) {
      return {
        'name': 'Example Task',
        'category': 4,
        'index': index,
        'hidden': false
      };
    });
    categories = List.generate(5,(index) {
      return {
        'name': 'Example Category',
        'id': index,
        'color': Colors.primaries[index]
      };
    });
    squareData = fillMissingSquares(DateTime(2023));
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
  }

  void addCategoryCallback(String categoryName, Color selectedColor){
    setState(() {
      categories.add({
        'name': categoryName,
        'id': categories.length,
        'color': selectedColor
      });
    });
  }

  void addTaskCallback(String taskName, int categoryId){
    setState(() {
      squareData[squareData.length - 2]['tasks'].add([0,tasks.length]);
      tasks.add({
        'name':  taskName,
        'category': categoryId,
        'index': tasks.length,
        'hidden': false,
      });
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
        currentWidget = Statistics(taskList: tasks, typeList: categories, squareData: squareData);
        break;
      case 2:
        currentWidget = TaskList(taskList: tasks, addNewTask: addTaskCallback, typeList: categories);
        break;
      case 3:
        currentWidget = TypeList(typeList: categories, addNewType: addCategoryCallback);
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
