# Pedometer Plus

A Flutter plugin for accessing pedometer data and pedestrian activity on iOS and Android devices. Get step counts, check walking/running status, and verify sensor availability.

<p>
    <img src="https://github.com/hieutv-dng/cm_pedometer/blob/master/screenshots/pedometer_stopped.png?raw=true"/>
    <img src="https://github.com/hieutv-dng/cm_pedometer/blob/master/screenshots/pedometer_walking.png?raw=true"/>
</p>

## Features

- 🚶‍♂️ Real-time step counting
- 🏃‍♀️ Pedestrian activity status (walking/running/stationary)
- ⚡ Check sensor availability
- 📱 Support for both iOS and Android

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
```

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  cm_pedometer: ^1.0.0
```

## Usage

### Basic Step Counter

```dart
import 'package:cm_pedometer/cm_pedometer.dart';

// Listen to step count updates
CMPedometer.stepCountStream.listen((steps) {
  print('Steps taken: $steps');
});
```

### Check Pedestrian Status

```dart
// Get current activity status
CMPedometer.pedestrianStatusStream.listen((status) {
  switch (status) {
    case PedestrianStatus.walking:
      print('User is walking');
      break;
    case PedestrianStatus.running:
      print('User is running');
      break;
    case PedestrianStatus.stopped:
      print('User is stationary');
      break;
  }
});
```

### Verify Sensor Availability

```dart
// Check if step counting is available
bool isStepCountAvailable = await CMPedometer.isStepCountAvailable();

// Check if pedestrian status detection is available
bool isPedestrianStatusAvailable = await CMPedometer.isPedestrianStatusAvailable();
```

### Complete Example

```dart
import 'package:cm_pedometer/cm_pedometer.dart';

class PedometerExample {  
  void initPedometer() async {
    
    // Check availability
    if (await CMPedometer.isPedestrianStatusAvailable()) {
      // Listen to activity updates
      _pedometer.pedestrianStatusStream.listen(
        (status) => print('Status: $status'),
        onError: (error) => print('Status error: $error'),
      );
    }

    if (await CMPedometer.isStepCountAvailable()) {
      // Listen to step updates
      _pedometer.stepCountStream.listen(
        (steps) => print('Steps: $steps'),
        onError: (error) => print('Step count error: $error'),
      );
    }
  }
}
```

## Permissions

You can manually request permissions:

```dart
// Request required permissions
bool granted = await CMPedometer.requestPermissions();
```

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

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) to get started.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.