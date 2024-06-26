import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'squares.dart';
import 'appcolors.dart';

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
  List<Map<String, dynamic>> squareData = List.generate(200, (index) {
    return {
      'color': Color.fromARGB(200,10* index, 2* index, 5* index),
      'index': index,
      'isMonth': index % 20 == 0 && index != 0,
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
        currentWidget = Squares(squareData: squareData); // Replace with your widget for index 0
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
      backgroundColor: AppColors.appBackground,
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
              icon:  Text("Squares"),
              label: "one"
          ),
          BottomNavigationBarItem(
              icon: Text("Summary"),
              label: "two"
          ),
          BottomNavigationBarItem(
              icon: Text("Tasks"),
              label: "three"
          ),
          BottomNavigationBarItem(
              icon: Text("Categories"),
              label: "four"
          ),
        ],
      ),
    );
  }
}
