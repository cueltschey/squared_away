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
import 'package:provider/provider.dart';
import 'theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:squared_away/drive.dart';

Future<void> _initFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyAOMFqIRAbHPlJrbhxGpO_Mz0uj-UlKDb0",
        appId: "1:700175434084:android:846f50a60fac116bd97a71",
        messagingSenderId: "700175434084",
        projectId: "squaredaway"
    ),
  );
}

void main() async {
  _initFirebase();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(
        ThemeData.dark(),
      ),
      child: const SquaredAway(),
    ),
  );
}

class SquaredAway extends StatelessWidget {
  const SquaredAway({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Squared Away',
          theme: themeProvider.themeData,
          home: HomePage(title: "Squared Away"),
        );
      },
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

  final List<Map<String, dynamic>> themes = [
    {
      'name': 'Basic Dark',
      'primary': Color.fromARGB(200, 34, 34, 34),
      'focus': Color.fromARGB(255, 200, 200, 200),
      'isDark': true,
    },
    {
      'name': 'Basic Light',
      'primary': Color.fromARGB(255, 150, 150, 150),
      'focus': Color.fromARGB(255, 34, 34, 34),
      'isDark': false,
    },
    {
      'name': 'Martian Dark',
      'primary': Color.fromARGB(200, 34, 34, 34),
      'focus': Color.fromARGB(255, 200, 255, 255),
      'isDark': true,
    },
    {
      'name': 'Martian Light',
      'primary': Color.fromARGB(255, 200, 255, 255),
      'focus': Color.fromARGB(255, 34, 34, 34),
      'isDark': false,
    },
    {
      'name': 'Fire Dark',
      'primary': Color.fromARGB(200, 34, 34, 34),
      'focus': Color.fromARGB(255, 235, 150, 150),
      'isDark': true,
    },
    {
      'name': 'Fire Light',
      'primary': Color.fromARGB(255, 235, 150, 150),
      'focus': Color.fromARGB(255, 34, 34, 34),
      'isDark': false,
    },
  ];

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
              "days": task['days']
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
      "theme": [themeId],
    };
    String jsonTaskList = jsonEncode(allData);
    return file.writeAsString(jsonTaskList);
  }


  List<List<int>> getTasksPairs(List<Map<String, dynamic>> tasks, DateTime currentDate){
    List<List<int>> result = [];
    for(Map<String, dynamic> item in tasks){
      if(item["hidden"]){
        continue;
      }
      if(item['days'][DateFormat("EEEE").format(currentDate).toLowerCase()]){
        List<int> pair = [];
        pair.add(0);
        pair.add(item['index']);
        result.add(pair);
      }
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
        'tasks': getTasksPairs(tasks, date),
      });
    }
    return result;
  }

  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> squareData = [];
  bool _loading = true;
  int themeId = 0;

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
    setState(() {
      tasks = [];
      squareData = [];
    });
    Map<String, dynamic> allData = await _readData();
    setState(() {
      if (allData['tasks'] == null) {
        tasks = [
          {
            'name': 'Workout',
            'index': 0,
            'hidden': false,
            'color': Colors.pink,
            'days': {
              'sunday': true,
              'monday': true,
              'tuesday': true,
              'wednesday': true,
              'thursday': true,
              'friday': true,
              'saturday': true,
            },
          },
          {
            'name': 'Read',
            'index': 1,
            'hidden': false,
            'color': Colors.brown,
            'days': {
              'sunday': true,
              'monday': true,
              'tuesday': true,
              'wednesday': true,
              'thursday': true,
              'friday': true,
              'saturday': true,
            },
          },
          {
            'name': 'Study',
            'index': 2,
            'hidden': false,
            'color': Colors.green,
            'days': {
              'sunday': true,
              'monday': true,
              'tuesday': true,
              'wednesday': true,
              'thursday': true,
              'friday': true,
              'saturday': true,
            },
          },
          {
            'name': 'Clean',
            'index': 3,
            'hidden': false,
            'color': Colors.blue,
            'days': {
              'sunday': true,
              'monday': true,
              'tuesday': true,
              'wednesday': true,
              'thursday': true,
              'friday': true,
              'saturday': true,
            },
          },
          {
            'name': 'Create',
            'index': 4,
            'hidden': false,
            'color': Colors.yellow,
            'days': {
              'sunday': true,
              'monday': false,
              'tuesday': false,
              'wednesday': false,
              'thursday': false,
              'friday': false,
              'saturday': true,
            },
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
            'days': allData['tasks'][i]['days'],
          });
        }
      }
      if(allData['squareData'] == null || allData['squareData'] == []){
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
      if(allData['theme'] != null && allData['theme'].length > 0){
        setState(() {
          themeId = allData['theme'][0];
        });

        Provider.of<ThemeProvider>(context, listen: false).setTheme(
            ThemeData(
              brightness: themes[themeId]['isDark']? Brightness.dark : Brightness.light,
              primaryColor:  themes[themeId]['primary'],
              focusColor: themes[themeId]['focus'],
            )
        );
      }
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loading = true;
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

  void addTaskCallback(String taskName, Color newColor, List<bool> checkedDays){
    if(taskName == ""){
      return;
    }
    setState(() {
      tasks.add({
        'name':  taskName,
        'index': tasks.length,
        'hidden': false,
        'color': newColor,
        'days': {
          'sunday': checkedDays[0],
          'monday': checkedDays[1],
          'tuesday': checkedDays[2],
          'wednesday': checkedDays[3],
          'thursday': checkedDays[4],
          'friday': checkedDays[5],
          'saturday': checkedDays[6],
        }
      });
      if(tasks.last['days'][DateFormat("EEEE").format(DateTime.now()).toLowerCase()]){
        squareData.last['tasks'].add([0,tasks.length - 1]);
      }
    });
    writeTaskList(tasks, squareData);
  }

  void updateTaskCallback(String taskName, Color newColor, List<bool> checkedDays, int taskIndex){
    if(taskName == ""){
      return;
    }
    setState(() {
      tasks[taskIndex] = {
        'name':  taskName,
        'index': taskIndex,
        'hidden': false,
        'color': newColor,
        'days': {
          'sunday': checkedDays[0],
          'monday': checkedDays[1],
          'tuesday': checkedDays[2],
          'wednesday': checkedDays[3],
          'thursday': checkedDays[4],
          'friday': checkedDays[5],
          'saturday': checkedDays[6],
        }
      };
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

  void setThemeCallback(int Id){
    setState(() {
      themeId = Id;
    });
    writeTaskList(tasks, squareData);
  }


  bool _isJournal = false;


  @override
  Widget build(BuildContext context) {
    Widget currentWidget;
    switch (_pageIndex) {
      case 0:
        DateTime now = DateTime.now();
        currentWidget = Scaffold(
          appBar: AppBar(title: _isJournal? Text("Journal"): Text("Squares"), toolbarHeight: 20.0,),
          body: _isJournal? Journal(squareData: squareData, taskList: tasks, setTaskCallback: setTaskCallback)
              : Squares(squareData: squareData, taskList: tasks, setTaskCallback: setTaskCallback),
          floatingActionButton:  Switch(
            activeColor: Theme.of(context).focusColor,
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
        currentWidget = Options(
          options: [
            TaskList(taskList: tasks, addNewTask: addTaskCallback, deleteTaskCallback: removeTaskCallback, updateTask: updateTaskCallback),
            Scaffold(
              appBar:  AppBar(title: Text("Statistics")),
                body: Statistics(taskList: tasks, squareData: squareData)
            ),
            ThemePicker(setThemeCallback: setThemeCallback,),
            GoogleDriveFileSync(getDataCallback: getData)
          ],
          icons: [
            Icon(Icons.auto_awesome_outlined, semanticLabel: "testing",),
            Icon(Icons.bar_chart_outlined),
            Icon(Icons.palette),
            Icon(Icons.file_copy_outlined)
          ],
          subtitles: ["Habits", "Statistics", "Theme", "Sync to Drive"],
        );
        break;
      default:
        currentWidget = const SizedBox.shrink(); // Handle any unexpected index
    }

    return Scaffold(
      body: Center(
        child: _loading? CircularProgressIndicator() : currentWidget,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).focusColor,
        elevation: 20.0,
        backgroundColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
              icon:  _isJournal?  Icon(Icons.chrome_reader_mode, color: Theme.of(context).focusColor) :
                                  Icon(Icons.dataset_outlined, color: Theme.of(context).focusColor),
              label: _isJournal? "Journal": "Squares",
          ),
          BottomNavigationBarItem(
              icon:  Icon(Icons.blender_outlined, color: Theme.of(context).focusColor),
              label: "Blender!!"
          ),
        ],
      ),
    );
  }
}
