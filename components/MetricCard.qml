import QtQuick
import QtQuick.Layouts

Rectangle {
    id: cardRoot

    property string value: "00"
    property string unit: "UNIT"
    property color accentColor: "#00E599"
    property bool isHighlighted: false
    property bool isCompact: cardRoot.width < 68
    property var themeColors: ({
        subCardBg: Qt.rgba(0.06, 0.06, 0.06, 0.88),
        subCardHover: Qt.rgba(0.12, 0.12, 0.12, 0.96),
        cardBorder: Qt.rgba(1, 1, 1, 0.09),
        cardBorderHover: Qt.rgba(1, 1, 1, 0.18),
        specularGlint: Qt.rgba(1, 1, 1, 0.45),
        textPrimary: "#EDEDED",
        textSecondary: "#A1A1AA",
        textMuted: "#71717A"
    })

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumWidth: isCompact ? 40 : 50
    Layout.minimumHeight: isCompact ? 44 : 54

    radius: 8
    color: mouseArea.containsMouse ? cardRoot.themeColors.subCardHover : cardRoot.themeColors.subCardBg

    Behavior on color { ColorAnimation { duration: 150 } }

    border.width: 1
    border.color: mouseArea.containsMouse ? cardRoot.themeColors.cardBorderHover : cardRoot.themeColors.cardBorder

    Behavior on border.color { ColorAnimation { duration: 150 } }

    // Top edge sub-pixel highlight (specular line)
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 1
        height: 1
        radius: 1
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.04) }
            GradientStop { position: 0.5; color: mouseArea.containsMouse ? cardRoot.themeColors.specularGlint : Qt.rgba(1, 1, 1, 0.15) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.04) }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: isCompact ? 4 : 8
        spacing: 2

        // Value text
        Text {
            id: valueText
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: cardRoot.value
            color: cardRoot.isHighlighted ? cardRoot.accentColor : cardRoot.themeColors.textPrimary
            font.family: "monospace"
            font.weight: Font.Bold
            font.pixelSize: isCompact ? Math.max(14, cardRoot.height * 0.42) : Math.max(18, cardRoot.height * 0.48)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSizeMode: Text.Fit
            minimumPixelSize: 10
        }

        // Unit label
        Text {
            Layout.fillWidth: true
            text: cardRoot.unit
            color: mouseArea.containsMouse ? cardRoot.themeColors.textSecondary : cardRoot.themeColors.textMuted
            font.family: "sans-serif"
            font.weight: Font.DemiBold
            font.pixelSize: isCompact ? 8 : 10
            font.letterSpacing: 1.2
            font.capitalization: Font.AllUppercase
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
