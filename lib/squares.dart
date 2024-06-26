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
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollToBottom(context);
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          controller: controller,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // Number of squares in a row
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            ),
          itemCount: squareData.length,
          itemBuilder: (context, index) {
            final item = squareData[index];
            if(index % 10 == 0){
              return Column(
                children: [

                ],
              );
            }
            return SquareItem(counter: item['index'], color: item['color']);
          },
        )
      )
    );
  }
}

class SquareItem extends StatefulWidget {
  SquareItem({super.key, required this.counter, required this.color});

  int counter;
  final Color color;

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

    child: Container(
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(8.0)
      ),
      width: 50.0,
      height: 50.0,
      child: Center(
          child: Text(widget.counter.toString())
      ),
    )
    );
  }
}