import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

class Statistics extends StatefulWidget {
  Statistics({super.key, required this.taskList, required this.squareData});
  final List<Map<String, dynamic>> taskList;
  final List<Map<String, dynamic>> squareData;

  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {

  List<Map<String, dynamic>> getDataFromDateOffset(List<Map<String, dynamic>> data, int daysOffset) {
    List<Map<String, dynamic>> result = [];
    int index = data.length - 2;
    int count = 0;
    while (count < daysOffset && index >= 0) {
      result.add(data[index]);
      count++;
      index--;
    }
    return result;
  }

  List<Map<String, dynamic>> monthData = [];
  Map<String, double> dataMap = {};
  List<Color> colorList = [];
  List<String> _items = ["this week", "this month", "this year", "forever"];
  int _selectedIndex = 0;
  String _selectedItem = "";

  @override
  void initState() {
    super.initState();
    _selectedIndex = 1;
    _selectedItem = _items[1];
    monthData = getDataFromDateOffset(widget.squareData, 31);
    dataMap = {
      "100%": 0,
      "75%": 0,
      "50%": 0,
      "0%": 0,
    };
    for (int i = 0; i < monthData.length; i++) {
      int sum = 0;
      for (int j = 0; j < monthData[i]['tasks'].length; j++) {
        if (monthData[i]['tasks'][j][0] == 1) {
          sum++;
        }
      }
      double ratio = sum / monthData[i]['tasks'].length;

      if (ratio == 1) {
        dataMap['100%'] = (dataMap['100%'] ?? 0) + 1;
      } else if (ratio >= 0.75) {
        dataMap['75%'] = (dataMap['75%'] ?? 0) + 1;
      } else if (ratio >= 0.5) {
        dataMap['50%'] = (dataMap['50%'] ?? 0) + 1;
      } else {
        dataMap['0%'] = (dataMap['0%'] ?? 0) + 1;
      }
    }
    colorList = [
      Colors.green,
      Colors.indigo,
      Colors.brown,
      Colors.red,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  PieChart(
                    dataMap: dataMap,
                    animationDuration: Duration(milliseconds: 800),
                    chartLegendSpacing: 32,
                    chartRadius: MediaQuery
                        .of(context)
                        .size
                        .width / 2.7,
                    colorList: colorList,
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 32,
                    legendOptions: const LegendOptions(
                      showLegendsInRow: true,
                      legendPosition: LegendPosition.bottom,
                      showLegends: true,
                      legendTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValueBackground: false,
                      showChartValues: true,
                      showChartValuesInPercentage: false,
                      chartValueStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              ),
            ),
            DropdownButton<String>(
              value: _selectedItem,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedItem = newValue!;
                  _selectedIndex = _items.indexOf(newValue);
                  List<Map<String, dynamic>> newData = [];
                  if(_selectedIndex == 3){
                    newData = widget.squareData;
                  } else if(_selectedIndex == 2){
                    newData = getDataFromDateOffset(widget.squareData, 365);
                  } else if(_selectedIndex == 1){
                    newData = getDataFromDateOffset(widget.squareData, 31);
                  } else{
                    newData = getDataFromDateOffset(widget.squareData, 7);
                  }
                  dataMap = {
                    "100%": 0,
                    "75%": 0,
                    "50%": 0,
                    "0%": 0,
                  };
                  monthData = newData;
                  for (int i = 0; i < newData.length; i++) {
                    int sum = 0;
                    for (int j = 0; j < newData[i]['tasks'].length; j++) {
                      if (newData[i]['tasks'][j][0] == 1) {
                        sum++;
                      }
                    }
                    double ratio = sum / newData[i]['tasks'].length;

                    if (ratio == 1) {
                      dataMap['100%'] = (dataMap['100%'] ?? 0) + 1;
                    } else if (ratio >= 0.75) {
                      dataMap['75%'] = (dataMap['75%'] ?? 0) + 1;
                    } else if (ratio >= 0.5) {
                      dataMap['50%'] = (dataMap['50%'] ?? 0) + 1;
                    } else {
                      dataMap['0%'] = (dataMap['0%'] ?? 0) + 1;
                    }
                  }
                });
              },
              items: _items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}