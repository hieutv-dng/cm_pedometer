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
| Average Active Pace | ❌      | ✅  |
| Current Pace        | ❌      | ✅  |
| Current Cadence     | ❌      | ✅  |
| Floors              | ❌      | ✅  |

## Getting Started

### Prerequisites

#### Android
Add the following permissions to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

#### iOS
1. Add the following keys to your `Info.plist`:

```xml
<key>NSMotionUsageDescription</key>
<string>This app needs to access motion data for step counting</string>
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>
```

2. In your `Podfile`, located under the `ios` folder, add this:

```rb
post_install do |installer|
    installer.pods_project.targets.each do |target|
        flutter_additional_ios_build_settings(target)

        ## ADD THIS SECTION
        target.build_configurations.each do |config|
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
            '$(inherited)',
            ## dart: PermissionGroup.sensors
            'PERMISSION_SENSORS=1',
            ]
        end
        ## END OF WHAT YOU NEED TO ADD
    end
end
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

### Listen to Pedometer Data Updates

You can use `stepCounterFirstStream`, `stepCounterSecondStream`, or `stepCounterThirdStream` to listen to step count updates starting from a specific time.

If no start time is provided, it will default to the time of the last system boot.

Since you cannot listen to the same stream twice, you need to call `stepCounterFirstStream`, `stepCounterSecondStream`, or `stepCounterThirdStream` separately if you want to listen to multiple streams simultaneously.

```dart
// Listen to step count updates since the last system boot
CMPedometer.stepCounterFirstStream().listen((data) {
  print('Start date: ${data.startDate}');
  print('End date: ${data.endDate}');
  print('Steps taken: ${data.numberOfSteps}');
  print('Distance: ${data.distance}');
  print('Average active pace: ${data.averageActivePace}');
  print('Current pace: ${data.currentPace}');
  print('Current cadence: ${data.currentCadence}');
  print('Floors ascended: ${data.floorsAscended}');
  print('Floors descended: ${data.floorsDescended}');
});

// Example with a specific date range
CMPedometer.stepCounterFirstStream(from: DateTime.now()).listen((data) {
  print('Steps taken from $fromDate: ${data.numberOfSteps}');
});
```

### Historical Pedometer Data

```dart
// Query historical pedometer data for a specific time range
DateTime fromDate = DateTime.now().subtract(Duration(days: 5));
DateTime toDate = DateTime.now();
final data = await CMPedometer.queryPedometerData(from: fromDate, to: toDate);
print('Steps taken: ${data.numberOfSteps}');
print('Distance: ${data.distance}');
// ... other data fields available

// Note: iOS stores up to 7 days of data, Android stores up to 10 days
```

## ROADMAP

We are actively working to bring feature parity between iOS and Android platforms. Here are the planned improvements for Android:

### Upcoming Android Features

- [ ] Sensor Availability Check
  - Implementation of proper sensor availability verification on Android

- [ ] Enhanced Motion Metrics
  - Distance tracking
  - Floor counting
  - Pace measurement
  - Cadence tracking

- [ ] Historical Data Access
  - Improved historical data retention and access
  - Better integration with Google Fit API

### Timeline

These features are being developed with priority given to the most requested capabilities. We welcome community contributions to help accelerate the development of these features.

## Thanks and credits

### This package was originally forked from:

- [Pedometer](https://pub.dev/packages/pedometer) by [cachet.dk](https://pub.dev/publishers/cachet.dk/packages)

***_And inspired by:_**
- [pedometer_2](https://pub.dev/packages/pedometer_2)

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) to get started.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.