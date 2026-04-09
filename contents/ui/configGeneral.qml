import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    // KConfigXT binding: matches <entry name="metric">
    property alias cfg_metric: metricValue.text

    // Hidden store for the string value
    QQC2.TextField { id: metricValue; visible: false; text: "systemRam" }

    QQC2.ComboBox {
        Kirigami.FormData.label: i18n("Metric to report")
        model: [
            { text: i18n("System RAM usage"), value: "systemRam" },
            { text: i18n("GPU VRAM usage"),   value: "gpuVram" }
        ]
        textRole: "text"
        Component.onCompleted: {
            var v = metricValue.text || "systemRam";
            currentIndex = (v === "gpuVram") ? 1 : 0;
        }
        onCurrentIndexChanged: if (currentIndex >= 0)
            metricValue.text = model[currentIndex].value;
    }
}
