import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider(this._themeData);

  ThemeData get themeData => _themeData;

  void setTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
}

class ThemePicker extends StatefulWidget {
  final Function(int) setThemeCallback;

  ThemePicker({super.key, required this.setThemeCallback});
  _ThemePickerState createState() => _ThemePickerState();
}

class _ThemePickerState extends State<ThemePicker>{


  List<Color> _selectedColors = [
    Color.fromARGB(200, 34, 34, 34),
    Color.fromARGB(255, 200, 200, 200),
    Color.fromARGB(255, 14, 34, 14),
  ];
  bool _isCustomDark = true;

  void _pickColor(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColors[index],
              enableAlpha: false,
              onColorChanged: (color) {
                setState(() {
                  _selectedColors[index] = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
              true, widget.setThemeCallback, 0),
          _buildColorOption(
              context,
              'Basic Light',
              Color.fromARGB(255, 200, 200, 200),
              Color.fromARGB(255, 34, 34, 34),
              Color.fromARGB(255, 230, 230, 230),
              false, widget.setThemeCallback, 1),
          _buildColorOption(context,
              'Martian Dark',
              Color.fromARGB(200, 34, 34, 34),
              Color.fromARGB(255, 200, 255, 255),
              Color.fromARGB(200, 0, 17, 23),
              true, widget.setThemeCallback, 2),
          _buildColorOption(
              context,
              'Martian Light',
              Color.fromARGB(200, 200, 255, 255),
              Color.fromARGB(255, 54, 54, 54),
              Color.fromARGB(200, 200, 220, 255),
              false, widget.setThemeCallback, 3),
          _buildColorOption(
              context,
              'Salmon Dark',
              Color.fromARGB(200, 34, 34, 34),
              Color.fromARGB(255, 235, 150, 150),
              Color.fromARGB(200, 14, 14, 14),
              true, widget.setThemeCallback, 4),
          _buildColorOption(
              context,
              'Salmon Light',
              Color.fromARGB(200, 235, 150, 150),
              Color.fromARGB(255, 34, 34, 34),
              Color.fromARGB(200, 200, 200, 200),
              false, widget.setThemeCallback, 5),
          _buildColorOption(
              context,
              'Custom Theme',
              _selectedColors[0],
              _selectedColors[1],
              _selectedColors[2],
              _isCustomDark, widget.setThemeCallback, 5),
          SizedBox(height: 50,),
          Row(
            children: [
              GestureDetector(
                onTap: () => _pickColor(context, 0),
                child: Icon(Icons.circle, color: _selectedColors[0], size: 40)
              ),
              GestureDetector(
                  onTap: () => _pickColor(context, 1),
                  child: Icon(Icons.circle, color: _selectedColors[1], size: 40)
              ),
              GestureDetector(
                  onTap: () => _pickColor(context, 2),
                  child: Icon(Icons.circle, color: _selectedColors[2], size: 40)
              ),
              Switch(value: _isCustomDark, onChanged: (bool? checked) => setState(() =>
                _isCustomDark = checked!
              ),
                activeColor: Colors.black,
                inactiveThumbColor: Colors.white,
              )
            ],
          )
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