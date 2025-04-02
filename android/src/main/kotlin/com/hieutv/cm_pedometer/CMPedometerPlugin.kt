package com.hieutv.cm_pedometer

import android.app.AlertDialog
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class CMPedometerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var stepDetectionChannel: EventChannel
    private lateinit var stepCounterFirstChannel: EventChannel
    private lateinit var stepCounterSecondChannel: EventChannel
    private lateinit var stepCounterThirdChannel: EventChannel

    private lateinit var context: Context
    private lateinit var sensorManager: SensorManager

    private var stepDetectorHandler: StepDetector? = null
    private var stepCounterHandler: StepCounter? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager

        // Khai báo channel method
        methodChannel = MethodChannel(binding.binaryMessenger, "cm_pedometer")
        methodChannel.setMethodCallHandler(this)

        // Thiết lập EventChannel cho step detection
        stepDetectorHandler = StepDetector(sensorManager)
        stepDetectionChannel = EventChannel(binding.binaryMessenger, "step_detection")
        stepDetectionChannel.setStreamHandler(stepDetectorHandler)

        // Thiết lập 3 EventChannel cho step counter (có thể dùng chung 1 listener)
        stepCounterHandler = StepCounter(sensorManager)
        stepCounterFirstChannel = EventChannel(binding.binaryMessenger, "step_counter_first")
        stepCounterFirstChannel.setStreamHandler(stepCounterHandler)
        stepCounterSecondChannel = EventChannel(binding.binaryMessenger, "step_counter_second")
        stepCounterSecondChannel.setStreamHandler(stepCounterHandler)
        stepCounterThirdChannel = EventChannel(binding.binaryMessenger, "step_counter_third")
        stepCounterThirdChannel.setStreamHandler(stepCounterHandler)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        stepDetectionChannel.setStreamHandler(null)
        stepCounterFirstChannel.setStreamHandler(null)
        stepCounterSecondChannel.setStreamHandler(null)
        stepCounterThirdChannel.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android " + Build.VERSION.RELEASE)
            }
            "showAlert" -> {
                // Hiển thị alert dialog trên Android (lưu ý cần Activity context để hiển thị dialog, sử dụng context ở đây có thể hạn chế)
                AlertDialog.Builder(context)
                    .setTitle("Hello")
                    .setMessage("I am a native alert dialog.")
                    .setPositiveButton("OK") { dialog, _ -> dialog.dismiss() }
                    .show()
                result.success(null)
            }
            "isStepCountingAvailable" -> {
                val sensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
                result.success(sensor != null)
            }
            "isDistanceAvailable" -> {
                // Android không hỗ trợ đo khoảng cách từ cảm biến bước chân
                result.success(false)
            }
            "isFloorCountingAvailable" -> {
                // Android không cung cấp API đếm tầng
                result.success(false)
            }
            "isPaceAvailable" -> {
                // Tốc độ đi bộ không có sẵn từ cảm biến bước chân
                result.success(false)
            }
            "isCadenceAvailable" -> {
                // Cadence không được hỗ trợ
                result.success(false)
            }
            "isPedometerEventTrackingAvailable" -> {
                val sensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
                result.success(sensor != null)
            }
            "queryPedometerData" -> {
                // Android không cung cấp API truy vấn dữ liệu lịch sử của cảm biến bước chân
                result.error("UNAVAILABLE", "Querying pedometer data is not supported on Android", null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    // Handler cho step detection: sử dụng Sensor.TYPE_STEP_DETECTOR
    private class StepDetector(private val sensorManager: SensorManager) : EventChannel.StreamHandler, SensorEventListener {
        private var eventSink: EventChannel.EventSink? = null

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            eventSink = events
            val sensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
            if (sensor == null) {
                eventSink?.error("UNAVAILABLE", "Step Detector sensor not available", null)
                return
            }
            sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_NORMAL)
        }

        override fun onCancel(arguments: Any?) {
            sensorManager.unregisterListener(this)
            eventSink = null
        }

        override fun onSensorChanged(event: SensorEvent?) {
            if (event?.sensor?.type == Sensor.TYPE_STEP_DETECTOR) {
                // Với sensor TYPE_STEP_DETECTOR, event.values[0] luôn bằng 1.0 cho mỗi bước
                eventSink?.success(1)
            }
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
            // Không sử dụng
        }
    }

    // Handler cho step counter: sử dụng Sensor.TYPE_STEP_COUNTER
    private class StepCounter(private val sensorManager: SensorManager) : EventChannel.StreamHandler, SensorEventListener {
        private var eventSink: EventChannel.EventSink? = null
        private var initialStepCount: Float? = null

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            eventSink = events
            val sensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
            if (sensor == null) {
                eventSink?.error("UNAVAILABLE", "Step Counter sensor not available", null)
                return
            }
            sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_NORMAL)
        }

        override fun onCancel(arguments: Any?) {
            sensorManager.unregisterListener(this)
            eventSink = null
            initialStepCount = null
        }

        override fun onSensorChanged(event: SensorEvent?) {
            if (event?.sensor?.type == Sensor.TYPE_STEP_COUNTER) {
                val cumulativeSteps = event.values[0]
                if (initialStepCount == null) {
                    initialStepCount = cumulativeSteps
                }
                // Tính số bước kể từ khi bắt đầu lắng nghe
                val steps = cumulativeSteps - (initialStepCount ?: cumulativeSteps)
                // Tạo kết quả trả về tương tự iOS (lưu ý các trường không có trên Android sẽ trả về null)
                val resultData: Map<String, Any?> = mapOf(
                    "startDate" to System.currentTimeMillis(), // Không có dữ liệu chính xác
                    "endDate" to System.currentTimeMillis(),
                    "numberOfSteps" to steps.toInt(),
                    "distance" to null,
                    "averageActivePace" to null,
                    "currentPace" to null,
                    "currentCadence" to null,
                    "floorsAscended" to null,
                    "floorsDescended" to null
                )
                eventSink?.success(resultData)
            }
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
            // Không sử dụng
        }
    }
}
