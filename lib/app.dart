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
  List<String> modes = [];

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
            writeData('3');
            setState(() {
              connectionText =
                  "Characteristic R. All ready with device: ${device.name}";
            });
            setupListeners();
            getInfo();
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
      if (parsed.startsWith('M')) {
        var parsedMode = parsed.split('');
        parsedMode.removeAt(0);
        var parsedString = parsedMode.join('');
        setState(() {
          if (modes.contains(parsedString) == false) {
            modes.add(parsedString);
          }
        });
      }

      if (parsed == "SPOWERON") {
        setState(() {
          active = true;
        });
      }
      if (parsed == "SPOWEROFF") {
        setState(() {
          active = false;
        });
      }
      if (parsed.startsWith("SMODE")) {
        var value = int.tryParse(parsed.substring(5), radix: 10);
        setState(() {
          mode = value ?? -1;
        });
      }

      if (parsed.startsWith("SBRIGHT")) {
        var value = int.tryParse(parsed.substring(7), radix: 10);
        setState(() {
          brightness = value / 2.55;
        });
      }

      if (parsed.startsWith("SSPEED")) {
        var value = int.tryParse(parsed.substring(6), radix: 10);
        setState(() {
          speed = value / 1.0;
        });
      }

      if (parsed.startsWith("SR")) {
        var value = int.tryParse(parsed.substring(2), radix: 10);

        setState(() {
          color = Color.fromRGBO(value, color.green, color.blue, 1);
        });
      }

      if (parsed.startsWith("SG")) {
        var value = int.tryParse(parsed.substring(2), radix: 10);

        setState(() {
          color = Color.fromRGBO(color.red, value, color.blue, 1);
        });
      }

      if (parsed.startsWith("SB")) {
        var value = int.tryParse(parsed.substring(2), radix: 10);

        setState(() {
          color = Color.fromRGBO(color.red, color.green, value, 1);
        });
      }

      print('Receive: ');
      if (parsed != "") {
        print(parsed);
      }
    });
  }

  writeData(String data) async {
    if (device == null) return;
    print('Send: ' + data);
    List<int> bytes = utf8.encode(data);
    await characteristic.write(bytes, withoutResponse: true);
  }

  getInfo() async {
    writeData('1');
    setState(() {
      connectionText = "Received status of module";
    });
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      connectionText = "Getting modes of module";
    });

    writeData('2');
    setState(() {
      connectionText = "Receiving modes of module";
    });
  }

  String calculateByteValue(double sliderValue) {
    return (sliderValue * 2.55).toStringAsFixed(0);
  }

  Debouncer debouncer = Debouncer(milliseconds: 150);

  Widget getConnectedUI(BuildContext context) {
    return Column(
      children: <Widget>[
        AdskyiSwitch(
          label: 'Увімкнути',
          value: active,
          onChange: (value) async {
            writeData('3');
          },
        ),
        RaisedButton(
          child: Text('Перезагрузити модуль'),
          onPressed: () {
            writeData('5');
          },
          color: Colors.red,
        ),
        AdskyiSlider(
          value: brightness,
          label: 'Регулювання освітлення',
          onChange: (value) {
            debouncer.run(() {
              brightness = value;
              writeData('9 ' + calculateByteValue(value));
            });
          },
        ),
        AdskyiSlider(
          value: speed,
          label: 'Регулювання швидкості',
          min: 1,
          max: 15,
          onChange: (value) async {
            debouncer.run(() {
              writeData('6 ' + (value).toStringAsFixed(0));
            });
            print(value);
          },
        ),
        AdskyiColorPicker(
          value: Colors.yellow,
          onChange: (Color color) {
            writeData("4 ${color.red} ${color.green} ${color.blue}");
          },
        ),
        RaisedButton(
          child: Text('Статус'),
          onPressed: () async {
            getInfo();
            // showDialog(
            //     context: context,
            //     builder: (BuildContext context) {
            //       return AlertDialog(
            //         title: Text("Статус"),
            //         content: Text("Харчування: ${active}"),
            //       );
            //     });
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

    //Timer.periodic(Duration(seconds: 10), (Timer t) => writeData('1'));
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
