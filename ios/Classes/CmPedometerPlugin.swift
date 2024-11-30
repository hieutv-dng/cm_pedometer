import Flutter
import UIKit

import CoreMotion

public class CMPedometerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "cm_pedometer", binaryMessenger: registrar.messenger())
        let instance = CMPedometerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        let stepDetectionHandler = StepDetector()
        let stepDetectionChannel = FlutterEventChannel.init(name: "step_detection", binaryMessenger: registrar.messenger())
        stepDetectionChannel.setStreamHandler(stepDetectionHandler)

        let stepCounterHandler = StepCounter()
        let stepCounterChannel = FlutterEventChannel.init(name: "step_counter", binaryMessenger: registrar.messenger())
        stepCounterChannel.setStreamHandler(stepCounterHandler)

        let stepCounterFromHandler = StepCounterFrom()
        let stepCounterFromChannel = FlutterEventChannel.init(name: "step_counter_from", binaryMessenger: registrar.messenger())
        stepCounterFromChannel.setStreamHandler(stepCounterFromHandler)
    }

    private let stepCount = StepCount()
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "showAlert":
            let alert = UIAlertController(title: "Hello", message: "I am a native alert dialog.", preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil);
        case "isStepCountingAvailable":
            result(CMPedometer.isStepCountingAvailable())
        case "isDistanceAvailable":
            result(CMPedometer.isDistanceAvailable())
        case "isFloorCountingAvailable":
            result(CMPedometer.isFloorCountingAvailable())
        case "isPaceAvailable":
            result(CMPedometer.isPaceAvailable())
        case "isCadenceAvailable":
            result(CMPedometer.isCadenceAvailable())
        case "isPedometerEventTrackingAvailable":
            result(CMPedometer.isPedometerEventTrackingAvailable())
        case "queryPedometerData":
            stepCount.queryPedometerData(call: call, channelResult: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

/// StepDetector, handles pedestrian status streaming
public class StepDetector: NSObject, FlutterStreamHandler {
    private let pedometer = CMPedometer()
    private var running = false
    private var eventSink: FlutterEventSink?

    private func handleEvent(status: Int) {
        // If no eventSink to emit events to, do nothing (wait)
        if (eventSink == nil) {
            return
        }
        // Emit pedestrian status event to Flutter
        eventSink!(status)
    }

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink

        if #available(iOS 10.0, *) {
            if (!CMPedometer.isPedometerEventTrackingAvailable()) {
                eventSink(FlutterError(code: "2", message: "Step Detection is not available", details: nil))
            } else if (!running) {
                running = true
                pedometer.startEventUpdates() {
                    pedometerData, error in
                    guard let pedometerData = pedometerData, error == nil else { return }

                    DispatchQueue.main.async {
                        self.handleEvent(status: pedometerData.type.rawValue)
                    }
                }
            }
        } else {
            eventSink(FlutterError(code: "1", message: "Requires iOS 10.0 minimum", details: nil))
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil

        if (running) {
            pedometer.stopUpdates()
            running = false
        }
        return nil
    }
}

/// StepCounter, handles step count streaming
public class StepCounter: NSObject, FlutterStreamHandler {
    private let pedometer = CMPedometer()
    private var running = false
    private var eventSink: FlutterEventSink?

    private func handleEvent(data: [String: Any]) {
        // If no eventSink to emit events to, do nothing (wait)
        if (eventSink == nil) {
            return
        }
        // Emit step count event to Flutter
        eventSink!(data)
    }

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        if #available(iOS 10.0, *) {
            if (!CMPedometer.isStepCountingAvailable()) {
                eventSink(FlutterError(code: "3", message: "Step Count is not available", details: nil))
            } else if (!running) {
                let systemUptime = ProcessInfo.processInfo.systemUptime;
                let timeNow = Date().timeIntervalSince1970
                let dateOfLastReboot = Date(timeIntervalSince1970: timeNow - systemUptime)
                running = true
                pedometer.startUpdates(from: dateOfLastReboot) {
                    pedometerData, error in
                    guard let data = pedometerData, error == nil else { return }

                    let result: [String: Any] = [
                        "startDate": Int64(data.startDate.timeIntervalSince1970 * 1000), // Milliseconds since epoch
                        "endDate": Int64(data.endDate.timeIntervalSince1970 * 1000), // Milliseconds since epoch
                        "numberOfSteps": data.numberOfSteps.intValue,
                        "distance": data.distance?.doubleValue,
                        "averageActivePace": data.averageActivePace?.doubleValue,
                        "currentPace": data.currentPace?.doubleValue,
                        "currentCadence": data.currentCadence?.doubleValue,
                        "floorsAscended": data.floorsAscended?.intValue,
                        "floorsDescended": data.floorsDescended?.intValue
                    ].compactMapValues { $0 }
                    
                    DispatchQueue.main.async {
                        self.handleEvent(data: result)
                    }
                }
            }
        } else {
            eventSink(FlutterError(code: "1", message: "Requires iOS 10.0 minimum", details: nil))
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil

        if (running) {
            pedometer.stopUpdates()
            running = false
        }
        return nil
    }
}

