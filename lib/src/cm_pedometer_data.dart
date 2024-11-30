/// Information about the distance traveled by a user on foot.
class CMPedometerData {
  /// The start time for the pedometer data. (if available)
  final DateTime? startDate;

  /// The end time for the pedometer data. (if available)
  final DateTime? endDate;

  /// The number of steps taken by the user.
  final int numberOfSteps;

  /// The estimated distance (in meters) traveled by the user. (if available)
  final double? distance;

  /// The average pace of the user, measured in seconds per meter. (if available)
  final double? averageActivePace;

  /// The current pace of the user, measured in seconds per meter. (if available)
  final double? currentPace;

  /// The rate at which steps are taken, measured in steps per second. (if available)
  final double? currentCadence;

  /// The approximate number of floors ascended by walking. (if available)
  final int? floorsAscended;

  /// The approximate number of floors descended by walking. (if available)
  final int? floorsDescended;

  /// Timestamp when this measurement was created.
  final DateTime timeStamp;

  /// Creates a new pedometer data instance with the current timestamp.
  CMPedometerData({
    required this.startDate,
    required this.endDate,
    required this.numberOfSteps,
    this.distance,
    this.averageActivePace,
    this.currentPace,
    this.currentCadence,
    this.floorsAscended,
    this.floorsDescended,
  }) : timeStamp = DateTime.now(); // Setting timestamp as now upon creation

  /// Creates a pedometer data instance from a JSON-like map
  ///
  /// Expected format:
  /// ```dart
  /// {
  ///   'startDate': int,
  ///   'endDate': int,
  ///   'numberOfSteps': int,
  ///   'distance': double?,
  ///   'averageActivePace': double?,
  ///   'currentPace': double?,
  ///   'currentCadence': double?,
  ///   'floorsAscended': int?,
  ///   'floorsDescended': int?,
  /// }
  /// ```
  CMPedometerData.fromJson(dynamic e)
      : startDate = e['startDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(e['startDate'] as int)
            : null,
        endDate = e['endDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(e['endDate'] as int)
            : null,
        numberOfSteps = e['numberOfSteps'] as int,
        distance = e['distance'] as double?,
        averageActivePace = e['averageActivePace'] as double?,
        currentPace = e['currentPace'] as double?,
        currentCadence = e['currentCadence'] as double?,
        floorsAscended = e['floorsAscended'] as int?,
        floorsDescended = e['floorsDescended'] as int?,
        timeStamp = DateTime.now();

  @override
  String toString() {
    return 'Steps taken: $numberOfSteps at ${timeStamp.toIso8601String()}'
        ' | Start date: $startDate'
        ' | End date: $endDate'
        ' | Distance: $distance meters'
        ' | Average active pace: $averageActivePace seconds/meter'
        ' | Current pace: $currentPace m/s'
        ' | Current cadence: $currentCadence steps/min'
        ' | Floors ascended: $floorsAscended'
        ' | Floors descended: $floorsDescended';
  }
}
