# CMPedometer

A Flutter plugin for accessing pedometer data and pedestrian activity on iOS and Android devices. Get step counts, check walking/running status, and verify sensor availability.

This plugin uses CoreMotion on iOS and the Activity Recognition API on Android to provide accurate step counting and activity detection. It supports real-time updates and can track various motion metrics including steps, distance, floors climbed, pace and cadence (iOS only).

<p>
    <img src="https://github.com/hieutv-dng/cm_pedometer/blob/master/screenshots/pedometer_stopped.png?raw=true" width="300"/>
    <img src="https://github.com/hieutv-dng/cm_pedometer/blob/master/screenshots/pedometer_walking.png?raw=true" width="300"/>
</p>

## Features

- 🚶‍♂️ Real-time step counting
- 🏃‍♀️ Pedestrian activity status (walking/running/stationary)
- ⚡ Check sensor availability
- 📱 Support for both iOS and Android

## Feature Support

| Feature             | Android | iOS |
|---------------------|---------|-----|
| Sensor Availability | ❌      | ✅  |
| Pedestrian Status   | ✅      | ✅  |
| Step Count          | ✅      | ✅  |
| Distance            | ❌      | ✅  |
| Floors              | ❌      | ✅  |
| Current Pace        | ❌      | ✅  |
| Current Cadence     | ❌      | ✅  |

## Getting Started

### Prerequisites

#### Android
Add the following permissions to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
<uses-permission android:name="android.permission.PHYSICAL_ACTIVITY" />
```

#### iOS
Add the following keys to your `Info.plist`:

```xml
<key>NSMotionUsageDescription</key>
<string>This app needs to access motion data for step counting</string>
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>
```

## Usage
See the [example app](https://github.com/hieutv-dng/cm_pedometer/blob/master/example/lib/main.dart) for a fully-fledged example.

Below are shown basic usage examples. Remember to set the required permissions as described above. This may require you to manually allow permissions in the phone's Settings.

### Permissions

You can manually request permissions using [package:permission_handler](https://pub.dev/packages/permission_handler):

```dart
// Request required permissions
bool granted = await Permission.activityRecognition.request() == PermissionStatus.granted;
```

### Verify Sensor Availability

```dart
// Check if step counting is available
bool isStepCountingAvailable = await CMPedometer.isStepCountingAvailable();

// Check if distance tracking is available
bool isDistanceAvailable = await CMPedometer.isDistanceAvailable();

// Check if floor counting is available
bool isFloorCountingAvailable = await CMPedometer.isFloorCountingAvailable();

// Check if pace tracking is available
bool isPaceAvailable = await CMPedometer.isPaceAvailable();

// Check if cadence tracking is available
bool isCadenceAvailable = await CMPedometer.isCadenceAvailable();

// Check if pedometer event tracking is available
bool isPedometerEventTrackingAvailable =
    await CMPedometer.isPedometerEventTrackingAvailable();
```

### Check Pedestrian Status

```dart
// Get current activity status
CMPedometer.pedestrianStatusStream.listen((status) {
  switch (status) {
    case 'walking':
      print('User is walking');
      break;
    case 'stopped':
      print('User is stationary');
      break;
    default:
      print('Unknown activity status');
      break;
  }
});
```

### Basic Pedometer Data

```dart
// Listen to step count updates
CMPedometer.stepCountStream.listen((data) {
  print('Steps taken: ${data.numberOfSteps}');
  print('Distance: ${data.distance}');
  print('Floors ascended: ${data.floorsAscended}');
  print('Floors descended: ${data.floorsDescended}');
  print('Current pace: ${data.currentPace}');
  print('Current cadence: ${data.currentCadence}');
});
```

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) to get started.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.