import 'dart:async';
import 'package:flutter/services.dart';

const EventChannel _sensorEventChannel =
    EventChannel('plugins.aeyrium.com/sensor');

class SensorEvent {
  /// Pitch event from the device
  /// A pitch is a rotation around a lateral (X) axis that passes through the device from side to side
  final double pitch;

  ///Roll event from the device
  ///A roll is a rotation around a longitudinal (Y) axis that passes through the device from its top to bottom
  final double roll;

  SensorEvent(this.pitch, this.roll);

  @override
  String toString() => '[Event: (pitch: $pitch, roll: $roll)]';
}

class AeyriumSensor {
  static AeyriumSensor _instance;
  Stream<SensorEvent> _sensorEvents;

  factory AeyriumSensor() {
    if (_instance == null) {
      _instance = AeyriumSensor._internal();
    }
    return _instance;
  }

  AeyriumSensor._internal();

  /// A broadcast stream of events from the device rotation sensor.
  Stream<SensorEvent> get sensorEvents {
    if (_sensorEvents == null) {
      _sensorEvents = _sensorEventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => _listToSensorEvent(event.cast<double>()));
    }
    return _sensorEvents;
  }

  SensorEvent _listToSensorEvent(List<double> list) {
    return SensorEvent(list[0], list[1]);
  }
  
}
