import 'package:flutter/material.dart';

class AdskyiSlider extends StatefulWidget {
  final String label;
  final Function(double) onChange;
  double min;
  double max;
  double value;

  AdskyiSlider(
      {@required this.label,
      @required this.value,
      @required this.onChange,
      this.min,
      this.max});

  @override
  AdskyiSliderState createState() => AdskyiSliderState();
}

class AdskyiSliderState extends State<AdskyiSlider> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(widget.label),
          Slider(
            min: widget.min ?? 0,
            label: 'adad',
            max: widget.max ?? 100,
            value: widget.value,
            onChanged: (value) {
              setState(() {
                widget.value = value;
                widget.onChange(value);
              });
            },
          ),
          Center(
            child: Text(widget.value.toStringAsFixed(0)),
          )
        ],
      ),
    );
  }
}
