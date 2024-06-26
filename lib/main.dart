import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  List<Map<String, dynamic>> generateDateList(DateTime startDate) {
    List<Map<String, dynamic>> result = [];
    DateTime current = DateTime.now();
    int count = current.difference(startDate).inDays;
    for (int i = 0; i < count; i++) {
      DateTime date = startDate.add(Duration(days: i));
      result.add({
        'date': date,
        'month': DateFormat("MMMM").format(DateTime(date.year, date.month - 1)),
        'isMonth': date.day == 1,
        'tasks': getTasksPairs(tasks),
      });
    }
    result.last['isMonth'] = true;
    result.last['month'] = DateFormat("MMMM").format(DateTime.now());
    return result;
  }

  List<Map<String, dynamic>> tasks = List.generate(5,(index) {
    return {
      'name': 'test',
      'category': 4,
      'index': index,
      'hidden': false
    };
  });


  int _pageIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _pageIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentWidget;

    switch (_pageIndex) {
      case 0:
        DateTime now = DateTime.now();
        currentWidget = Squares(squareData: generateDateList(DateTime(now.year, now.month - 1, 1)), taskList: tasks); // Replace with your widget for index 0
        break;
      case 1:
        DateTime now = DateTime.now();
        currentWidget = Text(generateDateList(DateTime(now.year, now.month - 1, 1)).toString());
        break;
      case 2:
        currentWidget = TaskList();
        break;
      case 3:
        currentWidget = TypeList();
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
        items: const [
          BottomNavigationBarItem(
              icon:  Icon(Icons.square, color: Colors.white),
              label: ""
          ),
          BottomNavigationBarItem(
              icon:  Icon(Icons.stacked_bar_chart, color: Colors.white),
              label: ""
          ),
          BottomNavigationBarItem(
              icon:  Icon(Icons.list, color: Colors.white),
              label: ""
          ),
          BottomNavigationBarItem(
              icon:  Icon(Icons.star, color: Colors.white),
              label: ""
          ),
        ],
      ),
    );
  }
}
