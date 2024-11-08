// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io' show Platform;

import 'cm_pedometer_data.dart';

const int _stopped = 0, _walking = 1;

class CMPedometer {
  static const EventChannel _stepDetectionChannel =
      EventChannel('step_detection');
  static const EventChannel _stepCountChannel = EventChannel('step_count');

  static final StreamController<CMPedestrianStatus>
      _androidPedestrianController = StreamController.broadcast();

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
  static const _WALKING = 'walking';
  static const _STOPPED = 'stopped';
  static const _UNKNOWN = 'unknown';

  static const Map<int, String> _STATUSES = {
    _stopped: _STOPPED,
    _walking: _WALKING
  };

  late DateTime _timeStamp;
  String _status = _UNKNOWN;

  CMPedestrianStatus._(dynamic t) {
    int type = t as int;
    _status = _STATUSES[type]!;
    _timeStamp = DateTime.now();
  }

  String get status => _status;

  DateTime get timeStamp => _timeStamp;

  @override
  String toString() => 'Status: $_status at ${_timeStamp.toIso8601String()}';
}
