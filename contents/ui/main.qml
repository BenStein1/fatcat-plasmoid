import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
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

    readonly property var ramPercentIds: [ "memory/physical/usedPercent", "memory/ram/usedPercent" ]
    readonly property var ramUsedIds:    [ "memory/physical/used", "memory/ram/used" ]
    readonly property var ramTotalIds:   [ "memory/physical/total", "memory/ram/total" ]

    readonly property var vramUsedIds:   [ "gpu/all/usedVram", "gpu/all/memory/used", "gpu/0/memory/used" ]
    readonly property var vramTotalIds:  [ "gpu/all/totalVram", "gpu/all/memory/total", "gpu/0/memory/total" ]
    readonly property var vramPercentIds:[ "gpu/all/memory/usedPercent", "gpu/0/memory/usedPercent" ]

    property real lastUsed: 0
    property real lastTotal: 0
    property double lastUpdateMs: 0
    readonly property int staleMs: 1500

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
        running: true
        interval: idleBlinkMin + Math.floor(Math.random() * (idleBlinkMax - idleBlinkMin + 1))

        onTriggered: {
            eyesOpen = !eyesOpen
            interval = eyesOpen
                ? idleBlinkMin + Math.floor(Math.random() * (idleBlinkMax - idleBlinkMin + 1))
                : closedBlinkMs
        }
    }

    Plasma5Support.DataSource {
        id: sysmon
        engine: "systemmonitor"
        interval: 1000
        connectedSources: []

        onSourceAdded: function(s) {
            if (ramPercentIds.indexOf(s) >= 0 || ramUsedIds.indexOf(s) >= 0 || ramTotalIds.indexOf(s) >= 0
                    || vramPercentIds.indexOf(s) >= 0 || vramUsedIds.indexOf(s) >= 0 || vramTotalIds.indexOf(s) >= 0) {
                console.log("[fatcat] source added:", s)
            }
        }

        onNewData: function(sourceName, data) {
            if (!data)
                return

            if (root.metric === "systemRam") {
                if (ramPercentIds.indexOf(sourceName) >= 0 && data.value !== undefined) {
                    var pv = Number(data.value)
                    root.measuredFrac = (pv > 1.0) ? pv / 100.0 : pv
                    lastUpdateMs = Date.now()
                    return
                }

                if (ramUsedIds.indexOf(sourceName) >= 0 && data.value !== undefined)
                    lastUsed = Number(data.value)

                if (ramTotalIds.indexOf(sourceName) >= 0 && data.value !== undefined)
                    lastTotal = Number(data.value)

                if (lastTotal > 0) {
                    root.measuredFrac = Math.max(0, Math.min(1, lastUsed / lastTotal))
                    lastUpdateMs = Date.now()
                }

                return
            }

            if (root.metric === "gpuVram") {
                if (vramPercentIds.indexOf(sourceName) >= 0 && data.value !== undefined) {
                    var gp = Number(data.value)
                    root.measuredFrac = (gp > 1.0) ? gp / 100.0 : gp
                    lastUpdateMs = Date.now()
                    return
                }

                if (vramUsedIds.indexOf(sourceName) >= 0 && data.value !== undefined)
                    lastUsed = Number(data.value)

                if (vramTotalIds.indexOf(sourceName) >= 0 && data.value !== undefined)
                    lastTotal = Number(data.value)

                if (lastTotal > 0) {
                    root.measuredFrac = Math.max(0, Math.min(1, lastUsed / lastTotal))
                    lastUpdateMs = Date.now()
                }

                return
            }
        }
    }

    Plasma5Support.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            var out = (data && data["stdout"]) ? String(data["stdout"]) : ""
            var parts = out.replace(/\s+/g, "").split(",")

            if (parts.length >= 2) {
                var used = parseFloat(parts[0]) || 0
                var tot = parseFloat(parts[1]) || 0

                if (tot > 0) {
                    root.measuredFrac = Math.max(0, Math.min(1, used / tot))
                    lastUpdateMs = Date.now()
                }
            }

            exec.disconnectSource(source)
        }
    }

    function probeSensors() {
        var list = []

        if (root.metric === "systemRam") {
            list = ramPercentIds.concat(ramUsedIds).concat(ramTotalIds)
        } else {
            list = vramPercentIds.concat(vramUsedIds).concat(vramTotalIds)
        }

        sysmon.connectedSources = list
        lastUsed = 0
        lastTotal = 0
        lastUpdateMs = 0

        console.log("[fatcat] metric =", root.metric, "subscribing:", list.join(", "))
    }

    function readFile(path, cb) {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "file://" + path)
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return
            cb(xhr.responseText || "")
        }
        xhr.send()
    }

    function fallbackRamFromProc() {
        readFile("/proc/meminfo", function(t) {
            var mt = /MemTotal:\s+(\d+)\s+kB/.exec(t)
            var ma = /MemAvailable:\s+(\d+)\s+kB/.exec(t)

            if (!mt || !ma)
                return

            var total = parseInt(mt[1])
            var avail = parseInt(ma[1])
            var used = Math.max(0, total - avail)
            var frac = total > 0 ? (used / total) : 0

            root.measuredFrac = Math.max(0, Math.min(1, frac))
            lastUpdateMs = Date.now()
        })
    }

    function fallbackGpuFromNvidiaSmi() {
        var cmd = "nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits -i 0"
        exec.connectSource(cmd)
    }

    Timer {
        id: poll
        interval: 1000
        repeat: true
        running: true

        onTriggered: {
            var now = Date.now()
            var stale = (now - lastUpdateMs) > staleMs

            if (root.metric === "systemRam") {
                if (stale)
                    fallbackRamFromProc()
            } else {
                if (stale)
                    fallbackGpuFromNvidiaSmi()
            }
        }

        Component.onCompleted: probeSensors()
    }

    onMetricChanged: probeSensors()
}
