import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

class Statistics extends StatefulWidget {
  Statistics({super.key, required this.taskList, required this.squareData, required this.typeList});
  final List<Map<String, dynamic>> taskList;
  final List<Map<String, dynamic>> typeList;
  final List<Map<String, dynamic>> squareData;

  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  List<Map<String, dynamic>> getMonthData(List<Map<String, dynamic>> data){
    List<Map<String, dynamic>> result = [];
    int currentMonth = DateTime.now().month;
    int index = data.length - 2;
    while(data[index]["date"].month > currentMonth){
      result.add(data[index]);
      index--;
    }
    return result;
  }

  Map<String, double> getDataMap(List<Map<String, dynamic>> monthData){
    Map<String, double> result = {
      "Complete: (100%)": 2,
      "Working on it (<75%)": 3,
      "Struggling (<50%)": 0,
      "Failed (0%)": 1
    };
    for(int i = 0; i < monthData.length; i++){
      num sum = 0;
      for(int j = 0; j < monthData[i]['tasks'].length; i++){
        sum += monthData[i]['tasks'][j][0];
      }
      num ratio = sum / monthData[i]['tasks'].length;
      if (ratio >= 1.0) {
        result["Complete: (100%)"] = (result["Complete: (100%)"] ?? 0) + 1;
      } else if (ratio >= 0.75) {
        result["Working on it (<75%)"] = (result["Working on it (<75%)"] ?? 0) + 1;
      } else if (ratio >= 0.5) {
        result["Struggling (<50%)"] = (result["Struggling (<50%)"] ?? 0) + 1;
      } else {
        result["Failed (0%)"] = (result["Failed (0%)"] ?? 0) + 1;
      }
    }
    return result;
  }

  List<Map<String, dynamic>> monthData = [];
  Map<String, double> dataMap = {};
  List<Color> colorList = [];

  @override
  void initState() {
    super.initState();
    monthData = getMonthData(widget.squareData);
    dataMap = getDataMap(monthData);
    colorList = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
    ];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Center(
            child: Text(monthData.toString()),
          ),
          Padding(padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
              PieChart (
              dataMap: dataMap,
              animationDuration: Duration(milliseconds: 800),
              chartLegendSpacing: 32,
              chartRadius: MediaQuery.of(context).size.width / 2.7,
              colorList: colorList,
              initialAngleInDegree: 0,
              chartType: ChartType.disc,
              ringStrokeWidth: 32,
              centerText: "Square Completion",
              legendOptions: const LegendOptions(
                showLegendsInRow: true,
                legendPosition: LegendPosition.bottom,
                showLegends: true,
                legendTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              chartValuesOptions: const ChartValuesOptions(
                showChartValueBackground: true,
                showChartValues: true,
                showChartValuesInPercentage: false,
                showChartValuesOutside: false,
              ),
            ),

              ],
            )
          )
        ],
      ),
    );
  }
}