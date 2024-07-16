import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class AchievementsPage extends StatefulWidget {
  final List<Map<String, dynamic>> squareData;
  AchievementsPage({super.key, required this.squareData});

  @override
  _AchievementsState createState() => _AchievementsState();
}

class _AchievementsState extends State<AchievementsPage> with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int totalCompleted = 0;
  List<Map<String, dynamic>> completedSquares = [];


  @override
  Widget build(BuildContext context) {
    bool allCompleted = true;
    for(int j = 0; j < widget.squareData.last['tasks'].length; j++){
      print(widget.squareData.last['tasks'][j]);
      if(widget.squareData.last['tasks'][j][0] != 1){
        allCompleted = false;
      }
    }
    if(allCompleted){
      totalCompleted++;
      completedSquares.add(widget.squareData.last);
    }

    for(int i = widget.squareData.length - 2; i > 0; i--){
      bool allCompleted = true;
      for(int j = 0; j < widget.squareData[i]['tasks'].length; j++){
        print(widget.squareData[i]['tasks'][j]);
        if(widget.squareData[i]['tasks'][j][0] != 1){
          allCompleted = false;
        }
      }
      if(allCompleted){
        totalCompleted++;
        completedSquares.add(widget.squareData[i]);
      } else{
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Streaks'),
      ),
      body: Column(
        children: [
          SizedBox(height: 100,),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (int i = 0; i < totalCompleted; i++)
                  AnimatedBuilder(
                    animation: _controller,
                    child: Text('🔥', style: TextStyle(fontSize: 30)),
                    builder: (context, child) {
                      double angle = 2 * pi * i / totalCompleted + _controller.value * 2 * pi;
                      return Transform.translate(
                        offset: Offset(100 * cos(angle), 100 * sin(angle)),
                        child: child,
                      );
                    },
                  ),
                Text(
                    totalCompleted.toString(),
                    style: TextStyle(
                        fontSize: (20 + totalCompleted).toDouble(),
                        fontWeight: FontWeight.bold
                    )
                ),
              ],
            ),
          ),
          SizedBox(height: 150,),
          Text("Completed Squares:", style: TextStyle(fontSize: 20.0)),
          Expanded(child: GridView.builder(
              itemCount: completedSquares.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index){
                return Padding(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.green,
                        width: 10.0
                      ),
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                      child: Center(child: Text(
                      completedSquares[index]['date'].month.toString() + '/' + completedSquares[index]['date'].day.toString(),
                    style: TextStyle(
                      fontSize: 20.0
                    ),
                  ),
                ),
                  ),
                  padding: EdgeInsets.all(5.0),
                );
              }
          )),
        ],
      )
    );
  }
}