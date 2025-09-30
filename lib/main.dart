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
  bool _showFrame = true;

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

  void toggleFrame(bool value) {
    setState(() {
      _showFrame = value;
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
        showFrame: _showFrame,
        onFrameToggle: toggleFrame,
      ),
    );
  }
}

class FadingTextAnimation extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final Color textColor;
  final Function(Color) onTextColorChange;
  final bool showFrame;
  final Function(bool) onFrameToggle;

  FadingTextAnimation({
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.textColor,
    required this.onTextColorChange,
    required this.showFrame,
    required this.onFrameToggle,
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
          // Page indicator with navigation
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous button
                IconButton(
                  onPressed: _currentPage > 0 ? () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } : null,
                  icon: Icon(Icons.arrow_back_ios),
                  tooltip: 'Previous Page',
                ),
                // Page indicators
                for (int i = 0; i < 2; i++)
                  GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        i,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _currentPage
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    ),
                  ),
                // Next button
                IconButton(
                  onPressed: _currentPage < 1 ? () {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } : null,
                  icon: Icon(Icons.arrow_forward_ios),
                  tooltip: 'Next Page',
                ),
              ],
            ),
          ),
          // Swipe instruction
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              ' Page ${_currentPage + 1} of 2',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // PageView with different animations
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: AlwaysScrollableScrollPhysics(),
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
                print('Page changed to: $page'); // Debug print
              },
              children: [
                FadingAnimationPage(
                  title: 'Fast Fade',
                  text: 'Hello, Flutter!',
                  duration: Duration(milliseconds: 500),
                  color: Colors.blue,
                  textColor: widget.textColor,
                  showFrame: widget.showFrame,
                  onFrameToggle: widget.onFrameToggle,
                ),
                FadingAnimationPage(
                  title: 'Slow Fade',
                  text: 'Welcome to Flutter!',
                  duration: Duration(seconds: 3),
                  color: Colors.purple,
                  textColor: widget.textColor,
                  showFrame: widget.showFrame,
                  onFrameToggle: widget.onFrameToggle,
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
  final bool showFrame;
  final Function(bool) onFrameToggle;

  FadingAnimationPage({
    required this.title,
    required this.text,
    required this.duration,
    required this.color,
    required this.textColor,
    required this.showFrame,
    required this.onFrameToggle,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
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
          // Frame toggle switch
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.border_outer, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Frame',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 8),
                Switch(
                  value: widget.showFrame,
                  onChanged: widget.onFrameToggle,
                  activeColor: widget.color,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated image with rounded corners and optional frame
                  AnimatedOpacity(
                    opacity: _isVisible ? 1.0 : 0.0,
                    duration: widget.duration,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: widget.showFrame
                          ? BoxDecoration(
                              border: Border.all(
                                color: widget.color,
                                width: 4,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            )
                          : null,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(widget.showFrame ? 16 : 20),
                        child: Image.asset(
                          'panda.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to gradient container if image fails to load
                            return Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    widget.color.withOpacity(0.3),
                                    widget.color.withOpacity(0.7),
                                    widget.color.withOpacity(0.5),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.image,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Animated text
                  AnimatedOpacity(
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
                ],
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
                  heroTag: widget.title, // Unique hero tag to prevent conflicts
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
