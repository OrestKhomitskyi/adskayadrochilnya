import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  var url = "http://192.168.0.118";
  double _currentBrightness = 20;

  void togglePower() async {
    await http.get(url + '/?power=on').timeout(Duration(seconds: 30));
  }

  void setBrightness() async {
    await http
        .get(url + '/?brightness=${_currentBrightness}')
        .timeout(Duration(seconds: 30));
  }

  void setMode(String mode) async {
    await http.get(url + '/?mode=${mode}').timeout(Duration(seconds: 30));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Лед контролювалка"),
      ),
      body: Column(
        children: <Widget>[
          FlatButton(onPressed: togglePower, child: Text('Увімкнути/Вимкнути')),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Slider(
                        label: 'Hi',
                        value: _currentBrightness,
                        min: 0,
                        max: 255,
                        onChanged: (value) {
                          setState(() {
                            _currentBrightness = value;
                          });
                        }),
                    Center(
                      child: Text(_currentBrightness.toStringAsFixed(0)),
                    )
                  ],
                ),
              ),
              FlatButton(
                  onPressed: setBrightness,
                  child: Text('Встановити \n яскравість'))
            ],
          ),
          Text(
            'Режими',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          FlatButton(
              onPressed: () => setMode('basic'), child: Text('1: Базовий')),
          FlatButton(
              onPressed: () => setMode('cylon'), child: Text('2: Cylon')),
          FlatButton(
              onPressed: () => setMode('meteor'), child: Text('3: Метеорчик')),
          FlatButton(
              onPressed: () => setMode('single'),
              child: Text('4: Одиночний колір')),
          FlatButton(
              onPressed: () => setMode('rainbow'), child: Text('5: Райдуга')),
        ],
      ),
    );
  }
}
