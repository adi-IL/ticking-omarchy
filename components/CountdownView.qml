import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: countdownRoot

    property var timeData: ({
        days: "00",
        hours: "00",
        minutes: "00",
        seconds: "00",
        milliseconds: "00",
        progressRatio: 0.0,
        progressPercent: "0.000%",
        isExpired: false
    })

    property bool showMilliseconds: true
    property bool showProgress: true
    property color accentColor: "#00E599"
    property var themeColors: null

    spacing: 6

    // Metric Cards Grid
    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 6

        MetricCard {
            value: countdownRoot.timeData.days
            unit: "Days"
            accentColor: countdownRoot.accentColor
            themeColors: countdownRoot.themeColors
        }

        MetricCard {
            value: countdownRoot.timeData.hours
            unit: "Hours"
            accentColor: countdownRoot.accentColor
            themeColors: countdownRoot.themeColors
        }

        MetricCard {
            value: countdownRoot.timeData.minutes
            unit: "Mins"
            accentColor: countdownRoot.accentColor
            themeColors: countdownRoot.themeColors
        }

        MetricCard {
            value: countdownRoot.timeData.seconds
            unit: "Secs"
            accentColor: countdownRoot.accentColor
            isHighlighted: true
            themeColors: countdownRoot.themeColors
        }

        MetricCard {
            visible: countdownRoot.showMilliseconds
            value: countdownRoot.timeData.milliseconds
            unit: "Msec"
            accentColor: countdownRoot.accentColor
            themeColors: countdownRoot.themeColors
        }
    }

    // Milestone Reached Banner
    Rectangle {
        visible: countdownRoot.timeData.isExpired
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        radius: 6
        color: Qt.rgba(countdownRoot.accentColor.r, countdownRoot.accentColor.g, countdownRoot.accentColor.b, 0.15)
        border.width: 1
        border.color: countdownRoot.accentColor

        RowLayout {
            anchors.centerIn: parent
            spacing: 8
            Text {
                text: "✓"
                color: countdownRoot.accentColor
                font.bold: true
                font.pixelSize: 12
            }
            Text {
                text: "HORIZON REACHED - 100.000% COMPLETED"
                color: countdownRoot.accentColor
                font.weight: Font.Bold
                font.pixelSize: 10
                font.letterSpacing: 1.2
            }
        }
    }

    // Progress Bar Track
    ProgressTrack {
        visible: countdownRoot.showProgress
        Layout.fillWidth: true
        progressRatio: countdownRoot.timeData.progressRatio
        percentageText: countdownRoot.timeData.progressPercent
        accentColor: countdownRoot.accentColor
        themeColors: countdownRoot.themeColors
    }
}
