
# Flutter Aeyrium Sensor Plugin 

[Aeyrium Sensor Plugin](https://pub.dartlang.org/packages/aeyrium_sensor)

A Flutter sensor plugin which provide easy access to the Pitch and Roll on Android and iOS devices. It was made using TYPE_ROTATION_VECTOR sensor on Android and DeviceMotion on iOS.

## Import

To use this plugin, add `aeyrium_sensor` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). For example:

```yaml
dependencies:
  aeyrium_sensor: ^1.0.2
```

## Usage

``` dart
import 'package:aeyrium_sensor/aeyrium_sensor.dart';

AeyriumSensor().sensorEvents.listen((SensorEvent event) {
      //do something with the event
      print("Pitch ${event.pitch} and Roll ${event.roll}")
      
    });

```

## Real Demo

We developed this plugin to use it on our Attitude indicator screen.
[![Aeyrium Sensor](http://img.youtube.com/vi/IIoa9uNka_0/0.jpg)](http://www.youtube.com/watch?v=IIoa9uNka_0 "Attitude indicator")


## Issues

Please file any issues, bugs or feature request as an issue on our [GitHub](https://github.com/aeyrium/aeyrium-sensor/issues) page.

## Author

This Aeyrium Sensor plugin for Flutter is developed by [Aeyrium Inc](https://aeyrium.com)