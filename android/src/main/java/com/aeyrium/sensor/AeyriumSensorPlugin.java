package com.aeyrium.sensor;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.view.Surface;
import android.view.WindowManager;

import java.util.Arrays;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;


/**
 * AeyriumSensorPlugin
 */
public class AeyriumSensorPlugin implements EventChannel.StreamHandler, SensorEventListener {

    private static final String SENSOR_CHANNEL_NAME = "plugins.aeyrium.com/sensor";
    private static final int SENSOR_DELAY_uS = SensorManager.SENSOR_DELAY_UI;

    private final float[] mVec4Rotation = new float[4];
    private final float[] mMat4Rotation = new float[16];
    private final float[] mMat4RotDisplay = new float[16];
    private final float[] mMat4RotRemappedXZ = new float[16];
    private final double[] mVec3Orientation = new double[3];

    private WindowManager mWindowManager;
    private SensorManager mSensorManager;
    private Sensor mSensor;
    private int mLastAccuracy;
    private EventChannel.EventSink mEventSink;


    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final EventChannel sensorChannel = new EventChannel(registrar.messenger(), SENSOR_CHANNEL_NAME);
        sensorChannel.setStreamHandler(new AeyriumSensorPlugin(registrar.context(), registrar));

    }

    private AeyriumSensorPlugin(Context context, Registrar registrar) {
        mWindowManager = registrar.activity().getWindow().getWindowManager();
        mSensorManager = (SensorManager) context.getSystemService(Context.SENSOR_SERVICE);
        if (mSensorManager == null) {
            throw new IllegalStateException("Sensor Manager not found");
        }
        mSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        Arrays.fill(mVec4Rotation, 0);
        mEventSink = events;
        mSensorManager.registerListener(this, mSensor, SENSOR_DELAY_uS);
    }

    @Override
    public void onCancel(Object arguments) {
        mSensorManager.unregisterListener(this, mSensor);
        mEventSink = null;
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {
        if (mLastAccuracy != accuracy) {
            mLastAccuracy = accuracy;
        }
    }


    @Override
    public void onSensorChanged(SensorEvent event) {
        if (mLastAccuracy == SensorManager.SENSOR_STATUS_UNRELIABLE || mEventSink == null) {
            return;
        }

        // Low-pass filter the incoming event data to smooth it out.
        lowPassFilter(event.values, mVec4Rotation, 0.3f);

        // Get the rotation matrix from the smoothed event rotation vector.
        SensorManager.getRotationMatrixFromVector(mMat4Rotation, mVec4Rotation);

        // Adjust the matrix to take into account the device orientation.
        remapRotationMatrixByDisplay(mWindowManager, mMat4RotDisplay, mMat4Rotation);

        // Remap to adjust for display orientation.
        SensorManager.remapCoordinateSystem(mMat4RotDisplay, SensorManager.AXIS_X,
                SensorManager.AXIS_Z, mMat4RotRemappedXZ);

        // Capture the orientation vector from the rotation matrix.
        //SensorManager.getOrientation(mMat4RotRemappedXZ, mVec3Orientation);
        mVec3Orientation[0] = Math.atan2(mMat4RotRemappedXZ[1], mMat4RotRemappedXZ[5]);
        mVec3Orientation[1] = Math.asin(-mMat4RotRemappedXZ[9]);
        mVec3Orientation[2] = Math.atan2(-mMat4RotRemappedXZ[8], mMat4RotRemappedXZ[10]);

        mEventSink.success(mVec3Orientation);
    }

    private static void lowPassFilter(float[] input, float[] prev, float alpha) {
        if (input == null || prev == null) {
            throw new NullPointerException("input and prev float arrays must be non-NULL");
        }
        int length = Math.min(input.length, prev.length);
        for (int i = 0; i < length; i++) {
            prev[i] = prev[i] + alpha * (input[i] - prev[i]);
        }
    }

    /**
     * https://android-developers.blogspot.co.uk/2010/09/one-screen-turn-deserves-another.html
     */
    @SuppressWarnings("SuspiciousNameCombination")
    private static void remapRotationMatrixByDisplay(WindowManager windowManager, float[] outMatrix, float[] inMatrix) {
        int x = SensorManager.AXIS_X, y = SensorManager.AXIS_Y;
        switch (windowManager.getDefaultDisplay().getRotation()) {
            case Surface.ROTATION_0:
                x = SensorManager.AXIS_X;
                y = SensorManager.AXIS_Y;
                break;
            case Surface.ROTATION_90:
                x = SensorManager.AXIS_Y;
                y = SensorManager.AXIS_MINUS_X;
                break;
            case Surface.ROTATION_180:
                x = SensorManager.AXIS_MINUS_X;
                y = SensorManager.AXIS_MINUS_Y;
                break;
            case Surface.ROTATION_270:
                x = SensorManager.AXIS_MINUS_Y;
                y = SensorManager.AXIS_X;
                break;
        }
        SensorManager.remapCoordinateSystem(inMatrix, x, y, outMatrix);
    }

    /*
    // Remap the axes as if the device screen was the instrument panel,
    // and adjust the rotation matrix for the device orientation.
    switch (mWindowManager.getDefaultDisplay().getRotation()) {
        case Surface.ROTATION_0:
        default:
            worldAxisForDeviceAxisX = SensorManager.AXIS_X;
            worldAxisForDeviceAxisY = SensorManager.AXIS_Z;
            break;
        case Surface.ROTATION_90:
            worldAxisForDeviceAxisX = SensorManager.AXIS_Z;
            worldAxisForDeviceAxisY = SensorManager.AXIS_MINUS_X;
            break;
        case Surface.ROTATION_180:
            worldAxisForDeviceAxisX = SensorManager.AXIS_MINUS_X;
            worldAxisForDeviceAxisY = SensorManager.AXIS_MINUS_Z;
            break;
        case Surface.ROTATION_270:
            worldAxisForDeviceAxisX = SensorManager.AXIS_MINUS_Z;
            worldAxisForDeviceAxisY = SensorManager.AXIS_X;
            break;
    }
    */
}
