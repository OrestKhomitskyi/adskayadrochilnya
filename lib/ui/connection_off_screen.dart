import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ConnectionOffScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.bluetooth_disabled,
            size: 200.0,
            color: Colors.white54,
          ),
          Text(
            'Adskyi Module is not found',
            style: Theme.of(context)
                .primaryTextTheme
                .subhead
                .copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
