import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  Color _textColor = Colors.deepPurple;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void changeTextColor(Color color) {
    setState(() {
      _textColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: FadingTextAnimation(
        isDarkMode: _isDarkMode,
        onThemeToggle: toggleTheme,
        textColor: _textColor,
        onTextColorChange: changeTextColor,
      ),
    );
  }
}

class FadingTextAnimation extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final Color textColor;
  final Function(Color) onTextColorChange;

  FadingTextAnimation({
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.textColor,
    required this.onTextColorChange,
  });

  @override
  _FadingTextAnimationState createState() => _FadingTextAnimationState();
}

class _FadingTextAnimationState extends State<FadingTextAnimation> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickerColor = widget.textColor;
        return AlertDialog(
          title: Text('Pick a text color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Select'),
              onPressed: () {
                widget.onTextColorChange(pickerColor);
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
        title: Text('Fading Text Animation'),
        actions: [
          IconButton(
            onPressed: _openColorPicker,
            icon: Icon(Icons.palette),
            tooltip: 'Change Text Color',
          ),
          IconButton(
            onPressed: widget.onThemeToggle,
            icon: Icon(
              widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
            ),
            tooltip: widget.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          // Page indicator
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 2; i++)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _currentPage
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
          // PageView with different animations
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                FadingAnimationPage(
                  title: 'Fast Fade',
                  text: 'Hello, Flutter!',
                  duration: Duration(milliseconds: 500),
                  color: Colors.blue,
                  textColor: widget.textColor,
                ),
                FadingAnimationPage(
                  title: 'Slow Fade',
                  text: 'Welcome to Flutter!',
                  duration: Duration(seconds: 3),
                  color: Colors.purple,
                  textColor: widget.textColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FadingAnimationPage extends StatefulWidget {
  final String title;
  final String text;
  final Duration duration;
  final Color color;
  final Color textColor;

  FadingAnimationPage({
    required this.title,
    required this.text,
    required this.duration,
    required this.color,
    required this.textColor,
  });

  @override
  _FadingAnimationPageState createState() => _FadingAnimationPageState();
}

class _FadingAnimationPageState extends State<FadingAnimationPage> {
  bool _isVisible = true;

  void toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.color,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: AnimatedOpacity(
              opacity: _isVisible ? 1.0 : 0.0,
              duration: widget.duration,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: widget.color.withOpacity(0.3)),
                ),
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 24,
                    color: widget.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Duration: ${widget.duration.inMilliseconds}ms',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 10),
              FloatingActionButton(
                onPressed: toggleVisibility,
                backgroundColor: widget.color,
                child: Icon(Icons.play_arrow),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
