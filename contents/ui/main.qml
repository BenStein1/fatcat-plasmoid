import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.ksvg as KSvg

PlasmoidItem {
    id: root

    implicitWidth: 160
    implicitHeight: 225

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    property string metric: plasmoid.configuration.metric || "systemRam"

    property real minScale: 1.0
    property real maxScale: 2.0
    property bool growFromCenter: true
    property int calibrationPercent: 60
    property real measuredFrac: 0.0
    property real effFrac: Math.max(0, Math.min(1, measuredFrac)) * (Math.max(1, calibrationPercent) / 100.0)

    property int idleBlinkMin: 1800
    property int idleBlinkMax: 15000
    property int closedBlinkMs: 140
    property bool eyesOpen: true

    KSvg.Svg {
        id: bottomArt
        imagePath: Qt.resolvedUrl("../images/fatcat-bottom.svg").toString()
    }

    KSvg.Svg {
        id: bodyArt
        imagePath: Qt.resolvedUrl("../images/fatcat-body.svg").toString()
    }

    KSvg.Svg {
        id: topOpen
        imagePath: Qt.resolvedUrl("../images/fatcat-top-eyes-open.svg").toString()
    }

    KSvg.Svg {
        id: topClosed
        imagePath: Qt.resolvedUrl("../images/fatcat-top-eyes-closed.svg").toString()
    }

    KSvg.SvgItem {
        anchors.fill: parent
        svg: bottomArt
    }

    KSvg.SvgItem {
        id: body
        anchors.fill: parent
        svg: bodyArt
        transform: Scale {
            origin.x: growFromCenter ? body.width / 2 : 0
            origin.y: body.height / 2
            xScale: root.minScale + root.effFrac * (root.maxScale - root.minScale)
            yScale: 1
        }
    }

    KSvg.SvgItem {
        anchors.fill: parent
        svg: eyesOpen ? topOpen : topClosed
    }

    Timer {
        id: blink
        repeat: true
        running: root.visible
        interval: idleBlinkMin + Math.floor(Math.random() * (idleBlinkMax - idleBlinkMin + 1))

        onTriggered: {
            eyesOpen = !eyesOpen
            interval = eyesOpen
                ? idleBlinkMin + Math.floor(Math.random() * (idleBlinkMax - idleBlinkMin + 1))
                : closedBlinkMs
        }
    }

    // Each sensor has an immutable ID. Switching metrics only toggles
    // subscriptions, avoiding repeated commands and stale sensor IDs.
    function numberFromSensor(sensor) {
        if (sensor.status !== Sensors.Sensor.Ready ||
                sensor.value === undefined || sensor.value === null)
            return NaN

        var n = Number(sensor.value)
        return isFinite(n) ? n : NaN
    }

    // KSystemStats *Percent sensors report 0..100, not a 0..1 ratio.
    function percentFraction(sensor) {
        var percent = numberFromSensor(sensor)
        return (percent >= 0 && percent <= 100) ? percent / 100.0 : NaN
    }

    function usageFraction(usedSensor, totalSensor) {
        var used = numberFromSensor(usedSensor)
        var total = numberFromSensor(totalSensor)
        return (used >= 0 && total > 0) ? used / total : NaN
    }

    function refreshMetric() {
        var fraction = NaN

        if (root.metric === "systemRam") {
            fraction = percentFraction(ramPercent)
            if (!isFinite(fraction))
                fraction = usageFraction(ramUsed, ramTotal)
        } else if (root.metric === "gpuVram") {
            // Prefer the total across all GPUs. Fall back to GPU 0 only
            // when the aggregate sensors are unavailable on this system.
            fraction = percentFraction(vramPercent)
            if (!isFinite(fraction))
                fraction = usageFraction(vramUsed, vramTotal)
            if (!isFinite(fraction))
                fraction = percentFraction(gpu0Percent)
            if (!isFinite(fraction))
                fraction = usageFraction(gpu0Used, gpu0Total)
        }

        if (isFinite(fraction))
            root.measuredFrac = Math.max(0, Math.min(1, fraction))
    }

    Sensors.Sensor {
        id: ramPercent
        sensorId: "memory/physical/usedPercent"
        enabled: root.visible && root.metric === "systemRam"
        updateRateLimit: 1000
        onValueChanged: root.refreshMetric()
        onStatusChanged: root.refreshMetric()
    }

    Sensors.Sensor {
        id: ramUsed
        sensorId: "memory/physical/used"
        enabled: root.visible && root.metric === "systemRam"
        updateRateLimit: 1000
        onValueChanged: root.refreshMetric()
        onStatusChanged: root.refreshMetric()
    }

    Sensors.Sensor {
        id: ramTotal
        sensorId: "memory/physical/total"
        enabled: root.visible && root.metric === "systemRam"
        updateRateLimit: 1000
        onValueChanged: root.refreshMetric()
        onStatusChanged: root.refreshMetric()
    }

    Sensors.Sensor {
        id: vramPercent
        sensorId: "gpu/all/usedPercent"
        enabled: root.visible && root.metric === "gpuVram"
        updateRateLimit: 1000
        onValueChanged: root.refreshMetric()
        onStatusChanged: root.refreshMetric()
    }

    Sensors.Sensor {
        id: vramUsed
        sensorId: "gpu/all/usedVram"
        enabled: root.visible && root.metric === "gpuVram"
        updateRateLimit: 1000
        onValueChanged: root.refreshMetric()
        onStatusChanged: root.refreshMetric()
    }

    Sensors.Sensor {
        id: vramTotal
        sensorId: "gpu/all/totalVram"
        enabled: root.visible && root.metric === "gpuVram"
        updateRateLimit: 1000
        onValueChanged: root.refreshMetric()
        onStatusChanged: root.refreshMetric()
    }

    Sensors.Sensor {
        id: gpu0Percent
        sensorId: "gpu/gpu0/usedPercent"
        enabled: root.visible && root.metric === "gpuVram"
        updateRateLimit: 1000
        onValueChanged: root.refreshMetric()
        onStatusChanged: root.refreshMetric()
    }

    Sensors.Sensor {
        id: gpu0Used
        sensorId: "gpu/gpu0/usedVram"
        enabled: root.visible && root.metric === "gpuVram"
        updateRateLimit: 1000
        onValueChanged: root.refreshMetric()
        onStatusChanged: root.refreshMetric()
    }

    Sensors.Sensor {
        id: gpu0Total
        sensorId: "gpu/gpu0/totalVram"
        enabled: root.visible && root.metric === "gpuVram"
        updateRateLimit: 1000
        onValueChanged: root.refreshMetric()
        onStatusChanged: root.refreshMetric()
    }

    onMetricChanged: {
        measuredFrac = 0
        refreshMetric()
    }

}
