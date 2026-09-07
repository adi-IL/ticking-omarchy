import QtQuick
import Quickshell

PopupWindow {
    id: popWindow

    property var stateEngine: null
    property var bar: null
    property var anchorItem: null
    property var hostWidget: null

    anchor.window: anchorItem && anchorItem.Window ? anchorItem.Window.window : null
    anchor.item: anchorItem
    anchor.edges: (bar && bar.position === "bottom") ? Edges.Top : Edges.Bottom
    anchor.gravity: (bar && bar.position === "bottom") ? Edges.Top : Edges.Bottom

    visible: false
    width: popupContent.width
    height: popupContent.height

    TickingPopup {
        id: popupContent
        stateEngine: popWindow.stateEngine
        bar: popWindow.bar
        opened: popWindow.visible
        onCloseRequested: popWindow.close()
    }

    function open() {
        visible = true;
    }

    function close() {
        visible = false;
        if (hostWidget && typeof hostWidget.onPopupClosed === "function") {
            hostWidget.onPopupClosed();
        }
    }

    function toggle() {
        if (visible) close();
        else open();
    }
}
