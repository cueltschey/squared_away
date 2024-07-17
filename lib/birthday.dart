import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';

class BirthdayPage extends StatefulWidget {
  final List<Map<String, dynamic>> birthdayData;
  final Function(String, Color, DateTime) addNewBirthday;
  BirthdayPage({super.key, required this.birthdayData, required this.addNewBirthday});

  _BirthdayState createState() => _BirthdayState();
}

class _BirthdayState extends State<BirthdayPage> {

  void _openAddBirthday() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddBirthday(addNewBirthday: widget.addNewBirthday,)
      ),
    );
  }

  void _openEditTask(Map<String, dynamic> birthday, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Text("To be implemented")//EditBirthday()
      ),
    );
  }

  void _deleteBirthday(int index){

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Birthday Tracker")),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(2),
              itemCount: widget.birthdayData.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            border: Border.all(
                                color: widget.birthdayData[index]['color'],
                                width: 2.0
                            ),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: ListTile(
                          title: Text(widget.birthdayData[index]['name'], style: TextStyle(
                            color: widget.birthdayData[index]['color'],
                            fontSize: 25.0,
                          ),
                          ),
                          subtitle: Text(
                              DateFormat("MMMM").format(widget.birthdayData[index]['date'])
                                  + ' ' +widget.birthdayData[index]['date'].day.toString()
                                  + ',' + widget.birthdayData[index]['date'].year.toString(),
                            style: TextStyle(
                              fontSize: 20.0
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: Colors.white),
                            onSelected: (String result) {
                              switch (result) {
                                case 'Edit':
                                  //_openEditTask(widget.taskList[index], index);
                                  break;
                                case 'Delete':
                                  _deleteBirthday(index);
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
                    ));
              },
            ),
          ),
          ElevatedButton(
            onPressed: _openAddBirthday,
            child: Icon(Icons.add, color: Colors.green),
          )
        ],
      ),
    );
  }
}

class AddBirthday extends StatefulWidget{
  final Function(String, Color, DateTime) addNewBirthday;
  AddBirthday({super.key, required this.addNewBirthday});
  _AddBirthdayState createState() => _AddBirthdayState();
}

class _AddBirthdayState extends State<AddBirthday> {
  Color _selectedColor = Colors.blue;
  TextEditingController _controller = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  void addTask() {
    setState(() {
      widget.addNewBirthday(_controller.text, _selectedColor, _selectedDate); // Add new task with the selected option index
      _controller.clear(); // Clear the text field after adding task
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
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
                      hintText: 'Who was born?',
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
                      GestureDetector(
                        onTap: () => _pickDate(context),
                        child: Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).focusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
        ],
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.check, color: Colors.green), onPressed: () {
        addTask();
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

