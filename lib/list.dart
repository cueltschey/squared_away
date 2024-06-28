import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TaskList extends StatefulWidget {
  TaskList({super.key, required this.taskList, required this.addNewTask, required this.typeList});
  final List<Map<String, dynamic>> taskList;
  final Function(String, int) addNewTask;
  final List<Map<String, dynamic>> typeList;

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  TextEditingController _controller = TextEditingController(); // Controller for TextField
  int _selectedIndex = 0; // Index of the selected dropdown option


  void addTask(String newTask) {
    setState(() {
      widget.addNewTask(newTask, _selectedIndex); // Add new task with the selected option index
      _controller.clear(); // Clear the text field after adding task
    });
  }

  bool _isDropdownExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Habits'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: widget.taskList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.taskList[index]['name'], style: TextStyle(
                    fontSize: 20.0
                  ),),
                  subtitle: Text(widget.typeList[widget.taskList[index]['category']]['name'], style: TextStyle(
                    color: widget.typeList[widget.taskList[index]['category']]['color'],
                    fontSize: 15.0
                  )),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Column(
                  children: [

                  ],
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter a new habit',
                    ),
                    autocorrect: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<int>(
                    value: _selectedIndex,
                    items: widget.typeList.asMap().entries.map((entry) {
                      int index = entry.value["id"];
                      String option = entry.value["name"];
                      Color optionColor = entry.value["color"];
                      return DropdownMenuItem<int>(
                        value: index,
                        child: Row(
                            children: [
                              Icon(Icons.star, color: optionColor),
                              if(_isDropdownExpanded) Text(option),
                              if(!_isDropdownExpanded) Text(option[0])
                            ],
                          ),
                      );
                    }).toList(),
                    onChanged: (int? newIndex) {
                      setState(() {
                        _selectedIndex =
                            newIndex ?? 0; // Update the selected index
                      });
                    },
                    onTap: () {
                        setState(() {
                          _isDropdownExpanded = true;
                        });
                      },
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      addTask(_controller.text); // Add the text from TextField as a new task
                    }
                  },
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }
}

class TypeList extends StatefulWidget {
  final List<Map<String, dynamic>> typeList;
  final Function(String, Color) addNewType;

  TypeList({super.key, required this.typeList, required this.addNewType});

  @override
  _TypeListState createState() => _TypeListState();
}

class _TypeListState extends State<TypeList> {
  TextEditingController _controller = TextEditingController(); // Controller for TextField
  Color _selectedColor = Colors.blue; // Default selected color

  void addType(String newType) {
    setState(() {
      widget.addNewType(newType, _selectedColor); // Add new type with the selected color
      _controller.clear(); // Clear the text field after adding type
    });
  }

  void _pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Categories'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: widget.typeList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.typeList[index]['name']),
                  trailing: Container(
                    width: 24,
                    height: 24,
                    color: widget.typeList[index]['color'],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter a new category',
                    ),
                    autocorrect: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => _pickColor(context),
                        child: Container(
                          width: 24,
                          height: 24,
                          color: _selectedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      addType(_controller.text); // Add the text from TextField as a new type
                    }
                  },
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }
}
