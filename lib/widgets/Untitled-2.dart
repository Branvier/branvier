import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _text = "Arthur";
  List<String> _texts = ["Arthur", "Meg", "Marialda"];
  int _counter = 0;

  void _changeText() {
    setState(() {
      _text = _texts[_counter];
      _counter = (_counter + 1) % _texts.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Toggle Text"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _text,
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _changeText,
                child: Text("Toggle"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
