import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart' as pc;
import 'package:fl_chart/fl_chart.dart';

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
    int index = data.length - 1;
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
      Color.fromARGB(255, 26, 120, 63),
      Color.fromARGB(230, 54, 106, 94),
      Color.fromARGB(230, 74, 82, 74),
      Color.fromARGB(200, 34, 34, 34),
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
                  pc.PieChart(
                    dataMap: dataMap,
                    animationDuration: Duration(milliseconds: 800),
                    chartLegendSpacing: 32,
                    chartRadius: MediaQuery
                        .of(context)
                        .size
                        .width / 2.7,
                    colorList: colorList,
                    initialAngleInDegree: 0,
                    chartType: pc.ChartType.ring,
                    ringStrokeWidth: 32,
                    legendOptions: const pc.LegendOptions(
                      showLegendsInRow: true,
                      legendPosition: pc.LegendPosition.bottom,
                      showLegends: true,
                      legendTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    chartValuesOptions: const pc.ChartValuesOptions(
                      showChartValueBackground: false,
                      showChartValues: true,
                      showChartValuesInPercentage: false,
                      chartValueStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              ),
            ),
            StatisticsLineChart(monthData: monthData,),
            DropdownButton<String>(
              value: _selectedItem,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedItem = newValue!;
                  _selectedIndex = _items.indexOf(newValue);
                  List<Map<String, dynamic>> newData = [];
                  if(_selectedIndex == 3){
                    newData = getDataFromDateOffset(widget.squareData, 1000000);
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










class _LineChart extends StatefulWidget {
  final monthData;

  _LineChart({required this.monthData});

  State<StatefulWidget> createState() => LineChartState();
}

class LineChartState extends State<_LineChart>{

  @override
  Widget build(BuildContext context) {
    return LineChart(
      sampleData1,
      duration: const Duration(milliseconds: 250),
    );
  }

  LineChartData get sampleData1 =>
      LineChartData(
        lineTouchData: lineTouchData1,
        gridData: gridData,
        titlesData: titlesData1,
        borderData: borderData,
        lineBarsData: lineBarsData1,
        minX: 0,
        maxX: widget.monthData.length.toDouble(),
        maxY: 1,
        minY: 0,
      );

  LineTouchData get lineTouchData1 =>
      LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
        ),
      );

  FlTitlesData get titlesData1 =>
      FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  List<LineChartBarData> get lineBarsData1 =>
      [
        lineChartBarData1_1,
      ];

  LineTouchData get lineTouchData2 =>
      const LineTouchData(
        enabled: false,
      );


  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 6:
        text = const Text("w", style: style);
        break;
      case 13:
        text = const Text('w2', style: style);
        break;
      case 20:
        text = const Text('w3', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }

  SideTitles get bottomTitles => SideTitles(
    showTitles: true,
    reservedSize: 32,
    interval: 1,
    getTitlesWidget: bottomTitleWidgets,
  );


  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    /*
    switch ((value * 10).toInt()) {
      case 0:
        text = '0%';
        break;
      case 5:
        text = "50%";
        break;
      case 7:
        text = '75%';
        break;
      case 10:
        text = '100%';
        break;
      default:
        return Container();
    }
    */

     text = (value * 100).toInt().toString() + "%";

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() =>
      SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 1,
        reservedSize: 40,
      );



  FlGridData get gridData => const FlGridData(show: false);

  FlBorderData get borderData =>
      FlBorderData(
        show: true,
        border: Border(
          bottom:
          BorderSide(color: Colors.blue, width: 4),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );


  void calculateCurrentData(){
    currentData = [];
    for(int i = 0; i < widget.monthData.length; i++){
      double total = 0;
      for(int j = 0; j < widget.monthData[i]['tasks'].length; j++){
        total += widget.monthData[i]['tasks'][j][0];
      }
      total /= widget.monthData[i]['tasks'].length;
      currentData.add(FlSpot(i.toDouble(), total));
    }
  }

  List<FlSpot> currentData = [];
  @override
  void initState() {
    super.initState();
    calculateCurrentData();
  }

  @override
  void didUpdateWidget(covariant _LineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.monthData != oldWidget.monthData){
      calculateCurrentData();
    }
  }

  LineChartBarData get lineChartBarData1_1 =>
      LineChartBarData(
        isCurved: true,
        gradient: const LinearGradient(
          colors: [
            Colors.deepPurple,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.orange,
            Colors.red,
          ]
        ),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: currentData
      );
}

class StatisticsLineChart extends StatefulWidget {
  final monthData;
  const StatisticsLineChart({super.key, required this.monthData});

  @override
  State<StatefulWidget> createState() => StatisticsLineChartState();
}

class StatisticsLineChartState extends State<StatisticsLineChart> {

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.23,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 30,),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 6),
                  child: SizedBox(
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    child: _LineChart(monthData: widget.monthData,),
                  )
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}