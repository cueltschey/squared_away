import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Squares extends StatelessWidget {
  final List<Map<String, dynamic>> squareData;
  final List<Map<String, dynamic>> taskList;
  final ScrollController controller;
  final Function(int, int, int) setTaskCallback;

  Squares({super.key, required this.squareData, required this.taskList, required this.setTaskCallback, ScrollController? controller})
      : this.controller = controller ?? ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.position.pixels < controller.position.maxScrollExtent) {
        controller.animateTo(
          controller.position.maxScrollExtent + 1000,
          duration: Duration(seconds: 2),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  List getPercentage(List<List<int>> taskData){
    int completed = 0;
    for(int i = 0; i < taskData.length; i++){
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
    while(index < squareData.length){
      if(squareData[index]["isMonth"]){

        if(index != 0){
          months.add(const Divider(
            thickness: 15.0,
            color: Colors.transparent,
          ));
          months.add(Text(
              squareData[index - 1]['month']
          ));
        }

        monthRows.add(Row(
          children: currentRow,
        ),);
        currentRow = [];


        months.add(Column(
          children: monthRows,
        ));
        monthRows = [];
        String weekDay = DateFormat('EEEE').format(squareData[index]['date']);
        weekIndex = weekdayToPadding[weekDay] ?? 0;
        for(int i = 0; i < weekIndex; i++){
          currentRow.add(Padding(padding: EdgeInsets.all(2.0),
              child:Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(width: 4, color: Colors.transparent)
            ),
          )));
        }
      }
      if(weekIndex == 7) {
        monthRows.add(Row(
          children: currentRow,
        ),);
        currentRow = [];
        weekIndex = 0;
      }
      currentRow.add(SquareItem(
          data: squareData[index],
          taskList: taskList,
          percentage: getPercentage(squareData[index]['tasks']),
          squareIndex: index,
          setTaskCallback: setTaskCallback,
          isHighlighted: index == squareData.length - 2
      ));
      index++;
      weekIndex++;
    }

    months.add(const Divider(thickness: 30.0, color: Colors.transparent,));

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
        child:  SingleChildScrollView(
          controller: controller,
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: months,
          ),
        ),
      )
    );
  }
}

class SquareItem extends StatefulWidget {
  SquareItem({super.key, required this.data ,required this.taskList, required this.percentage, required this.squareIndex, required this.setTaskCallback,
  required this.isHighlighted});

  final isHighlighted;
  final int squareIndex;
  final Function(int, int, int) setTaskCallback;
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> taskList;
  final List percentage;
  @override
  State<SquareItem> createState() => _SquareItemState();
}

class _SquareItemState extends State<SquareItem> {

  _SquareItemState();
  @override

  void _openPopup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSquare(
            data: widget.data,
            taskList: widget.taskList,
            percentage: widget.percentage,
            updateTask: _UpdateCompleted,
            getCheckList: _GetCheckList
        ),
      ),
    );
  }

  double calculateColorComponent(double base, double percentage) {
    return 34 + (percentage * 0.8) * base;
  }

  int toInt(double value) {
    return value.toInt();
  }

  void _UpdateCompleted(int index, int value){
    widget.setTaskCallback(widget.squareIndex, index, value);
  }

  List<bool> _GetCheckList(){
    List<bool> result = [];
    for(int i = 0; i < widget.data['tasks'].length; i++){
      result.add(widget.data['tasks'][i][0] == 1);
    }
    return result;
  }

  //List<Map<String, dynamic>> parseTasksDetailed(List<List<int>> taskData, List<Map<String, dynamic>> taskList){}

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.white;
    Color squareColor = Color.fromARGB(
      200,  // Opacity set to maximum (255)
      toInt(calculateColorComponent(100, (widget.percentage[1] - widget.percentage[0]) / widget.percentage[1])),
      toInt(calculateColorComponent(120, widget.percentage[0] / widget.percentage[1])),
      toInt(calculateColorComponent(100, widget.percentage[0] / widget.percentage[1])),
    );
    if(widget.percentage[0] == 0){
      squareColor = Color.fromARGB(150, 34, 34, 34);
    }
    if(widget.percentage[0] == widget.percentage[1]){
      squareColor = Color.fromARGB(255, 26, 120, 63);
    }
    if(widget.isHighlighted){
      textColor = Colors.yellow;
    }
    return GestureDetector(
      onTap: _openPopup,

    child: Padding(
      padding: EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromARGB(150, 34, 34, 34),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: squareColor,
              width: 4.0,
            ),
        ),
        width: 45.0,
        height: 45.0,
        child: Center(
            child: Text(widget.percentage[0].toString() + ":" + widget.percentage[1].toString(), style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: textColor
            ),)
        ),
      )
    )
    );
  }
}


class EditSquare extends StatefulWidget {
  EditSquare({super.key, required this.data ,required this.taskList, required this.percentage, required this.updateTask, required this.getCheckList});

  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> taskList;
  final List percentage;
  final Function(int, int) updateTask;
  final Function() getCheckList;
  @override
  State<EditSquare> createState() => _EditSquareState();
}

class _EditSquareState extends State<EditSquare> {

  List<bool> _isCheckedList = [];

  @override
  void initState() {
    super.initState();
    _isCheckedList = widget.getCheckList();
  }

  void _handleCheckboxChange(int index, bool isChecked) {
    setState(() {
      _isCheckedList[index] = isChecked;
      if(isChecked){
        widget.updateTask(index, 1);
      }
      else{
        widget.updateTask(index, 0);
      }
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat("EEEE").format(widget.data['date']) +
              " " +
              widget.data['month'] +
              " " +
              widget.data['date'].day.toString() +
              ", " +
              widget.data['date'].year.toString(),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.data['tasks'].length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              widget.taskList[index]['name'],
              style: TextStyle(color: widget.taskList[index]['color']),
            ),
            trailing: Checkbox(
              value: _isCheckedList[index],
              onChanged: (bool? isChecked) {
                _handleCheckboxChange(index, isChecked!);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.check, color: Colors.green),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}



