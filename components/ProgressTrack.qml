import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: progressRoot

    property double progressRatio: 0.0 // 0.0 to 1.0
    property string percentageText: "0.000%"
    property string remainingText: ""
    property color accentColor: "#00E599"
    property var themeColors: ({
        textMuted: "#71717A",
        cardBorder: Qt.rgba(1, 1, 1, 0.09)
    })

    spacing: 4

    // Header metrics
    RowLayout {
        Layout.fillWidth: true

        Text {
            text: "JOURNEY TO HORIZON"
            color: progressRoot.themeColors.textMuted
            font.family: "sans-serif"
            font.weight: Font.DemiBold
            font.pixelSize: 10
            font.letterSpacing: 1.1
            font.capitalization: Font.AllUppercase
        }

        Item {
            Layout.fillWidth: true
        }

        Text {
            text: progressRoot.percentageText
            color: progressRoot.accentColor
            font.family: "monospace"
            font.weight: Font.Bold
            font.pixelSize: 11
        }
    }

    // Progress Bar Track
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 6
        radius: 3
        color: Qt.rgba(0.12, 0.12, 0.12, 0.9)
        border.width: 1
        border.color: progressRoot.themeColors.cardBorder

        // Filled active bar
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 1
            width: Math.max(0, Math.min(parent.width - 2, (parent.width - 2) * progressRoot.progressRatio))
            radius: 2

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.rgba(progressRoot.accentColor.r, progressRoot.accentColor.g, progressRoot.accentColor.b, 0.6) }
                GradientStop { position: 1.0; color: progressRoot.accentColor }
            }

            Behavior on width {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }
        }
    }
}
