class CMPedometerData {
  final int numberOfSteps;
  final double? distance;
  final int? floorsAscended;
  final int? floorsDescended;
  final double? currentPace;
  final double? currentCadence;
  final DateTime timeStamp;

  CMPedometerData({
    required this.numberOfSteps,
    this.distance,
    this.floorsAscended,
    this.floorsDescended,
    this.currentPace,
    this.currentCadence,
  }) : timeStamp = DateTime.now(); // Setting timestamp as now upon creation

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
