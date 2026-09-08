import QtQuick
import QtQuick.Layouts
import "./components" as Components

Item {
    id: popupRoot

    property var stateEngine: null
    property var bar: null
    property bool opened: false

    signal closeRequested()

    implicitWidth: 380
    implicitHeight: cardLayout.implicitHeight + 24
    width: implicitWidth
    height: implicitHeight

    // Obsidian Glass Container
    Rectangle {
        id: hudCard
        anchors.fill: parent
        anchors.margins: 4
        radius: 12
        color: stateEngine ? stateEngine.themeColors.cardBg : Qt.rgba(0.03, 0.03, 0.03, 0.88)
        border.width: 1
        border.color: mouseTracker.hovered
            ? (stateEngine ? stateEngine.themeColors.cardBorderHover : Qt.rgba(1, 1, 1, 0.18))
            : (stateEngine ? stateEngine.themeColors.cardBorder : Qt.rgba(1, 1, 1, 0.09))

        HoverHandler {
            id: mouseTracker
        }

        // Specular highlight beam across top edge
        Rectangle {
            id: specularBeam
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 1
            radius: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.04) }
                GradientStop {
                    position: Math.max(0.05, Math.min(0.95, (mouseTracker.point ? mouseTracker.point.position.x : 190) / Math.max(1, hudCard.width)))
                    color: mouseTracker.hovered
                        ? (stateEngine ? stateEngine.themeColors.specularGlint : Qt.rgba(1, 1, 1, 0.45))
                        : Qt.rgba(1, 1, 1, 0.20)
                }
                GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.04) }
            }
        }

        ColumnLayout {
            id: cardLayout
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            spacing: 8

            // Top Header: Milestone Headline
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Rectangle {
                    Layout.preferredWidth: 6
                    Layout.preferredHeight: 14
                    radius: 3
                    color: stateEngine ? stateEngine.accentColor : "#00E599"
                }

                Text {
                    text: stateEngine ? stateEngine.customTitle : "NEW HORIZON"
                    color: stateEngine ? stateEngine.themeColors.textPrimary : "#EDEDED"
                    font.family: "sans-serif"
                    font.weight: Font.Bold
                    font.pixelSize: 11
                    font.letterSpacing: 1.2
                    font.capitalization: Font.AllUppercase
                }

                Item { Layout.fillWidth: true }

                // Close button
                Rectangle {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    radius: 4
                    color: closeMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: closeMouse.containsMouse ? "#FFFFFF" : (stateEngine ? stateEngine.themeColors.textMuted : "#71717A")
                        font.pixelSize: 11
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popupRoot.closeRequested()
                    }
                }
            }

            // Segmented Navigation
            Components.SegmentedNav {
                Layout.fillWidth: true
                currentIndex: stateEngine ? stateEngine.activeTab : 0
                themeColors: stateEngine ? stateEngine.themeColors : null
                onTabSelected: function(idx) {
                    if (stateEngine) {
                        stateEngine.activeTab = idx;
                        stateEngine.updateAllMetrics();
                    }
                }
            }

            // View Switcher Stack
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: currentContentItem ? currentContentItem.implicitHeight : 140
                implicitHeight: currentContentItem ? currentContentItem.implicitHeight : 140

                readonly property Item currentContentItem: {
                    if (!stateEngine) return countdownView;
                    if (stateEngine.activeTab === 1) return clockView;
                    if (stateEngine.activeTab === 2) return stopwatchView;
                    return countdownView;
                }

                Components.CountdownView {
                    id: countdownView
                    anchors.fill: parent
                    visible: stateEngine ? stateEngine.activeTab === 0 : true
                    timeData: stateEngine ? stateEngine.countdownData : ({})
                    showMilliseconds: stateEngine ? stateEngine.showMilliseconds : true
                    showProgress: stateEngine ? stateEngine.showProgress : true
                    accentColor: stateEngine ? stateEngine.accentColor : "#00E599"
                    themeColors: stateEngine ? stateEngine.themeColors : null
                }

                Components.ClockView {
                    id: clockView
                    anchors.fill: parent
                    visible: stateEngine ? stateEngine.activeTab === 1 : false
                    clockData: stateEngine ? stateEngine.clockData : ({})
                    accentColor: stateEngine ? stateEngine.accentColor : "#00E599"
                    themeColors: stateEngine ? stateEngine.themeColors : null
                }

                Components.StopwatchView {
                    id: stopwatchView
                    anchors.fill: parent
                    visible: stateEngine ? stateEngine.activeTab === 2 : false
                    stopwatchData: stateEngine ? stateEngine.stopwatchData : ({})
                    accentColor: stateEngine ? stateEngine.accentColor : "#00E599"
                    themeColors: stateEngine ? stateEngine.themeColors : null

                    onStartRequested: if (stateEngine) stateEngine.startStopwatch()
                    onPauseRequested: if (stateEngine) stateEngine.pauseStopwatch()
                    onResetRequested: if (stateEngine) stateEngine.resetStopwatch()
                    onLapRequested: if (stateEngine) stateEngine.lapStopwatch()
                }
            }

            // Quote Capsule
            Components.QuoteBar {
                visible: stateEngine ? stateEngine.showQuoteBar : true
                Layout.fillWidth: true
                quoteText: stateEngine ? stateEngine.currentQuoteText : ""
                quoteAuthor: stateEngine ? stateEngine.currentQuoteAuthor : ""
                isLoading: stateEngine ? stateEngine.isQuoteLoading : false
                accentColor: stateEngine ? stateEngine.accentColor : "#00E599"
                themeColors: stateEngine ? stateEngine.themeColors : null
                onRefreshRequested: if (stateEngine) stateEngine.fetchNextQuote(false)
                onCopyRequested: function(txt) {
                    if (bar && typeof bar.run === "function") {
                        // Also push to Wayland clipboard via wl-copy for system-wide sync
                        var b64 = Qt.btoa(unescape(encodeURIComponent(txt)));
                        bar.run("echo '" + b64 + "' | base64 -d | wl-copy");
                    }
                }
            }
        }
    }

    // Escape Key capture
    FocusScope {
        id: keyFocus
        anchors.fill: parent
        focus: popupRoot.opened
        Keys.onEscapePressed: popupRoot.closeRequested()
    }
}
