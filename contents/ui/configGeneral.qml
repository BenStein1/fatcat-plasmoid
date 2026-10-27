import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    // Plasma's config loader binds cfg_* values. Only user selections write
    // them, so initialization cannot accidentally reset saved preferences.
    property string cfg_metric: "systemRam"
    property string cfg_renderer: "ksvg"

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

    QQC2.ComboBox {
        id: rendererCombo
        Kirigami.FormData.label: i18n("Artwork renderer")
        model: [
            { text: i18n("KDE SVG (default)"), value: "ksvg" },
            { text: i18n("Qt Quick Image (experimental)"), value: "image" }
        ]
        textRole: "text"
        currentIndex: page.cfg_renderer === "image" ? 1 : 0

        onActivated: function(index) {
            page.cfg_renderer = model[index].value
        }
    }
}
