/// A data class that represents pedometer measurements at a specific point in time.
/// Contains information about steps, distance, floors, pace, and cadence.
class CMPedometerData {
  /// The total number of steps counted
  final int numberOfSteps;

  /// The distance traveled in meters (if available)
  final double? distance;

  /// The number of floors climbed up (if available)
  final int? floorsAscended;

  /// The number of floors climbed down (if available)
  final int? floorsDescended;

  /// Current walking/running pace in meters per second (if available)
  final double? currentPace;

  /// Current stepping rate in steps per minute (if available)
  final double? currentCadence;

  /// Timestamp when this measurement was created
  final DateTime timeStamp;

  /// Creates a new pedometer data instance with the current timestamp
  CMPedometerData({
    required this.numberOfSteps,
    this.distance,
    this.floorsAscended,
    this.floorsDescended,
    this.currentPace,
    this.currentCadence,
  }) : timeStamp = DateTime.now(); // Setting timestamp as now upon creation

  /// Creates a pedometer data instance from a JSON-like map
  ///
  /// Expected format:
  /// ```dart
  /// {
  ///   'numberOfSteps': int,
  ///   'distance': double?,
  ///   'floorsAscended': int?,
  ///   'floorsDescended': int?,
  ///   'currentPace': double?,
  ///   'currentCadence': double?
  /// }
  /// ```
  CMPedometerData.fromJson(dynamic e)
      : numberOfSteps = e['numberOfSteps'] as int,
        distance = e['distance'] as double?,
        floorsAscended = e['floorsAscended'] as int?,
        floorsDescended = e['floorsDescended'] as int?,
        currentPace = e['currentPace'] as double?,
        currentCadence = e['currentCadence'] as double?,
        timeStamp = DateTime.now();

  @override
  String toString() {
    return 'Steps taken: $numberOfSteps at ${timeStamp.toIso8601String()}'
        ' | Distance: $distance meters'
        ' | Floors ascended: $floorsAscended'
        ' | Floors descended: $floorsDescended'
        ' | Current pace: $currentPace m/s'
        ' | Current cadence: $currentCadence steps/min';
  }
}
