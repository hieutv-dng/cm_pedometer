// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:cm_pedometer/cm_pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Streams for pedometer data since last system boot
  late Stream<CMPedometerData> _stepCountStream;

  // Stream for step count from a specific start time
  late Stream<CMPedometerData> _stepCountFromStream;

  // Stream for pedestrian status
  late Stream<CMPedestrianStatus> _pedestrianStatusStream;

  // Start time for step count from
  final DateTime _from = DateTime.now();

  // ValueNotifier for pedestrian status
  final ValueNotifier<String> _status = ValueNotifier('?');

  // ValueNotifier for step count since last system boot
  final ValueNotifier<CMPedometerData?> _pedometerData = ValueNotifier(null);

  // ValueNotifier for step count from a specific start time
  final ValueNotifier<CMPedometerData?> _pedometerDataFrom =
      ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Callback for step count updates
  void onStepCount(CMPedometerData data) {
    print(data);
    _pedometerData.value = data; // Update ValueNotifier instead of setState
  }

  // Callback for step count updates from a specific time
  void onStepCountFrom(CMPedometerData data) {
    print(data);
    _pedometerDataFrom.value = data; // Update ValueNotifier instead of setState
  }

  // Callback for pedestrian status changes
  void onPedestrianStatusChanged(CMPedestrianStatus event) {
    print(event);
    _status.value = event.status; // Update ValueNotifier instead of setState
  }

  // Error handler for pedestrian status stream
  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    _status.value = 'Pedestrian Status not available';
  }

  // Error handler for step count stream
  void onStepCountError(error) {
    print('onStepCountError: $error');
    _pedometerData.value = null;
  }

  // Error handler for step count from stream
  void onStepCountFromError(error) {
    print('onStepCountFromError: $error');
    _pedometerDataFrom.value = null;
  }

  // Check if activity recognition permission is granted
  Future<bool> _checkActivityRecognitionPermission() async {
    bool granted = await Permission.activityRecognition.isGranted;

    if (!granted) {
      granted = await Permission.activityRecognition.request() ==
          PermissionStatus.granted;
    }

    return granted;
  }

  // Initialize the platform state
  Future<void> initPlatformState() async {
    bool granted = await _checkActivityRecognitionPermission();
    if (!granted) {
      // TODO: Inform the user that the app will not function without permissions
    }

    _pedestrianStatusStream = CMPedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    // Stream for step count since last system boot
    _stepCountStream = CMPedometer.stepCounterFirstStream();
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    // Stream for step count from a specific start time
    _stepCountFromStream = CMPedometer.stepCounterSecondStream(from: _from);
    _stepCountFromStream.listen(onStepCountFrom).onError(onStepCountFromError);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pedometer Example'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Pedestrian Status',
                  style: TextStyle(fontSize: 30),
                ),
                // Listen to _status ValueNotifier
                ValueListenableBuilder<String>(
                  valueListenable: _status,
                  builder: (context, status, child) {
                    return Icon(
                      status == 'walking'
                          ? Icons.directions_walk
                          : status == 'stopped'
                              ? Icons.accessibility_new
                              : Icons.error,
                      size: 100,
                    );
                  },
                ),
                // Listen to _status ValueNotifier for text display
                ValueListenableBuilder<String>(
                  valueListenable: _status,
                  builder: (context, status, child) {
                    return Text(
                      status,
                      style: status == 'walking' || status == 'stopped'
                          ? const TextStyle(fontSize: 30)
                          : const TextStyle(fontSize: 20, color: Colors.red),
                    );
                  },
                ),
                const Divider(
                  height: 30,
                  thickness: 0,
                  color: Colors.white,
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                          text: 'Steps Taken', style: TextStyle(fontSize: 30)),
                      TextSpan(
                          text: '\n(Since the last system boot)',
                          style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                // Listen to _pedometerData ValueNotifier
                ValueListenableBuilder<CMPedometerData?>(
                  valueListenable: _pedometerData,
                  builder: (context, data, child) {
                    return _buildStepsTaken(context, data);
                  },
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                          text: 'Steps Taken', style: TextStyle(fontSize: 30)),
                      TextSpan(
                          text: '\n (from ${formatDate(_from)})',
                          style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                // Listen to _pedometerDataFrom ValueNotifier
                ValueListenableBuilder<CMPedometerData?>(
                  valueListenable: _pedometerDataFrom,
                  builder: (context, data, child) {
                    return _buildStepsTaken(context, data);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build the steps taken widget
  Widget _buildStepsTaken(BuildContext context, CMPedometerData? data) {
    final steps = data?.numberOfSteps.toString() ?? '?';
    final distance = data?.distance ?? 0.0;
    final floorsAscended = data?.floorsAscended ?? 0;
    final floorsDescended = data?.floorsDescended ?? 0;
    final currentPace = data?.currentPace ?? 0.0;
    final currentCadence = data?.currentCadence ?? 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          steps,
          style: const TextStyle(fontSize: 60),
        ),
        const Divider(height: 20),
        Text(
          'Distance: ${(distance / 1000).toStringAsFixed(2)} km',
          style: const TextStyle(fontSize: 24),
        ),
        const Divider(height: 20),
        Text(
          'Floors: ⬆️ $floorsAscended ⬇️ $floorsDescended',
          style: const TextStyle(fontSize: 24),
        ),
        const Divider(height: 20),
        Text(
          'Pace: ${currentPace > 0 ? (1 / currentPace).toStringAsFixed(2) : 0} m/s',
          style: const TextStyle(fontSize: 24),
        ),
        const Divider(height: 20),
        Text(
          'Cadence: ${(currentCadence * 60).toStringAsFixed(1)} steps/min',
          style: const TextStyle(fontSize: 24),
        ),
        const Divider(
          height: 100,
          thickness: 0,
          color: Colors.white,
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Dispose of ValueNotifiers to free resources
    _status.dispose();
    // Dispose of ValueNotifier for pedometer data since last system boot
    _pedometerData.dispose();
    // Dispose of ValueNotifier for pedometer data from a specific start time
    _pedometerDataFrom.dispose();
    super.dispose();
  }
}