/// StepCounterFrom, handles step count streaming from a specific date
public class StepCounterFrom: NSObject, FlutterStreamHandler {
    private let pedometer = CMPedometer()
    private var running = false
    private var eventSink: FlutterEventSink?

    private func handleEvent(data: [String: Any]) {
        // If no eventSink to emit events to, do nothing (wait)
        if (eventSink == nil) {
            return
        }
        // Emit step count event to Flutter
        eventSink!(data)
    }

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        if #available(iOS 10.0, *) {
            if (!CMPedometer.isStepCountingAvailable()) {
                eventSink(FlutterError(code: "3", message: "Step Count is not available", details: nil))
            } else if (!running) {
                guard let arguments = arguments as? NSDictionary,
                    let startTime = (arguments["startTime"] as? NSNumber)
                else {
                    eventSink(FlutterError(code: "3", message: "Not arrowed arguments", details: nil))
                    return nil
                }
                let dateFrom = Date(timeIntervalSince1970: startTime.doubleValue / 1000)
                running = true
                pedometer.startUpdates(from: dateFrom) {
                    pedometerData, error in
                    guard let data = pedometerData, error == nil else { return }
                    let result: [String: Any] = [
                        "startDate": Int64(data.startDate.timeIntervalSince1970 * 1000), // Milliseconds since epoch
                        "endDate": Int64(data.endDate.timeIntervalSince1970 * 1000), // Milliseconds since epoch
                        "numberOfSteps": data.numberOfSteps.intValue,
                        "distance": data.distance?.doubleValue,
                        "averageActivePace": data.averageActivePace?.doubleValue,
                        "currentPace": data.currentPace?.doubleValue,
                        "currentCadence": data.currentCadence?.doubleValue,
                        "floorsAscended": data.floorsAscended?.intValue,
                        "floorsDescended": data.floorsDescended?.intValue
                    ].compactMapValues { $0 }
                    DispatchQueue.main.async {
                        self.handleEvent(data: result)
                    }
                }
            }
        } else {
            eventSink(FlutterError(code: "1", message: "Requires iOS 10.0 minimum", details: nil))
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil

        if (running) {
            pedometer.stopUpdates()
            running = false
        }
        return nil
    }
}

public class StepCount: NSObject {
    private let pedometer = CMPedometer()
    
    func queryPedometerData(call: FlutterMethodCall, channelResult: @escaping FlutterResult) {
        if (!CMPedometer.isStepCountingAvailable()) {
            channelResult(FlutterError(code: "3", message: "Not isStepCountingAvailable", details: nil))
            return
        }
        guard let arguments = call.arguments as? NSDictionary,
            let startTime = (arguments["startTime"] as? NSNumber),
            let endTime = (arguments["endTime"] as? NSNumber)
        else {
            channelResult(FlutterError(code: "3", message: "Not arrowed arguments", details: nil))
            return
        }
        let dateFrom = Date(timeIntervalSince1970: startTime.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: endTime.doubleValue / 1000)
        pedometer.queryPedometerData(from: dateFrom, to: dateTo) {
            pedometerData, error in
            if (error == nil) {
                guard let data = pedometerData
                else {
                    channelResult(FlutterError(code: "3", message: "Not get pedometerData", details: nil))
                    return
                }
                let result: [String: Any] = [
                    "startDate": Int64(data.startDate.timeIntervalSince1970 * 1000), // Milliseconds since epoch
                    "endDate": Int64(data.endDate.timeIntervalSince1970 * 1000), // Milliseconds since epoch
                    "numberOfSteps": data.numberOfSteps.intValue,
                    "distance": data.distance?.doubleValue,
                    "averageActivePace": data.averageActivePace?.doubleValue,
                    "currentPace": data.currentPace?.doubleValue,
                    "currentCadence": data.currentCadence?.doubleValue,
                    "floorsAscended": data.floorsAscended?.intValue,
                    "floorsDescended": data.floorsDescended?.intValue
                ].compactMapValues { $0 }
                channelResult(result)
            } else {
                channelResult(FlutterError(code: "3", message: "Error: \(error!)", details: nil))
            }
        }
    }
}