import 'dart:async';

import 'package:flutter/material.dart';
import 'package:aeyrium_sensor/aeyrium_sensor.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _data = "";

  StreamSubscription<dynamic> _streamSubscriptions;

  @override
  void initState() {
    _streamSubscriptions = AeyriumSensor.sensorEvents.listen((event) {
      setState(() {
        _data = "Pitch ${event.pitch} , Roll ${event.roll}";
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    if (_streamSubscriptions != null) {
      _streamSubscriptions.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: new Center(
            child: new Text('Device : $_data'),
          ),
        ),
      ),
    );
  }
}
