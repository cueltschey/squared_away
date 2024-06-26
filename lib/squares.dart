import 'package:flutter/material.dart';
import 'appcolors.dart';

class Squares extends StatelessWidget {
  final List<Map<String, dynamic>> squareData;
  final ScrollController controller;

  Squares({super.key, required this.squareData, ScrollController? controller})
      : this.controller = controller ?? ScrollController();

  void _scrollToBottom(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.jumpTo(controller.position.maxScrollExtent);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    int index = 0;
    int weekIndex = 1;
    List<Widget> months = [];
    List<Widget> currentRow = [];
    List<Widget> monthRows = [];
    while(index < squareData.length){
      currentRow.add(SquareItem(
        counter: squareData[index]["index"],
        color: squareData[index]["color"],
        isMonth: squareData[index]["isMonth"],
      ));
      if(squareData[index]["isMonth"]){
        monthRows.add(Row(
          children: currentRow,
        ),);
        currentRow = [];
        months.add(const Divider(
          thickness: 15.0,
          color: Colors.transparent,
        ));
        months.add(const Text(
          "Text"
        ));
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
      index++;
      weekIndex++;
    }
    WidgetsBinding.instance!.addPostFrameCallback((_) {
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
  SquareItem({super.key, required this.counter, required this.color, required this.isMonth});

  int counter;
  final Color color;
  final bool isMonth;

  @override
  State<SquareItem> createState() => _SquareItemState();
}

class _SquareItemState extends State<SquareItem> {

  _SquareItemState();

  void _incrementCounter() {
    setState(() {
      widget.counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _incrementCounter,

    child: Padding(
      padding: EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(8.0)
        ),
        width: 45.0,
        height: 45.0,
        child: Center(
            child: Text(widget.isMonth.toString())
        ),
      )
    )
    );
  }
}