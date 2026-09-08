import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    // Properties injected by Omarchy Bar.qml
    property var bar: null
    property string moduleName: "ticking"
    property var settings: null

    readonly property bool isVertical: bar ? (bar.vertical === true || bar.position === "left" || bar.position === "right") : false
    readonly property bool showBadge: !isVertical && stateEngine.showPanelBadge

    implicitHeight: bar ? bar.barSize : 26
    implicitWidth: pillContainer.implicitWidth + 8

    // State Engine
    TickingState {
        id: stateEngine
        bar: root.bar
    }

    IpcHandler {
        target: "ticking"

        function open(): void { root.open() }
        function close(): void { root.close() }
        function toggle(): void { root.toggle() }
        function status(): string {
            return JSON.stringify({
                isPopupOpen: stateEngine.isPopupOpen,
                activeTab: stateEngine.activeTab,
                days: stateEngine.countdownData.days,
                hours: stateEngine.countdownData.hours,
                progressPercent: stateEngine.countdownData.progressPercent,
                quoteText: stateEngine.currentQuoteText,
                quoteAuthor: stateEngine.currentQuoteAuthor,
                stopwatchRunning: stateEngine.stopwatchRunning,
                stopwatchElapsed: stateEngine.stopwatchElapsedMs
            });
        }
        function selectTab(idx: int): void {
            if (idx >= 0 && idx <= 3) {
                stateEngine.activeTab = idx;
                stateEngine.updateAllMetrics();
            }
        }
        function startStopwatch(): void { stateEngine.startStopwatch(); }
        function pauseStopwatch(): void { stateEngine.pauseStopwatch(); }
        function resetStopwatch(): void { stateEngine.resetStopwatch(); }
        function nextQuote(): void { stateEngine.fetchNextQuote(false); }
    }

    function injectPopup() {
        if (popupLoader.item) {
            popupLoader.item.stateEngine = stateEngine;
            popupLoader.item.bar = root.bar;
            popupLoader.item.anchorItem = pillContainer;
            popupLoader.item.hostWidget = root;
        }
    }

    onBarChanged: injectPopup()
    onSettingsChanged: injectPopup()

    Component.onCompleted: {
        stateEngine.loadInitialConfig(root.settings);
        Qt.callLater(injectPopup);
    }

    // Tooltip handling
    readonly property Item pillContainerItem: pillContainer
    readonly property string tooltipString: {
        var title = stateEngine.customTitle || "NEW HORIZON";
        if (stateEngine.countdownData.isExpired) {
            return title + " - Horizon Reached";
        }
        return title + " - " + stateEngine.countdownData.days + "d " + stateEngine.countdownData.hours + "h remaining";
    }

    // Bar Face Pill
    Rectangle {
        id: pillContainer
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        height: Math.min(24, parent.height - 2)
        implicitWidth: pillRow.implicitWidth + 12
        width: implicitWidth
        radius: 6

        color: mouseArea.containsMouse
            ? Qt.rgba(1, 1, 1, 0.12)
            : (popupLoader.item && popupLoader.item.visible ? Qt.rgba(1, 1, 1, 0.08) : "transparent")

        border.width: (popupLoader.item && popupLoader.item.visible) ? 1 : 0
        border.color: stateEngine.accentColor

        Behavior on color { ColorAnimation { duration: 150 } }

        RowLayout {
            id: pillRow
            anchors.centerIn: parent
            spacing: 5

            // Ticking Icon / Chronometer glyph
            Text {
                text: "⏱"
                font.pixelSize: 12
                color: (popupLoader.item && popupLoader.item.visible)
                    ? stateEngine.accentColor
                    : (bar ? bar.foreground : "#EDEDED")
            }

            // Compact Remaining Badge
            Text {
                visible: root.showBadge
                text: stateEngine.countdownData.isExpired
                    ? "done"
                    : (stateEngine.countdownData.days + "d " + stateEngine.countdownData.hours + "h")
                color: (popupLoader.item && popupLoader.item.visible)
                    ? stateEngine.accentColor
                    : (bar ? bar.foreground : "#EDEDED")
                font.family: bar ? bar.fontFamily : "monospace"
                font.weight: Font.Bold
                font.pixelSize: 11
                opacity: 0.92
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onEntered: {
                if (bar && typeof bar.showTooltip === "function") {
                    bar.showTooltip(root, root.tooltipString);
                }
            }
            onExited: {
                if (bar && typeof bar.hideTooltip === "function") {
                    bar.hideTooltip(root);
                }
            }
            onClicked: {
                root.toggle();
            }
        }
    }

    // Popout Manager & Loader
    Loader {
        id: popupLoader
        active: true
        source: Qt.resolvedUrl("TickingPopupWindow.qml")
        onLoaded: {
            if (item) {
                item.stateEngine = stateEngine;
                item.bar = root.bar;
                item.anchorItem = pillContainer;
                item.hostWidget = root;
            }
        }
    }

    function open() {
        injectPopup();
        if (bar && typeof bar.requestPopout === "function") {
            bar.requestPopout(root);
        }
        stateEngine.isPopupOpen = true;
        if (typeof stateEngine.onPopupOpened === "function") {
            stateEngine.onPopupOpened();
        }
        if (popupLoader.item) {
            popupLoader.item.showPopup();
        }
    }

    function close() {
        if (popupLoader.item) {
            popupLoader.item.hidePopup();
        }
        stateEngine.isPopupOpen = false;
        if (bar && typeof bar.releasePopout === "function") {
            bar.releasePopout(root);
        }
    }

    function closeForPopoutSwitch() {
        if (popupLoader.item) {
            popupLoader.item.hidePopup();
        }
        stateEngine.isPopupOpen = false;
    }

    function toggle() {
        if (popupLoader.item && popupLoader.item.isOpen) {
            root.close();
        } else {
            root.open();
        }
    }

    function onPopupClosed() {
        stateEngine.isPopupOpen = false;
        if (bar && typeof bar.releasePopout === "function") {
            bar.releasePopout(root);
        }
    }
}
