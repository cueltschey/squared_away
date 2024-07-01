import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TaskList extends StatefulWidget {
  TaskList({super.key, required this.taskList, required this.addNewTask, required this.deleteTaskCallback});
  final List<Map<String, dynamic>> taskList;
  final Function(String, Color) addNewTask;
  final Function(int) deleteTaskCallback;

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  TextEditingController _controller = TextEditingController(); // Controller for TextField

  void addTask(String newTask) {
    setState(() {
      widget.addNewTask(newTask, _selectedColor); // Add new task with the selected option index
      _controller.clear(); // Clear the text field after adding task
    });
  }

  void _editTask(int taskIndex){}
  void _deleteTask(int taskIndex){
    widget.deleteTaskCallback(taskIndex);
  }

  Color _selectedColor = Colors.blue; // Default selected color

  void _pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              enableAlpha: false,
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
              child: const Text('Done'),
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
        title: Text('Current Habits'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: widget.taskList.length,
              itemBuilder: (context, index) {
                if(widget.taskList[index]['hidden']){
                  return Container();
                }
                return ListTile(
                  title: Text(widget.taskList[index]['name'], style: TextStyle(
                    color: widget.taskList[index]['color'],
                    fontSize: 20.0,
                  ),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (String result) {
                      switch (result) {
                        case 'Edit':
                          _editTask(index);
                          break;
                        case 'Delete':
                          _deleteTask(index);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'Edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
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
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => _pickColor(context),
                        child: Icon(
                          Icons.circle,
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
