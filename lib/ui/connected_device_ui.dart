import 'package:adskaya_drochilnya/inputs/colorpicker.dart';
import 'package:adskaya_drochilnya/inputs/radio.dart';
import 'package:adskaya_drochilnya/inputs/slider.dart';
import 'package:adskaya_drochilnya/inputs/switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ConnectedDeviceUi extends StatefulWidget {
  BluetoothDevice device;
  ConnectedDeviceUi({this.device});

  @override
  _ConnectedDeviceUiState createState() => _ConnectedDeviceUiState();
}

class _ConnectedDeviceUiState extends State<ConnectedDeviceUi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('"Да будет свет!" - сказал електрик'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[],
          ),
        ),
      ),
    );
  }
}
