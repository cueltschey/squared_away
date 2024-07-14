import 'package:flutter/material.dart';

class Options extends StatelessWidget {
  final List<Widget> options;
  final List<Icon> icons;
  final List<String> subtitles;
  Options({super.key, required this.options, required this.icons, required this.subtitles});

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
              child: icons[index],
            ),
          );
        }),
      ),
    );
  }
}