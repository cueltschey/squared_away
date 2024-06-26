import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Squares extends StatelessWidget {
  final List<Map<String, dynamic>> squareData;
  final List<Map<String, dynamic>> taskList;
  final ScrollController controller;

  Squares({super.key, required this.squareData, required this.taskList, ScrollController? controller})
      : this.controller = controller ?? ScrollController();

  void _scrollToBottom(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.jumpTo(controller.position.maxScrollExtent);
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
    List<Widget> months = [];
    List<Widget> currentRow = [];
    List<Widget> monthRows = [];
    while(index < squareData.length){
      if(squareData[index]["isMonth"]){
        monthRows.add(Row(
          children: currentRow,
        ),);
        currentRow = [];
        if(index != 0){
          months.add(const Divider(
            thickness: 15.0,
            color: Colors.transparent,
          ));
          months.add(Text(
              squareData[index]['month']
          ));
        }

        months.add(Column(
          children: monthRows,
        ));
        monthRows = [];
        weekIndex = 0;
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
          percentage: getPercentage(squareData[index]['tasks'])
      ));
      index++;
      weekIndex++;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(context);
    });


    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: months.length,
          controller: controller,
          itemBuilder: (context, index)
           {
             return months[index];
           },
        )
      )
    );
  }
}

class SquareItem extends StatefulWidget {
  SquareItem({super.key, required this.data ,required this.taskList, required this.percentage});

  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> taskList;
  final List percentage;
  @override
  State<SquareItem> createState() => _SquareItemState();
}

class _SquareItemState extends State<SquareItem> {

  _SquareItemState();

  Map<String, dynamic> stateData = {};
  @override
  void initState() {
    super.initState();
    stateData = widget.data;
  }

  void _openPopup() {
    /*
    setState(() {
      widget.percentage[0]++;
    });
    */
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSquare(data: stateData, taskList: widget.taskList, percentage: widget.percentage, updateTask: _UpdateCompleted),
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
    stateData['tasks'][index][0] = value;
  }

  //List<Map<String, dynamic>> parseTasksDetailed(List<List<int>> taskData, List<Map<String, dynamic>> taskList){}

  @override
  Widget build(BuildContext context) {
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
            ),)
        ),
      )
    )
    );
  }
}


class EditSquare extends StatefulWidget {
  EditSquare({super.key, required this.data ,required this.taskList, required this.percentage, required this.updateTask});

  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> taskList;
  final List percentage;
  final Function(int, int) updateTask;
  @override
  State<EditSquare> createState() => _EditSquareState();
}

class _EditSquareState extends State<EditSquare> {
  List<bool> initCheckList(Map<String, dynamic> data){
    List<bool> result = [];
    for(int i = 0; i < data['tasks'].length; i++){
      if (data['tasks'][i] == 1){
        result.add(true);
      }
      else{
        result.add(false);
      }
    }
    return result;
  }
  List<bool> _isCheckedList = [];

  @override
  void initState() {
    super.initState();
    _isCheckedList = initCheckList(widget.data);
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
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text(widget.data['month'] + ", " + widget.data['date'].day.toString() + " " + widget.data['date'].year.toString())),
      body: ListView.builder(
        itemCount: widget.taskList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.taskList[index]['name']),
            subtitle: Text(widget.taskList[index]['category'].toString()),
            trailing: Checkbox(
              value: _isCheckedList[index],
              onChanged: (bool? isChecked) {
                _handleCheckboxChange(index, isChecked!);
              },
            ),
          );
        },
      ),
    );
  }
}



