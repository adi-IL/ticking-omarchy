import QtQuick
import QtQuick.Layouts

Rectangle {
    id: navRoot

    property int currentIndex: 0
    property var themeColors: ({
        subCardBg: Qt.rgba(0.06, 0.06, 0.06, 0.88),
        subCardHover: Qt.rgba(0.12, 0.12, 0.12, 0.96),
        cardBorder: Qt.rgba(1, 1, 1, 0.09),
        cardBorderHover: Qt.rgba(1, 1, 1, 0.18),
        textPrimary: "#EDEDED",
        textSecondary: "#A1A1AA",
        textMuted: "#71717A"
    })

    signal tabSelected(int index)

    readonly property var tabs: [
        { name: "COUNTDOWN", iconGlyph: "⏱" },
        { name: "CLOCK", iconGlyph: "🕒" },
        { name: "STOPWATCH", iconGlyph: "⏱" }
    ]

    Layout.fillWidth: true
    Layout.preferredHeight: 32
    radius: 8
    color: navRoot.themeColors.subCardBg
    border.width: 1
    border.color: navRoot.themeColors.cardBorder

    RowLayout {
        anchors.fill: parent
        anchors.margins: 3
        spacing: 2

        Repeater {
            model: navRoot.tabs

            Item {
                id: tabItem
                Layout.fillWidth: true
                Layout.fillHeight: true

                readonly property bool isSelected: navRoot.currentIndex === index
                readonly property bool isHovered: tabMouse.containsMouse

                // Active pill background
                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: tabItem.isSelected
                        ? Qt.rgba(0.18, 0.18, 0.18, 0.95)
                        : (tabItem.isHovered ? navRoot.themeColors.subCardHover : "transparent")
                    border.width: tabItem.isSelected ? 1 : 0
                    border.color: tabItem.isSelected ? navRoot.themeColors.cardBorderHover : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: modelData.iconGlyph
                        color: tabItem.isSelected ? navRoot.themeColors.textPrimary : (tabItem.isHovered ? navRoot.themeColors.textSecondary : navRoot.themeColors.textMuted)
                        font.pixelSize: 11
                    }

                    Text {
                        text: modelData.name
                        color: tabItem.isSelected ? navRoot.themeColors.textPrimary : (tabItem.isHovered ? navRoot.themeColors.textSecondary : navRoot.themeColors.textMuted)
                        font.family: "sans-serif"
                        font.weight: tabItem.isSelected ? Font.Bold : Font.DemiBold
                        font.pixelSize: 10
                        font.letterSpacing: 1.1
                        font.capitalization: Font.AllUppercase
                    }
                }

                MouseArea {
                    id: tabMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        navRoot.tabSelected(index);
                    }
                }
            }
        }
    }
}
