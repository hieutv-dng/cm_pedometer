// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

import 'cm_pedometer_data.dart';

const int _stopped = 0, _walking = 1;

/// A Flutter plugin for accessing pedometer functionality on iOS and Android devices.
class CMPedometer {
  /// The method channel for communication with the native platform.
  static const MethodChannel _channel = MethodChannel('cm_pedometer');

  /// The event channel for step detection events.
  static const EventChannel _stepDetectionChannel =
      EventChannel('step_detection');

  /// The event channel for step count events.
  static const EventChannel _stepCountChannel = EventChannel('step_count');

  /// The stream controller for Android pedestrian status events.
  static final StreamController<CMPedestrianStatus>
      _androidPedestrianController = StreamController.broadcast();

  /// Checks if step counting is available.
  ///
  /// Android only. Returns false on iOS or if an error occurs.
  Future<bool> isStepCountingAvailable() async {
    if (Platform.isAndroid) return false;

    try {
      final status =
          await _channel.invokeMethod<bool>('isStepCountingAvailable');
      return status ?? false;
    } catch (e) {
      debugPrint('$runtimeType - Exception in isStepCountingAvailable(): $e');
      return false;
    }
  }

  /// Checks if distance tracking is available.
  ///
  /// iOS only. Returns false on Android or if an error occurs.
  Future<bool> isDistanceAvailable() async {
    if (Platform.isAndroid) return false;

    try {
      final status = await _channel.invokeMethod<bool>('isDistanceAvailable');
      return status ?? false;
    } catch (e) {
      debugPrint('$runtimeType - Exception in isDistanceAvailable(): $e');
      return false;
    }
  }

  /// Checks if floor counting is available.
  ///
  /// iOS only. Returns false on Android or if an error occurs.
  Future<bool> isFloorCountingAvailable() async {
    if (Platform.isAndroid) return false;

    try {
      final status =
          await _channel.invokeMethod<bool>('isFloorCountingAvailable');
      return status ?? false;
    } catch (e) {
      debugPrint('$runtimeType - Exception in isFloorCountingAvailable(): $e');
      return false;
    }
  }

  /// Checks if pace tracking is available.
  ///
  /// iOS only. Returns false on Android or if an error occurs.
  Future<bool> isPaceAvailable() async {
    if (Platform.isAndroid) return false;

    try {
      final status = await _channel.invokeMethod<bool>('isPaceAvailable');
      return status ?? false;
    } catch (e) {
      debugPrint('$runtimeType - Exception in isPaceAvailable(): $e');
      return false;
    }
  }

  /// Checks if cadence tracking is available.
  ///
  /// iOS only. Returns false on Android or if an error occurs.
  Future<bool> isCadenceAvailable() async {
    if (Platform.isAndroid) return false;

    try {
      final status = await _channel.invokeMethod<bool>('isCadenceAvailable');
      return status ?? false;
    } catch (e) {
      debugPrint('$runtimeType - Exception in isCadenceAvailable(): $e');
      return false;
    }
  }

  /// Checks if pedometer event tracking is available.
  ///
  /// iOS only. Returns false on Android or if an error occurs.
  Future<bool> isPedometerEventTrackingAvailable() async {
    if (Platform.isAndroid) return false;

    try {
      final status = await _channel
          .invokeMethod<bool>('isPedometerEventTrackingAvailable');
      return status ?? false;
    } catch (e) {
      debugPrint(
          '$runtimeType - Exception in isPedometerEventTrackingAvailable(): $e');
      return false;
    }
  }

  /// Returns one step at a time.
  /// Events come every time a step is detected.
  static Stream<CMPedestrianStatus> get pedestrianStatusStream {
    Stream<CMPedestrianStatus> stream = _stepDetectionChannel
        .receiveBroadcastStream()
        .map((event) => CMPedestrianStatus._(event));
    if (Platform.isAndroid) return _androidStream(stream);
    return stream;
  }

  /// Transformed stream for the Android platform
  static Stream<CMPedestrianStatus> _androidStream(
      Stream<CMPedestrianStatus> stream) {
    /// Init a timer and a status
    Timer? t;
    int? pedestrianStatus;

    /// Listen for events on the original stream
    /// Transform these events by using the timer
    stream.listen((dynamic e) {
      /// If an event is received it means the status is 'walking'
      /// If the timer has been started, it should be cancelled
      /// to prevent sending out additional 'walking' events
      if (t != null) {
        t!.cancel();

        /// If a previous status was either not set yet, or was 'stopped'
        /// then a 'walking' event should be emitted.
        if (pedestrianStatus == null || pedestrianStatus == _stopped) {
          _androidPedestrianController.add(CMPedestrianStatus._(_walking));
          pedestrianStatus = _walking;
        }
      }

      /// After receiving an event, start a timer for 2 seconds, after
      /// which a 'stopped' event is emitted. If it manages to go through,
      /// it is because no events were received for the 2 second duration
      t = Timer(const Duration(seconds: 2), () {
        _androidPedestrianController.add(CMPedestrianStatus._(_stopped));
        pedestrianStatus = _stopped;
      });
    });

    return _androidPedestrianController.stream;
  }

  /// Returns the steps taken since last system boot.
  /// Events may come with a delay.
  static Stream<CMPedometerData> get stepCountStream => _stepCountChannel
      .receiveBroadcastStream()
      .map((event) => CMPedometerData.fromJson(event));
}

/// A DTO for steps taken containing a detected step and its corresponding
/// status, i.e. walking, stopped or unknown.
class CMPedestrianStatus {
  /// The walking status.
  static const _WALKING = 'walking';

  /// The stopped status.
  static const _STOPPED = 'stopped';

  /// The unknown status.
  static const _UNKNOWN = 'unknown';

  /// The map of statuses.
  static const Map<int, String> _STATUSES = {
    _stopped: _STOPPED,
    _walking: _WALKING
  };

  /// The timestamp of the status.
  late DateTime _timeStamp;

  /// The status.
  String _status = _UNKNOWN;

  /// Constructs a new CMPedestrianStatus instance.
  CMPedestrianStatus._(dynamic t) {
    int type = t as int;
    _status = _STATUSES[type]!;
    _timeStamp = DateTime.now();
  }

  /// Returns the status.
  String get status => _status;

  /// Returns the timestamp.
  DateTime get timeStamp => _timeStamp;

  /// Returns a string representation of the status.
  @override
  String toString() => 'Status: $_status at ${_timeStamp.toIso8601String()}';
}
