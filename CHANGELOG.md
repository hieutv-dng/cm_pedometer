# Changelog

## 1.2.1

* Add `startDate` and `endDate` fields to `CMPedometerData`.
* Add `averageActivePace` field to `CMPedometerData`.
* Add `queryPedometerData()` method to query historical pedometer data for a specific time range.
* **BREAKING CHANGE**: Remove `stepCountStream()` method. Use `stepCounterFirstStream()`, `stepCounterSecondStream()`, or `stepCounterThirdStream()` instead. These methods support a `from` parameter to start the stream from a specific date.

## 1.1.0

* Add `CMPedometerData` class.
* Add `distance`, `floorsAscended`, `floorsDescended`, `currentPace`, `currentCadence` to `CMPedometerData`.
* Add platform availability check for pedometer features.

## 1.0.0

* Initial release.