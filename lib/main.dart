import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(CalculatorApp());

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            minimumSize: MaterialStateProperty.all<Size>(Size(72.0, 72.0)),
          ),
        ),
      ),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '';

  void _updateDisplay(String value) {
    setState(() {
      _display += value;
    });
  }

  String _formatResult(double result) {
    if (result % 1 == 0) {
      return result.toInt().toString();
    } else {
      return result.toStringAsFixed(1);
    }
  }

  void _calculate() {
    setState(() {
      try {
        Parser p = Parser();
        Expression exp = p.parse(_display);
        ContextModel cm = ContextModel();
        String result = exp.evaluate(EvaluationType.REAL, cm).toString();
        _display = _formatResult(double.parse(result));
      } catch (e) {
        _display = 'Error';
      }
    });
  }

  void _clearDisplay() {
    setState(() {
      _display = '';
    });
  }

  void _saveToHistory() async {
    if (_display.isNotEmpty && _display != 'Error') {
      final file = await _getLocalFile();
      file.writeAsStringSync(_display + '\n', mode: FileMode.append);
    }
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/history.txt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalkulator'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _display,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('7'),
              _buildButton('8'),
              _buildButton('9'),
              _buildButton('+'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('4'),
              _buildButton('5'),
              _buildButton('6'),
              _buildButton('-'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('1'),
              _buildButton('2'),
              _buildButton('3'),
              _buildButton('*'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('0'),
              _buildButton('.'),
              _buildButton('='),
              _buildButton('/'),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _clearDisplay,
                child: Text(
                  'Clear',
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
              SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: _saveToHistory,
                child: Text(
                  'Simpan',
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String value) {
    return ElevatedButton(
      onPressed: () {
        if (value == '=') {
          _calculate();
        } else {
          _updateDisplay(value);
        }
      },
      child: Text(
        value,
        style: TextStyle(fontSize: 24.0),
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _history = '';

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/history.txt');
  }

  Future<void> _readHistory() async {
    try {
      final file = await _getLocalFile();
      final contents = await file.readAsString();
      setState(() {
        _history = contents;
      });
    } catch (e) {
      setState(() {
        _history = '';
      });
    }
  }

  Future<void> _clearHistory() async {
    final file = await _getLocalFile();
    await file.writeAsString('');
    setState(() {
      _history = '';
    });
  }

  @override
  void initState() {
    super.initState();
    _readHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          _history,
          style: TextStyle(fontSize: 48.0),
        ),
      ),
    );
  }
}
