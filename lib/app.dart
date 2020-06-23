import 'dart:async';

import 'package:adskaya_drochilnya/helpers/debounce.dart';
import 'package:adskaya_drochilnya/inputs/colorpicker.dart';
import 'package:adskaya_drochilnya/inputs/radio.dart';
import 'package:adskaya_drochilnya/inputs/slider.dart';
import 'package:adskaya_drochilnya/inputs/switch.dart';
import 'package:adskaya_drochilnya/ui/bluetootth_off_screen.dart';
import 'package:adskaya_drochilnya/ui/connected_device_ui.dart';
import 'package:adskaya_drochilnya/ui/connection_off_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert' show utf8;
import 'dart:convert' show ascii;

class AdskyiApp extends StatefulWidget {
  @override
  _AdskyiAppState createState() => _AdskyiAppState();
}

class _AdskyiAppState extends State<AdskyiApp> {
  String connectionText = "";
  final String SERVICE_UUID = "0000ffe0-0000-1000-8000-00805f9b34fb";
  final String CHARACTERISTIC_UUID = "0000ffe1-0000-1000-8000-00805f9b34fb";
  final String TARGET_DEVICE_NAME = "HMSoft";

  FlutterBlue fb = FlutterBlue.instance;

  BluetoothDevice device;
  BluetoothCharacteristic characteristic;

  StreamSubscription<ScanResult> scanSubscription;

  Color color;
  double brightness = 100;
  double speed = 10;
  bool active = false;
  int mode = -1;
  List<String> modes = [
    "Поймай меня",
    "Змейка",
    "Радуга",
    "Метеор",
    "Мерцание",
    "Обычный",
    "Плавный переход"
  ];

  startScan() {
    setState(() {
      connectionText = "Start Scanning";
    });

    scanSubscription = fb.scan().listen(
        (scanDevice) {
          if (scanDevice.device.name == TARGET_DEVICE_NAME) {
            stopScan();
            setState(() {
              connectionText = "Found Target Device";
            });
            device = scanDevice.device;
            connectToDevice();
          }
        },
        onDone: () => stopScan(),
        onError: (err) {
          print(err);
        });
  }

  stopScan() {
    scanSubscription?.cancel();
    FlutterBlue.instance.stopScan();
    scanSubscription = null;
  }

  connectToDevice() async {
    if (device == null) return;
    setState(() {
      connectionText = "Device connecting";
    });

    await device.connect();
    setState(() {
      connectionText = "Device connected";
    });
    discoverServices();
  }

  disconnectDevice() async {
    List<BluetoothDevice> devices = await FlutterBlue.instance.connectedDevices;

    devices.forEach((element) async {
      await element.disconnect();
    });
    stopScan();
    if (devices.length > 0)
      setState(() {
        connectionText = "Device disconnected";
      });
  }

  discoverServices() async {
    if (device == null) return;
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((ch) {
          if (ch.uuid.toString() == CHARACTERISTIC_UUID) {
            characteristic = ch;
            setState(() {
              connectionText =
                  "Characteristic R. All ready with device: ${device.name}";
            });
            setupListeners();
          }
        });
      }
      // do something with service
    });
  }

  setupListeners() async {
    await characteristic.setNotifyValue(true);
    characteristic.value.listen((event) {
      var parsed = utf8.decode(event);

      if (parsed != "") {
        print(parsed);
      }
    });
  }

  writeData(String data) async {
    if (device == null) return;
    print('Send: ' + data);
    List<int> bytes = ascii.encode(data + '\n');
    characteristic.write(bytes, withoutResponse: true);
  }

  String calculateByteValue(double sliderValue) {
    return (sliderValue * 2.55).toStringAsFixed(0);
  }

  Debouncer debouncer = Debouncer(milliseconds: 150);

  Widget getConnectedUI(BuildContext context) {
    return Column(
      children: <Widget>[
        RaisedButton(
          child: Text('Увімкнути/Вимкнути'),
          onPressed: () async {
            writeData('3');
          },
        ),
        // RaisedButton(
        //   child: Text('Перезагрузити модуль'),
        //   onPressed: () {
        //     writeData('5');
        //   },
        //   color: Colors.red,
        // ),
        AdskyiSlider(
          value: brightness,
          label: 'Регулювання освітлення',
          onChange: (value) {
            brightness = value;
            debouncer.run(() {
              writeData('7 ' + calculateByteValue(value));
            });
          },
        ),
        AdskyiColorPicker(
          value: Colors.yellow,
          onChange: (Color color) {
            writeData(
                "4 ${color.red.toString().padLeft(3, '0')} ${color.green.toString().padLeft(3, '0')} ${color.blue.toString().padLeft(3, '0')}");
          },
        ),
        AdskyiRadio(
          modes: modes,
          value: mode,
          label: "Режими",
          onChange: (value) {
            writeData("8 ${value}");
          },
        ),
      ],
    );
  }

  BluetoothDevice findDevice(List<BluetoothDevice> devices) {
    var found = devices.where((element) => element.name == TARGET_DEVICE_NAME);
    // search by single automatically will throw exception because no
    if (found.length > 0) return found.first;

    return null;
  }

  checkDevice() async {
    var devices = await fb.connectedDevices;
    var connectedDevice = findDevice(devices);
    if (connectedDevice != null) {
      device = connectedDevice;
      setState(() {
        connectionText = "Device connected";
      });
      discoverServices();
    }
  }

  @override
  void initState() {
    super.initState();
    checkDevice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('"Да будет свет!" - сказал електрик'),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(connectionText),
                StreamBuilder<List<BluetoothDevice>>(
                    builder: (_, snapshot) {
                      if (snapshot.hasData) {
                        var deviceExist = snapshot.data
                                .where((element) =>
                                    element.name == TARGET_DEVICE_NAME)
                                .length >
                            0;
                        if (deviceExist) {
                          return Text('Connected');
                        }
                      }
                      return Text('Not connected');
                    },
                    stream: Stream.periodic(Duration(seconds: 1)).asyncMap(
                        (_) => FlutterBlue.instance.connectedDevices)),
                RaisedButton(
                  onPressed: () {
                    startScan();
                  },
                  child: Text('Підключитись'),
                ),
                RaisedButton(
                  onPressed: () {
                    disconnectDevice();
                  },
                  child: Text('Відключитись'),
                ),
                if (device != null)
                  StreamBuilder<BluetoothDeviceState>(
                    stream: device.state,
                    builder: (_, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data == BluetoothDeviceState.connected) {
                        return getConnectedUI(context);
                      }
                      return Text('');
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
