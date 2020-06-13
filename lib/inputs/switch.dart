import 'package:flutter/material.dart';

class AdskyiSwitch extends StatefulWidget {
  final String label;
  final Function(bool) onChange;
  bool value;

  AdskyiSwitch({@required this.label, this.value, @required this.onChange});
  @override
  AdskyiSwitchState createState() => AdskyiSwitchState();
}

class AdskyiSwitchState extends State<AdskyiSwitch> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(widget.label),
          Switch(
            value: widget.value,
            onChanged: (value) {
              setState(() {
                widget.value = value;
                widget.onChange(value);
              });
            },
          )
        ],
      ),
    );
  }
}
