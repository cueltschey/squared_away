import 'package:flutter/material.dart';

class Options extends StatelessWidget {
  List<Widget> options = [
    Text("one"),
    Text("two")
  ];

  List<Icon> icons = [
    Icon(Icons.star, size: 50.0),
    Icon(Icons.add, size: 50.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Icon Grid'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: List.generate(options.length, (index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => options[index]),
              );
            },
            child: Card(
              child: Center(
                child: icons[index],
              ),
            ),
          );
        }),
      ),
    );
  }
}