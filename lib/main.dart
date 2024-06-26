import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'squares.dart';

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
  List<Map<String, dynamic>> generateDateList(DateTime startDate) {
    List<Map<String, dynamic>> result = [];
    int count = DateTime.now().difference(startDate).inDays + 1;
    for (int i = 0; i < count; i++) {
      DateTime date = startDate.add(Duration(days: i));
      result.add({
        'date': date,
        'month': DateFormat("MMMM").format(date),
        'index': i,
        'isMonth': date.day == 1,
        'color': Color.fromARGB(200,100, 2* i, 100),
      });
    }
    return result;
  }


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
        currentWidget = Squares(squareData: generateDateList(DateTime(2024, 1, 1))); // Replace with your widget for index 0
        break;
      case 1:
        currentWidget = const Placeholder(color: Colors.blueGrey); // Replace with your widget for index 1
        break;
      case 2:
        currentWidget = const Placeholder(color: Colors.greenAccent); // Replace with your widget for index 2
        break;
      case 3:
        currentWidget = const Placeholder(color: Colors.orangeAccent); // Replace with your widget for index 3
        break;
      default:
        currentWidget = const SizedBox.shrink(); // Handle any unexpected index
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        title: Text(widget.title),
      ),
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
