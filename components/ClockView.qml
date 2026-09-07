import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: clockRoot

    property var clockData: ({
        hours: "00",
        minutes: "00",
        seconds: "00",
        amPm: "",
        dateString: "",
        timeZone: "UTC",
        dayOfYear: 1,
        weekOfYear: 1
    })

    property color accentColor: "#00E599"
    property var themeColors: ({
        subCardBg: Qt.rgba(0.06, 0.06, 0.06, 0.88),
        cardBorder: Qt.rgba(1, 1, 1, 0.12),
        specularGlint: Qt.rgba(1, 1, 1, 0.25),
        textPrimary: "#EDEDED",
        textSecondary: "#A1A1AA",
        textMuted: "#71717A"
    })

    spacing: 8

    // Big Digital Time Card
    Rectangle {
        id: clockCard
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: 90
        radius: 8
        color: clockRoot.themeColors.subCardBg
        border.width: 1
        border.color: clockRoot.themeColors.cardBorder

        // Top edge specular line
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
                GradientStop { position: 0.5; color: clockRoot.themeColors.specularGlint }
                GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.04) }
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 6

            // Time Row
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                readonly property int responsiveFontSize: Math.min(42, Math.max(26, clockCard.width * 0.11))

                Text {
                    text: clockRoot.clockData.hours
                    color: clockRoot.themeColors.textPrimary
                    font.family: "monospace"
                    font.weight: Font.Bold
                    font.pixelSize: parent.responsiveFontSize
                }

                Text {
                    text: ":"
                    color: clockRoot.accentColor
                    font.family: "monospace"
                    font.weight: Font.Bold
                    font.pixelSize: parent.responsiveFontSize
                }

                Text {
                    text: clockRoot.clockData.minutes
                    color: clockRoot.themeColors.textPrimary
                    font.family: "monospace"
                    font.weight: Font.Bold
                    font.pixelSize: parent.responsiveFontSize
                }

                Text {
                    text: ":"
                    color: clockRoot.accentColor
                    font.family: "monospace"
                    font.weight: Font.Bold
                    font.pixelSize: parent.responsiveFontSize
                }

                Text {
                    text: clockRoot.clockData.seconds
                    color: clockRoot.accentColor
                    font.family: "monospace"
                    font.weight: Font.Bold
                    font.pixelSize: parent.responsiveFontSize
                }

                Text {
                    visible: clockRoot.clockData.amPm !== ""
                    text: clockRoot.clockData.amPm
                    color: clockRoot.themeColors.textSecondary
                    font.family: "sans-serif"
                    font.weight: Font.Bold
                    font.pixelSize: 13
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 6
                }
            }

            // Full Date String
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: clockRoot.clockData.dateString
                color: clockRoot.themeColors.textSecondary
                font.family: "sans-serif"
                font.weight: Font.DemiBold
                font.pixelSize: 11
                font.letterSpacing: 1.2
                font.capitalization: Font.AllUppercase
            }
        }
    }

    // Secondary Info Pills
    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        // Timezone Pill
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            radius: 6
            color: clockRoot.themeColors.subCardBg
            border.width: 1
            border.color: clockRoot.themeColors.cardBorder

            RowLayout {
                anchors.centerIn: parent
                spacing: 6
                Text { text: "ZONE:"; color: clockRoot.themeColors.textMuted; font.pixelSize: 9; font.weight: Font.Bold }
                Text { text: clockRoot.clockData.timeZone; color: clockRoot.themeColors.textPrimary; font.pixelSize: 10; font.family: "monospace"; font.weight: Font.Bold }
            }
        }

        // Day of Year Pill
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            radius: 6
            color: clockRoot.themeColors.subCardBg
            border.width: 1
            border.color: clockRoot.themeColors.cardBorder

            RowLayout {
                anchors.centerIn: parent
                spacing: 6
                Text { text: "DAY:"; color: clockRoot.themeColors.textMuted; font.pixelSize: 9; font.weight: Font.Bold }
                Text { text: "" + clockRoot.clockData.dayOfYear; color: clockRoot.themeColors.textPrimary; font.pixelSize: 10; font.family: "monospace"; font.weight: Font.Bold }
            }
        }

        // Week of Year Pill
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            radius: 6
            color: clockRoot.themeColors.subCardBg
            border.width: 1
            border.color: clockRoot.themeColors.cardBorder

            RowLayout {
                anchors.centerIn: parent
                spacing: 6
                Text { text: "ISO WK:"; color: clockRoot.themeColors.textMuted; font.pixelSize: 9; font.weight: Font.Bold }
                Text { text: "#" + clockRoot.clockData.weekOfYear; color: clockRoot.themeColors.textPrimary; font.pixelSize: 10; font.family: "monospace"; font.weight: Font.Bold }
            }
        }
    }
}
