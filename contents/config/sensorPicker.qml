import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.4 as Kirigami
import org.kde.ksysguard.sensors 1.0 as Sensors

Kirigami.OverlaySheet {
    id: sheet
    property var targetField: null
    function openFor(field) { targetField = field; open(); }

    header: Kirigami.Heading { text: i18n("Choose a sensor") }

    contentItem: ColumnLayout {
        spacing: 6

        QQC2.TextField {
            id: filterEdit
            placeholderText: i18n("Filter (e.g. 'gpu', 'memory')")
            onTextChanged: proxy.filterText = text
        }

        Sensors.SensorTreeModel { id: treeModel }
        Sensors.SensorProxyModel {
            id: proxy
            sourceModel: treeModel
            filterText: ""
            filterCaseSensitivity: Qt.CaseInsensitive
        }

        QQC2.ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: proxy
            delegate: QQC2.ItemDelegate {
                width: list.width
                text: model.display
                secondaryText: model.sensorId
                onClicked: {
                    if (sheet.targetField) sheet.targetField.text = model.sensorId;
                    sheet.close();
                }
            }
        }
    }
}
