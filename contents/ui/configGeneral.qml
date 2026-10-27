import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    // Plasma's configuration loader reads/writes cfg_metric. Avoid updating
    // settings from ComboBox initialization, which is not a user selection.
    property string cfg_metric: "systemRam"

    QQC2.ComboBox {
        id: metricCombo
        Kirigami.FormData.label: i18n("Metric to report")
        model: [
            { text: i18n("System RAM usage"), value: "systemRam" },
            { text: i18n("GPU VRAM usage"), value: "gpuVram" }
        ]
        textRole: "text"
        currentIndex: page.cfg_metric === "gpuVram" ? 1 : 0

        onActivated: function(index) {
            page.cfg_metric = model[index].value
        }
    }
}
