#import "AeyriumSensorPlugin.h"
#import <CoreMotion/CoreMotion.h>
#import <GLKit/GLKit.h>

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
   
     CMDeviceMotion *deviceMotion = data;
     
     // Correct for the rotation matrix not including the screen orientation:
     UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
     float deviceOrientationRadians = 0.0f;
     if (orientation == UIDeviceOrientationLandscapeLeft) {
       deviceOrientationRadians = M_PI_2;
     }
     if (orientation == UIDeviceOrientationLandscapeRight) {
       deviceOrientationRadians = -M_PI_2;
     }
     if (orientation == UIDeviceOrientationPortraitUpsideDown) {
       deviceOrientationRadians = M_PI;
     }
     GLKMatrix4 baseRotation = GLKMatrix4MakeRotation(deviceOrientationRadians, 0.0f, 1.0f, 1.0f);
     
     GLKMatrix4 deviceMotionAttitudeMatrix;
     CMRotationMatrix a = deviceMotion.attitude.rotationMatrix;
     deviceMotionAttitudeMatrix
     = GLKMatrix4Make(a.m11, a.m21, a.m31, 0.0f,
                      a.m12, a.m22, a.m32, 0.0f,
                      a.m13, a.m23, a.m33, 0.0f,
                      0.0f, 0.0f, 0.0f, 1.0f);
     
     deviceMotionAttitudeMatrix = GLKMatrix4Multiply(baseRotation, deviceMotionAttitudeMatrix);
     double pitch = (asin(-deviceMotionAttitudeMatrix.m22));
     double roll = -(atan2(2*(quat.y*quat.w - quat.x*quat.z), 1 - 2*quat.y*quat.y - 2*quat.z*quat.z)) ;
     sendData(pitch, roll , eventSink);
   }];
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  [_motionManager stopDeviceMotionUpdates];
  return nil;
}

@end
