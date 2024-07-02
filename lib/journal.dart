import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Journal extends StatelessWidget {
  final List<Map<String, dynamic>> squareData;
  final List<Map<String, dynamic>> taskList;
  final ScrollController controller;
  final Function(int, int, int) setTaskCallback;

  Journal({
    super.key,
    required this.squareData,
    required this.taskList,
    required this.setTaskCallback,
    ScrollController? controller,
  }) : this.controller = controller ?? ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (controller.position.pixels < controller.position.maxScrollExtent) {
        controller.animateTo(
          controller.position.maxScrollExtent + 1000,
          duration: Duration(seconds: 2),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  List<int> getPercentage(List<List<int>> taskData) {
    int completed = 0;
    for (int i = 0; i < taskData.length; i++) {
      completed += taskData[i][0];
    }
    return [completed, taskData.length];
  }

  @override
  Widget build(BuildContext context) {
    int index = 0;
    int weekIndex = 1;
    Map<String, int> weekdayToPadding = {
      "Sunday": 0,
      "Monday": 1,
      "Tuesday": 2,
      "Wednesday": 3,
      "Thursday": 4,
      "Friday": 5,
      "Saturday": 6,
    };
    List<Widget> months = [];
    List<Widget> currentRow = [];
    List<Widget> monthRows = [];
    while (index < squareData.length) {
      if (squareData[index]["isMonth"]) {
        if (index != 0) {
          months.add(const Divider(
            thickness: 15.0,
            color: Colors.transparent,
          ));
          months.add(Text(squareData[index - 1]['month']));
        }

        monthRows.add(Row(
          children: currentRow,
        ));
        currentRow = [];

        months.add(Column(
          children: monthRows,
        ));
        monthRows = [];

        String weekDay = DateFormat('EEEE').format(squareData[index]['date']);
        weekIndex = weekdayToPadding[weekDay] ?? 0;

        for (int i = 0; i < weekIndex; i++) {
          currentRow.add(
            Padding(
              padding: EdgeInsets.all(2.0),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(width: 4, color: Colors.transparent),
                ),
              ),
            ),
          );
        }
      }

      if (weekIndex == 7) {
        monthRows.add(
          Row(
            children: currentRow,
          ),
        );
        currentRow = [];
        weekIndex = 0;
      }

      currentRow.add(
        JournalItem(
          data: squareData[index],
          taskList: taskList,
          percentage: getPercentage(squareData[index]['tasks']),
          squareIndex: index,
          setTaskCallback: setTaskCallback,
          isHighlighted: index == squareData.length - 1,
        ),
      );

      index++;
      weekIndex++;
    }

    monthRows.add(
      Row(
        children: currentRow,
      ),
    );

    months.add(
      Column(
        children: monthRows,
      ),
    );

    months.add(const Divider(thickness: 30.0, color: Colors.transparent));

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: _scrollToBottom,
        child: Icon(Icons.arrow_downward, color: Colors.white),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          controller: controller,
          child: Wrap(
            direction: Axis.horizontal,
            spacing: 8.0,
            runSpacing: 4.0,
            children: months,
          ),
        ),
      ),
    );
  }
}

class JournalItem extends StatefulWidget {
  JournalItem({
    super.key,
    required this.data,
    required this.taskList,
    required this.percentage,
    required this.squareIndex,
    required this.setTaskCallback,
    required this.isHighlighted,
  });

  final bool isHighlighted;
  final int squareIndex;
  final Function(int, int, int) setTaskCallback;
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> taskList;
  final List<int> percentage;

  @override
  State<JournalItem> createState() => _JournalItemState();
}

