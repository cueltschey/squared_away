import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TaskList extends StatefulWidget {
  TaskList({super.key, required this.taskList, required this.addNewTask, required this.deleteTaskCallback, required this.updateTask});
  final List<Map<String, dynamic>> taskList;
  final Function(String, Color, List<bool>) addNewTask;
  final Function(String, Color, List<bool>, int) updateTask;
  final Function(int) deleteTaskCallback;

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {

  void _deleteTask(int taskIndex){
    widget.deleteTaskCallback(taskIndex);
  }

  void _openAddTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTask(addNewTask: widget.addNewTask)
      ),
    );
  }

  void _openEditTask(Map<String, dynamic> taskItem, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditTask(updateTask: widget.updateTask, taskItem: taskItem, taskIndex: index,)
      ),
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
              padding: EdgeInsets.all(2),
              itemCount: widget.taskList.length,
              itemBuilder: (context, index) {
                if(widget.taskList[index]['hidden']){
                  return Container();
                }
                return Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    border: Border.all(
                      color: widget.taskList[index]['color'],
                      width: 2.0
                    ),
                    borderRadius: BorderRadius.circular(10)
                  ),
                    child: ListTile(
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
                          _openEditTask(widget.taskList[index], index);
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
                )
                );
              },
            ),
          ),
          ElevatedButton(
              onPressed: _openAddTask,
              child: Icon(Icons.add, color: Colors.green),
              )
        ],
      ),
    );
  }
}

class AddTask extends StatefulWidget{
  final Function(String, Color, List<bool>) addNewTask;
  AddTask({super.key, required this.addNewTask});
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  Color _selectedColor = Colors.blue;
  TextEditingController _controller = TextEditingController();
  List<bool> _isChecked = [true, true, true, true, true, true, true];
  List<String> _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  void addTask(String newTask, List<bool> checkedDays) {
    setState(() {
      widget.addNewTask(newTask, _selectedColor, checkedDays); // Add new task with the selected option index
      _controller.clear(); // Clear the text field after adding task
    });
  }

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
      appBar: AppBar(title: Text("Add a new task")),
      body: Column(
        children: [
          Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter a new habit',
                ),
                autocorrect: false,
                maxLength: 30,
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
        ]),
          Divider(thickness: 10.0, color: Colors.transparent),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(_days.length, (int index) {
                return Row(
                  children: <Widget>[
                    Column(
                      children: [
                        Text(_days[index]),
                        Checkbox(
                          value: _isChecked[index],
                          onChanged: (bool? value) {
                            setState(() {
                              _isChecked[index] = value!;
                            });
                          },
                        ),
                      ],
                    )
                  ],
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.check, color: Colors.green), onPressed: () {
        addTask(_controller.text, _isChecked);
        Navigator.pop(context);
      },
        backgroundColor: Colors.transparent,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }
}


class EditTask extends StatefulWidget{
  final Map<String, dynamic> taskItem;
  final int taskIndex;
  final Function(String, Color, List<bool>, int) updateTask;
  EditTask({super.key, required this.updateTask, required this.taskItem, required this.taskIndex});
  _EditTaskState createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  Color _selectedColor = Colors.blue;
  TextEditingController _controller = TextEditingController();
  List<bool> _isChecked = [];
  List<String> _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.taskItem['color'];
    _controller.text = widget.taskItem['name'];
    _isChecked = [
      widget.taskItem['days']['sunday'],
      widget.taskItem['days']['monday'],
      widget.taskItem['days']['tuesday'],
      widget.taskItem['days']['wednesday'],
      widget.taskItem['days']['thursday'],
      widget.taskItem['days']['friday'],
      widget.taskItem['days']['saturday'],
    ];
  }

  void addTask(String newTask, List<bool> checkedDays) {
    setState(() {
      widget.updateTask(newTask, _selectedColor, checkedDays, widget.taskIndex); // Add new task with the selected option index
      _controller.clear(); // Clear the text field after adding task
    });
  }

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
      appBar: AppBar(title: Text("Edit task")),
      body: Column(
        children: [
          Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter a new habit',
                    ),
                    autocorrect: false,
                    maxLength: 30,
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
              ]),
          Divider(thickness: 10.0, color: Colors.transparent),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(_days.length, (int index) {
                return Row(
                  children: <Widget>[
                    Column(
                      children: [
                        Text(_days[index]),
                        Checkbox(
                          value: _isChecked[index],
                          onChanged: (bool? value) {
                            setState(() {
                              _isChecked[index] = value!;
                            });
                          },
                        ),
                      ],
                    )
                  ],
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.check, color: Colors.green), onPressed: () {
        addTask(_controller.text, _isChecked);
        Navigator.pop(context);
      },
        backgroundColor: Colors.transparent,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }
}
