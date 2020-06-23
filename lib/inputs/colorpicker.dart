import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AdskyiColorPicker extends StatefulWidget {
  Color value;
  final Function(Color) onChange;
  AdskyiColorPicker({@required this.value, @required this.onChange});

  @override
  _AdskyiColorPickerState createState() => _AdskyiColorPickerState();
}

class _AdskyiColorPickerState extends State<AdskyiColorPicker> {
  void _onPressed() {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Оберіть колір'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ColorPicker(
                  pickerColor: widget.value,
                  onColorChanged: (rcolor) {
                    setState(() {
                      widget.value = rcolor;
                    });
                  },
                  showLabel: true,
                  enableAlpha: false,
                  displayThumbColor: false,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Благословити'),
              onPressed: () {
                widget.onChange(widget.value);
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
    return Container(
      child: RaisedButton(
        child: Text('Обрати колір'),
        onPressed: _onPressed,
      ),
    );
  }
}
