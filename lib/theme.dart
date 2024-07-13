import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider(this._themeData);

  ThemeData get themeData => _themeData;

  void setTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
}

class ThemePicker extends StatelessWidget {
  final Function(int) setThemeCallback;
  ThemePicker({super.key, required this.setThemeCallback});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Theme Picker'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          _buildColorOption(
              context,
              'Basic Dark',
              Color.fromARGB(200, 34, 34, 34),
              Color.fromARGB(255, 200, 200, 200),
              Color.fromARGB(255, 14, 14, 14),
              true, setThemeCallback, 0),
          _buildColorOption(
              context,
              'Basic Light',
              Color.fromARGB(255, 200, 200, 200),
              Color.fromARGB(255, 34, 34, 34),
              Color.fromARGB(255, 230, 230, 230),
              false, setThemeCallback, 1),
          _buildColorOption(context,
              'Martian Dark',
              Color.fromARGB(200, 34, 34, 34),
              Color.fromARGB(255, 200, 255, 255),
              Color.fromARGB(200, 0, 17, 23),
              true, setThemeCallback, 2),
          _buildColorOption(
              context,
              'Martian Light',
              Color.fromARGB(200, 200, 255, 255),
              Color.fromARGB(255, 54, 54, 54),
              Color.fromARGB(200, 200, 220, 255),
              false, setThemeCallback, 3),
          _buildColorOption(
              context,
              'Salmon Dark',
              Color.fromARGB(200, 34, 34, 34),
              Color.fromARGB(255, 235, 150, 150),
              Color.fromARGB(200, 14, 14, 14),
              true, setThemeCallback, 4),
          _buildColorOption(
              context,
              'Salmon Light',
              Color.fromARGB(200, 235, 150, 150),
              Color.fromARGB(255, 34, 34, 34),
              Color.fromARGB(200, 200, 200, 200),
              false, setThemeCallback, 5),
        ],
      ),
    );
  }

  Widget _buildColorOption(BuildContext context, String label, Color primary, Color focus, Color background, bool isDark, Function setThemeCallback, int Id) {
    return GestureDetector(
      onTap: () {
        setThemeCallback(Id);
        ThemeData newTheme = ThemeData(
          brightness: isDark ? Brightness.dark : Brightness.light,
          primaryColor: primary,
          focusColor: focus,
          scaffoldBackgroundColor: background,
          // Add more properties as needed (e.g., textTheme, buttonTheme, etc.)
        );
        Provider.of<ThemeProvider>(context, listen: false).setTheme(newTheme);
      },
      child: Card(
        elevation: 4.0,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          tileColor: primary,
          title: Text(label, style: TextStyle(color: isDark? Colors.white : Colors.black)),
          leading: CircleAvatar(
            backgroundColor: focus,
          ),
          // Example of adding more customization to ListTile
          // subtitle: Text('Tap to apply'),
          // trailing: Icon(Icons.check_circle),
        ),
      ),
    );
  }
}