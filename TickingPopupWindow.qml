import QtQuick
import Quickshell
import qs.Ui

KeyboardPanel {
    id: popWindow

    property var stateEngine: null
    property var hostWidget: null
    property bool isOpen: false

    anchorItem: hostWidget ? hostWidget.pillContainerItem : null
    bar: hostWidget ? hostWidget.bar : null
    owner: hostWidget

    open: isOpen
    padding: 0
    margin: 6
    contentWidth: popupContent.implicitWidth || 380
    contentHeight: popupContent.implicitHeight || 280

    TickingPopup {
        id: popupContent
        anchors.fill: parent
        stateEngine: popWindow.stateEngine
        bar: popWindow.bar
        opened: popWindow.isOpen
        onCloseRequested: popWindow.hidePopup()
    }

    function showPopup() {
        isOpen = true;
    }

    function hidePopup() {
        isOpen = false;
        if (hostWidget && typeof hostWidget.onPopupClosed === "function") {
            hostWidget.onPopupClosed();
        }
    }

    function togglePopup() {
        if (isOpen) hidePopup();
        else showPopup();
    }
}
