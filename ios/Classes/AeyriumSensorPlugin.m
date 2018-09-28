#import "AeyriumSensorPlugin.h"
#import <CoreMotion/CoreMotion.h>

@implementation AeyriumSensorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FLTSensorStreamHandler* sensorStreamHandler =
      [[FLTSensorStreamHandler alloc] init];
  FlutterEventChannel* sensorChannel =
      [FlutterEventChannel eventChannelWithName:@"plugins.aeyrium.com/sensor"
                                binaryMessenger:[registrar messenger]];
  [sensorChannel setStreamHandler:sensorStreamHandler];
}

@end

CMMotionManager* _motionManager;

void _initMotionManager() {
  if (!_motionManager) {
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.deviceMotionUpdateInterval = 0.03;
  }
}

static void sendData(Float64 pitch, Float64 roll, FlutterEventSink sink) {
  NSMutableData* event = [NSMutableData dataWithCapacity:2 * sizeof(Float64)];
  [event appendBytes:&pitch length:sizeof(Float64)];
  [event appendBytes:&roll length:sizeof(Float64)];
  sink([FlutterStandardTypedData typedDataWithFloat64:event]);
}


@implementation FLTSensorStreamHandler

double degrees(double radians) {
  return (180/M_PI) * radians;
}

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  _initMotionManager();
   [_motionManager
   startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical toQueue:[[NSOperationQueue alloc] init]
   withHandler:^(CMDeviceMotion* data, NSError* error) {
     CMAttitude *attitude = data.attitude;
     CMQuaternion quat = attitude.quaternion;
     double pitch = degrees(atan2(2*(quat.x*quat.w + quat.y*quat.z), 1 - 2*quat.x*quat.x - 2*quat.z*quat.z)) - 90.0;
     double roll = -degrees(atan2(2*(quat.y*quat.w - quat.x*quat.z), 1 - 2*quat.y*quat.y - 2*quat.z*quat.z));
     sendData(pitch, roll , eventSink);
   }];
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  [_motionManager stopDeviceMotionUpdates];
  return nil;
}

@end
