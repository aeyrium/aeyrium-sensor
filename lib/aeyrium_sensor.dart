import 'dart:async';

import 'package:flutter/services.dart';

const EventChannel _sensorEventChannel = EventChannel('plugins.aeyrium.com/sensor');

class SensorEvent {

	/// Azimuth, angle of rotation about the -z axis in radians.
	///
	/// This value represents the angle between the device's y axis and the magnetic
	/// north pole. When facing north, this angle is 0, when facing south, this
	/// angle is π. Likewise, when facing east, this angle is π/2, and when facing
	/// west, this angle is -π/2.
	///
	/// The range of values is -π to π.
	final double azimuth;

	/// Pitch, angle of rotation about the x axis in radians.
	///
	/// A pitch is a rotation around a lateral (X) axis that passes through the device
	/// from side to side.
	///
	/// This value represents the angle between a plane parallel to the device's screen
	/// and a plane parallel to the ground. Assuming that the bottom edge of the device
	/// faces the user and that the screen is face-up, tilting the top edge of the
	/// device toward the ground creates a positive pitch angle.
	///
	/// The range of values is -π to π.
	final double pitch;

	///Roll value from the device in radians
	/// Roll, angle of rotation about the y axis in radians.
	///
	/// A roll is a rotation around a longitudinal (Y) axis that passes through the device
	/// from top to bottom.
	///
	/// This value represents the angle between a plane perpendicular to the device's
	/// screen and a plane perpendicular to the ground. Assuming that the bottom edge of
	/// the device faces the user and that the screen is face-up, tilting the left edge
	/// of the device toward the ground creates a positive roll angle.
	///
	/// The range of values is -π/2 to π/2.
	final double roll;

	SensorEvent(this.azimuth, this.pitch, this.roll);

	@override
	String toString() => '[SensorEvent: (azimuth: $azimuth, pitch: $pitch, roll: $roll)]';
}

class AeyriumSensor {
	static Stream<SensorEvent> _sensorEvents;

	AeyriumSensor._();

	/// A broadcast stream of events from the device rotation sensor.
	static Stream<SensorEvent> get sensorEvents {
		if (_sensorEvents == null) {
			_sensorEvents = _sensorEventChannel
				.receiveBroadcastStream()
				.map((dynamic event) => _listToSensorEvent(event.cast<double>()));
		}
		return _sensorEvents;
	}

	static SensorEvent _listToSensorEvent(List<double> list) {
		return SensorEvent(list[0], list[1], list[2]);
	}
}