class _JournalItemState extends State<JournalItem> {
  void _openPopup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditJournal(
          pathString: filePath,
          setFileExistsCallback: setFileExistsCallback,
        ),
      ),
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    directory.create(recursive: true);
    return directory.path;
  }

  double calculateColorComponent(double base, double percentage) {
    return 34 + (percentage * 0.8) * base;
  }

  int toInt(double value) {
    return value.toInt();
  }

  String filePath = "";
  bool fileExists = false;

  void setFileExistsCallback(bool exists){
    setState(() {
      fileExists = exists;
    });
  }

  void _setFilePath() async {
    final basePath = await _localPath;
    setState(() {
      filePath = basePath + "/" + widget.data['date'].year.toString() + "-" + widget.data['date'].month.toString() + "-" + widget.data['date'].day.toString() + ".md";
    });
    File openedFile = File(filePath);
    if(await openedFile.exists()){
      setState(() {
        fileExists = true;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    _setFilePath();
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.white;
    Color squareColor = Color.fromARGB(
      200, // Opacity set to maximum (255)
      toInt(calculateColorComponent(100, (widget.percentage[1] - widget.percentage[0]) / widget.percentage[1])),
      toInt(calculateColorComponent(120, widget.percentage[0] / widget.percentage[1])),
      toInt(calculateColorComponent(100, widget.percentage[0] / widget.percentage[1])),
    );

    if (widget.percentage[0] == 0) {
      squareColor = Color.fromARGB(150, 34, 34, 34);
    }
    if (widget.percentage[0] == widget.percentage[1]) {
      squareColor = Color.fromARGB(255, 26, 120, 63);
    }
    if (widget.isHighlighted) {
      textColor = Colors.yellow;
    }

    return GestureDetector(
      onTap: _openPopup,
      child: Padding(
        padding: EdgeInsets.all(2.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(150, 34, 34, 34),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: squareColor,
              width: 4.0,
            ),
          ),
          width: 45.0,
          height: 45.0,
          child: Center(
            child: fileExists ? Icon(Icons.book) : Icon(Icons.disabled_by_default)
          ),
        ),
      ),
    );
  }
}

ScrollController _scroll_controller = ScrollController();

class EditJournal extends StatefulWidget {
  final String pathString;
  final Function(bool) setFileExistsCallback;

  EditJournal({super.key, required this.pathString, required this.setFileExistsCallback});

  @override
  _EditJournalState createState() => _EditJournalState();
}

class _EditJournalState extends State<EditJournal> {
  TextEditingController _controller = TextEditingController();
  String _markdownText = '';
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    directory.create(recursive: true);
    return directory.path;
  }

  @override
  void initState() {
    super.initState();
    _openMarkdownFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journal Editor'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: TextField(
                controller: _controller,
                maxLines: null,
                onChanged: (text) {
                  setState(() {
                    _markdownText = text;
                    if (_scroll_controller.position.pixels < _scroll_controller.position.maxScrollExtent) {
                      _scroll_controller.animateTo(
                        _scroll_controller.position.maxScrollExtent + 1000,
                        duration: Duration(seconds: 2),
                        curve: Curves.fastOutSlowIn,
                      );
                    }
                    widget.setFileExistsCallback(true);
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Markdown text here...',
                ),
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll_controller,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MarkdownBody(
                  data: _markdownText,
                  softLineBreak: true,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(fontSize: 18.0), // Paragraph text style
                    h1: TextStyle(fontSize: 32.0), // Heading 1 style
                    h2: TextStyle(fontSize: 28.0), // Heading 2 style
                    h3: TextStyle(fontSize: 24.0), // Heading 3 style
                    h4: TextStyle(fontSize: 22.0), // Heading 4 style
                    h5: TextStyle(fontSize: 20.0), // Heading 5 style
                    h6: TextStyle(fontSize: 18.0), // Heading 6 style
                  ),
                  selectable: true, // Optional: Make text selectable
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMarkdownFile() async {
    final basePath = await _localPath;
    File file = File('$basePath/${widget.pathString}');
    if (await file.exists()) {
      print("File exists continue...");
    } else {
      print("creating file: " + '$basePath/${widget.pathString}');
      file.create(recursive: true);
    }
    String text = await file.readAsString();
    _controller.text = text;
    setState(() {
      _markdownText = text;
    });
  }

  Future<void> _saveMarkdownFile() async {
    final basePath = await _localPath;
    File file = File('$basePath/${widget.pathString}');
    await file.writeAsString(_markdownText);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File saved successfully', style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromARGB(200, 34, 34, 34)
      ),
    );
  }
  @override
  void dispose() {
    _saveMarkdownFile();
    super.dispose();
  }
}