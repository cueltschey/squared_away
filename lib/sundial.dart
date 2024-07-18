import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class SunAnimationScreen extends StatefulWidget {
  final double progress; // 0.0 to 1.0, where 0.0 is sunrise and 1.0 is sunset
  final List<double> taskProgressArray;
  final List<Color> taskColorArray;

  SunAnimationScreen({required this.progress, required this.taskColorArray, required this.taskProgressArray});

  @override
  _SunAnimationScreenState createState() => _SunAnimationScreenState();
}

class _SunAnimationScreenState extends State<SunAnimationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
        if(_animation.value >= widget.progress){
          _controller.stop();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, 400),
      painter: SunPainter(
        progress: _animation.value,
        taskProgressArray: widget.taskProgressArray,
        taskColorArray: widget.taskColorArray,
      ),
    );
  }
}

class SunPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0, where 0.0 is sunrise and 1.0 is sunset
  final List<double> taskProgressArray;
  final List<Color> taskColorArray;

  SunPainter({required this.progress, required this.taskColorArray, required this.taskProgressArray});

  @override
  void paint(Canvas canvas, Size size) {
    Color paintColor = Colors.orange;
    Color arcColor = Colors.yellow;
    if (progress > 0.8 || progress < 0.2) {
      paintColor = Colors.grey;
      arcColor = Color.fromARGB(255, 34, 34, 34);
    }
    final Paint paint = Paint()
      ..color = paintColor
      ..style = PaintingStyle.fill;

    final Paint arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw the arc
    final Rect arcRect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 1.2),
      radius: size.width / 2,
    );
    canvas.drawArc(arcRect, pi, pi, false, arcPaint);

    for (int i = 0; i < taskProgressArray.length; i++) {
      final double angle = pi * taskProgressArray[i];
      final double x = size.width / 2 + (size.width / 2) * cos(angle);
      final double y = size.height / 1.2 + (size.width / 2) * sin(angle) * -1;
      final Paint taskPaint = Paint()
        ..color = taskColorArray[i]
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 10, taskPaint);
    }

    // Calculate the sun position
    final double angle = pi * progress;
    final double sunX = size.width / 2 + (size.width / 2) * cos(angle);
    final double sunY = size.height / 1.2 + (size.width / 2) * sin(angle) * -1;

    // Draw the sun
    canvas.drawCircle(Offset(sunX, sunY), 20, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class SunScaffold extends StatefulWidget {
  final List<Map<String, dynamic>> taskList;
  final Map<String, dynamic> todayData;
  SunScaffold({super.key, required this.taskList, required this.todayData});
  @override
  _SunScaffoldState createState() => _SunScaffoldState();
}

class _SunScaffoldState extends State<SunScaffold> {
  double _progress = 0.0;
  List<double> _taskProgressArray = [];
  List<Color> _taskColorArray = [];
  List<Map<String, dynamic>> _tasksArray = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      widget.todayData['tasks'].forEach((key, value) {
        _taskColorArray.add(widget.taskList[key]['color']);
        _taskProgressArray.add(_calculateProgress(value));
        Map<String, dynamic> item = {};
        item['color'] = widget.taskList[key]['color'];
        item['text'] = widget.taskList[key]['name'];
        item['date'] = value;
        _tasksArray.add(item);
      });
      print(_tasksArray);
      _progress = _calculateProgress(DateTime.now());
    });
  }

  double _calculateProgress(DateTime now) {
    final sunrise = DateTime(now.year, now.month, now.day, 0, 0); // 6:00 AM
    final sunset = DateTime(now.year, now.month, now.day, 23, 0); // 6:00 PM
    final totalDayDuration = sunset.difference(sunrise).inSeconds;
    final currentDuration = now.difference(sunrise).inSeconds;

    if (currentDuration <= 0) {
      return 0.0;
    } else if (currentDuration >= totalDayDuration) {
      return 1.0;
    } else {
      return currentDuration / totalDayDuration;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sundial'),
      ),
      body: Column(
        children: [
          Padding(
                child: SunAnimationScreen(
                  progress: _progress,
                  taskColorArray: _taskColorArray,
                  taskProgressArray: _taskProgressArray,
                ),
                padding: EdgeInsets.all(30.0)
            ),
          Expanded(child:
          ListView.builder(
              itemCount: _tasksArray.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      _tasksArray[index]['text'],
                    style:  TextStyle(
                      color: _tasksArray[index]['color'],
                      fontSize: 20.0
                    ),
                  ),
                  trailing: Text(
                      _tasksArray[index]['date'].hour.toString() + ':' + _tasksArray[index]['date'].minute.toString(),
                    style: TextStyle(fontSize: 20.0)
                  ),
                );
              }
          )
          )
        ],
      )
    );
  }
}