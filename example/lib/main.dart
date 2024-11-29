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
  late Stream<CMPedometerData> _stepCountStream;
  late Stream<CMPedestrianStatus> _pedestrianStatusStream;
  String _status = '?';
  CMPedometerData? _pedometerData;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onStepCount(CMPedometerData data) {
    print(data);
    setState(() {
      _pedometerData = data;
    });
  }

  void onPedestrianStatusChanged(CMPedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _pedometerData = null;
    });
  }

  Future<bool> _checkActivityRecognitionPermission() async {
    bool granted = await Permission.activityRecognition.isGranted;

    if (!granted) {
      granted = await Permission.activityRecognition.request() ==
          PermissionStatus.granted;
    }

    return granted;
  }

  Future<void> initPlatformState() async {
    bool granted = await _checkActivityRecognitionPermission();
    if (!granted) {
      // tell user, the app will not work
    }

    _pedestrianStatusStream = CMPedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = CMPedometer.stepCountStream();
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  String get _steps => _pedometerData?.numberOfSteps.toString() ?? '?';
  double get _distance => _pedometerData?.distance ?? 0.0;
  int get _floorsAscended => _pedometerData?.floorsAscended ?? 0;
  int get _floorsDescended => _pedometerData?.floorsDescended ?? 0;
  double get _currentPace => _pedometerData?.currentPace ?? 0.0;
  double get _currentCadence => _pedometerData?.currentCadence ?? 0.0;

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
                Icon(
                  _status == 'walking'
                      ? Icons.directions_walk
                      : _status == 'stopped'
                          ? Icons.accessibility_new
                          : Icons.error,
                  size: 100,
                ),
                Center(
                  child: Text(
                    _status,
                    style: _status == 'walking' || _status == 'stopped'
                        ? const TextStyle(fontSize: 30)
                        : const TextStyle(fontSize: 20, color: Colors.red),
                  ),
                ),
                const Divider(
                  height: 30,
                  thickness: 0,
                  color: Colors.white,
                ),
                const Text(
                  'Steps Taken',
                  style: TextStyle(fontSize: 30),
                ),
                Text(
                  _steps,
                  style: const TextStyle(fontSize: 60),
                ),
                const Divider(height: 20),
                Text(
                  'Distance: ${(_distance / 1000).toStringAsFixed(2)} km',
                  style: const TextStyle(fontSize: 24),
                ),
                const Divider(height: 20),
                Text(
                  'Floors: ⬆️ $_floorsAscended ⬇️ $_floorsDescended',
                  style: const TextStyle(fontSize: 24),
                ),
                const Divider(height: 20),
                Text(
                  'Pace: ${_currentPace > 0 ? (1 / _currentPace).toStringAsFixed(2) : 0} m/s',
                  style: const TextStyle(fontSize: 24),
                ),
                const Divider(height: 20),
                Text(
                  'Cadence: ${(_currentCadence * 60).toStringAsFixed(1)} steps/min',
                  style: const TextStyle(fontSize: 24),
                ),
                const Divider(
                  height: 100,
                  thickness: 0,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
