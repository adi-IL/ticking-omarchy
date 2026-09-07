import QtQuick
import QtQuick.Layouts

Rectangle {
    id: quoteBarRoot

    property string quoteText: ""
    property string quoteAuthor: ""
    property bool isLoading: false
    property color accentColor: "#00E599"
    property var themeColors: ({
        subCardBg: Qt.rgba(0.06, 0.06, 0.06, 0.88),
        subCardHover: Qt.rgba(0.12, 0.12, 0.12, 0.96),
        cardBorder: Qt.rgba(1, 1, 1, 0.09),
        cardBorderHover: Qt.rgba(1, 1, 1, 0.18),
        specularGlint: Qt.rgba(1, 1, 1, 0.25),
        textPrimary: "#EDEDED",
        textMuted: "#71717A"
    })

    signal refreshRequested()
    signal copyRequested(string text)

    property bool isCopied: false

    Timer {
        id: copiedResetTimer
        interval: 1600
        repeat: false
        onTriggered: quoteBarRoot.isCopied = false
    }

    TextInput {
        id: clipboardHelper
        visible: false
    }

    readonly property int charCount: (quoteText || "").trim().length
    readonly property int wordCount: quoteText.trim().length > 0 ? quoteText.trim().split(/\s+/).length : 0

    // Adaptive typography: scale font size according to length
    readonly property real adaptiveQuoteFontSize: {
        var base = 12;
        if (charCount > 115 || wordCount > 22) {
            return Math.max(10, base - 2);
        } else if (charCount > 75 || wordCount > 14) {
            return Math.max(10.5, base - 1);
        } else if (charCount < 36 && wordCount <= 6) {
            return base + 1;
        }
        return base;
    }

    // Adaptive line limits
    readonly property int adaptiveMaxLines: {
        if (charCount > 110) return 4;
        if (charCount > 60) return 3;
        return 2;
    }

    // Adaptive vertical padding
    readonly property real adaptiveVSpacing: {
        if (charCount > 90) return 5;
        if (charCount < 40) return 3;
        return 4;
    }

    readonly property real fallbackHeight: {
        var lines = (charCount > 110) ? 4 : ((charCount > 60) ? 3 : ((charCount > 30) ? 2 : 1));
        var fontH = Math.round(adaptiveQuoteFontSize * 1.32);
        var textH = lines * fontH;
        var authH = quoteAuthor.length > 0 ? 15 : 0;
        return textH + authH;
    }

    readonly property real contentCalculatedHeight: {
        var textH = Math.ceil(quoteLabel.paintedHeight);
        var authH = authorLabel.visible ? Math.ceil(authorLabel.paintedHeight + textColumn.spacing) : 0;
        var iconsH = 18;
        var innerH = (textH > 0) ? Math.max(textH + authH, iconsH) : fallbackHeight;
        return innerH + Math.round(adaptiveVSpacing * 2);
    }

    Layout.fillWidth: true
    Layout.minimumHeight: 34
    Layout.maximumHeight: 96
    Layout.preferredHeight: Math.max(Layout.minimumHeight, Math.min(Layout.maximumHeight, contentCalculatedHeight))

    Behavior on Layout.preferredHeight {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    radius: 10
    color: capsuleMouse.containsMouse ? quoteBarRoot.themeColors.subCardHover : quoteBarRoot.themeColors.subCardBg
    border.width: 1
    border.color: capsuleMouse.containsMouse ? quoteBarRoot.themeColors.cardBorderHover : quoteBarRoot.themeColors.cardBorder

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    MouseArea {
        id: capsuleMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: quoteBarRoot.refreshRequested()
    }

    // Top edge highlight line
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
            GradientStop { position: 0.5; color: capsuleMouse.containsMouse ? quoteBarRoot.themeColors.specularGlint : Qt.rgba(1, 1, 1, 0.12) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.04) }
        }
    }

    RowLayout {
        id: contentRow
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 8
        anchors.topMargin: Math.round(quoteBarRoot.adaptiveVSpacing)
        anchors.bottomMargin: Math.round(quoteBarRoot.adaptiveVSpacing)
        spacing: 6

        ColumnLayout {
            id: textColumn
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: authorLabel.visible ? 2 : 0

            Text {
                id: quoteLabel
                Layout.fillWidth: true
                textFormat: Text.PlainText
                text: quoteBarRoot.quoteText.length > 0
                    ? ("\"" + quoteBarRoot.quoteText + "\"")
                    : "Focus on the horizon ahead."
                color: quoteBarRoot.themeColors.textPrimary
                font.family: "sans-serif"
                font.pixelSize: quoteBarRoot.adaptiveQuoteFontSize
                font.italic: true
                lineHeight: 1.22
                wrapMode: Text.WordWrap
                maximumLineCount: quoteBarRoot.adaptiveMaxLines
                elide: Text.ElideRight

                Behavior on font.pixelSize {
                    NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                }
            }

            Text {
                id: authorLabel
                visible: quoteBarRoot.quoteAuthor.length > 0
                Layout.fillWidth: true
                textFormat: Text.PlainText
                text: quoteBarRoot.quoteAuthor.length > 0 ? ("- " + quoteBarRoot.quoteAuthor) : ""
                color: quoteBarRoot.accentColor
                font.family: "sans-serif"
                font.pixelSize: 10
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }

        // Copy button
        Rectangle {
            id: copyBtn
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            Layout.alignment: Qt.AlignVCenter
            radius: 4
            color: copyMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

            Text {
                anchors.centerIn: parent
                text: quoteBarRoot.isCopied ? "✓" : "⎘"
                color: quoteBarRoot.isCopied
                    ? quoteBarRoot.accentColor
                    : (copyMouse.containsMouse ? quoteBarRoot.themeColors.textPrimary : quoteBarRoot.themeColors.textMuted)
                font.pixelSize: quoteBarRoot.isCopied ? 12 : 14
            }

            MouseArea {
                id: copyMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var full = quoteBarRoot.quoteText;
                    if (quoteBarRoot.quoteAuthor.length > 0) {
                        full = full + " - " + quoteBarRoot.quoteAuthor;
                    }
                    clipboardHelper.text = full;
                    clipboardHelper.selectAll();
                    clipboardHelper.copy();
                    quoteBarRoot.copyRequested(full);
                    quoteBarRoot.isCopied = true;
                    copiedResetTimer.restart();
                }
            }
        }

        // Refresh button
        Rectangle {
            id: refreshBtn
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            Layout.alignment: Qt.AlignVCenter
            radius: 4
            color: refreshMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

            Text {
                id: refreshGlyph
                anchors.centerIn: parent
                text: "↻"
                color: refreshMouse.containsMouse ? quoteBarRoot.themeColors.textPrimary : quoteBarRoot.themeColors.textMuted
                font.pixelSize: 14

                RotationAnimation on rotation {
                    running: quoteBarRoot.isLoading
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 900
                }
            }

            MouseArea {
                id: refreshMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: quoteBarRoot.refreshRequested()
            }
        }
    }
}
