import 'package:flutter/material.dart';

class AdskyiRadio extends StatefulWidget {
  final List<String> modes;
  final String label;
  final Function(int) onChange;
  int value;

  AdskyiRadio(
      {@required this.modes, this.label, this.value, @required this.onChange});
  @override
  _AdskyiRadioState createState() => _AdskyiRadioState();
}

class _AdskyiRadioState extends State<AdskyiRadio> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(widget.label),
          ...widget.modes.map((e) {
            int index = widget.modes.indexOf(e);
            bool isMatch = index == widget.value;
            return Row(children: <Widget>[
              Radio(
                value: isMatch,
                groupValue: true,
                onChanged: (value) {
                  setState(() {
                    widget.value = index;
                    widget.onChange(index);
                  });
                },
              ),
              Text(e)
            ]);
          }).toList()
        ],
      ),
    );
  }
}
