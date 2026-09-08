import QtQuick
import QtQuick.Layouts

Item {
    id: settingsRoot

    property var stateEngine: null
    property color accentColor: stateEngine ? stateEngine.accentColor : "#00E599"
    property var themeColors: stateEngine ? stateEngine.themeColors : null
    property string dateError: ""

    signal closeSettingsRequested()

    implicitWidth: 356
    implicitHeight: 280
    Layout.fillWidth: true

    readonly property var colors: themeColors || ({
        subCardBg: Qt.rgba(0.06, 0.06, 0.06, 0.88),
        subCardHover: Qt.rgba(0.12, 0.12, 0.12, 0.96),
        cardBorder: Qt.rgba(1, 1, 1, 0.09),
        cardBorderHover: Qt.rgba(1, 1, 1, 0.18),
        specularGlint: Qt.rgba(1, 1, 1, 0.45),
        textPrimary: "#EDEDED",
        textSecondary: "#A1A1AA",
        textMuted: "#71717A",
        buttonBg: Qt.rgba(1, 1, 1, 0.08),
        buttonBgHover: Qt.rgba(1, 1, 1, 0.14),
        buttonFg: "#EDEDED",
        onAccentFg: "#0A0A0A"
    })

    function formatDate(d) {
        if (!d || isNaN(d.getTime())) return "";
        var y = d.getFullYear();
        var m = d.getMonth() + 1;
        var day = d.getDate();
        return y + "-" + (m < 10 ? "0" + m : "" + m) + "-" + (day < 10 ? "0" + day : "" + day);
    }

    function isColorMatch(c1, hex2) {
        if (!c1 || !hex2) return false;
        var s1 = c1.toString().toLowerCase();
        var s2 = hex2.toLowerCase();
        if (s1 === s2) return true;
        if (s1.replace("#ff", "#") === s2) return true;
        if (s1 === s2.replace("#", "#ff")) return true;
        return false;
    }

    function syncFieldsFromState() {
        if (!stateEngine) return;
        titleField.text = stateEngine.customTitle || "NEW HORIZON";
        if (stateEngine.targetTimestamp && stateEngine.targetTimestamp.trim() !== "") {
            targetDateField.text = stateEngine.targetTimestamp;
        } else {
            var defaultTarget = stateEngine.defaultTargetDate();
            targetDateField.text = formatDate(defaultTarget);
        }
        dateError = "";
    }

    function applyManualSettings() {
        if (!stateEngine) return true;
        var rawTitle = titleField.text.trim();
        if (rawTitle.length > 0) {
            stateEngine.customTitle = rawTitle;
        }

        var rawDate = targetDateField.text.trim();
        if (rawDate.length > 0) {
            var parsed = stateEngine.parseHorizonDate(rawDate);
            if (parsed) {
                var formatted = formatDate(parsed);
                stateEngine.targetTimestamp = formatted;
                targetDateField.text = formatted;
                dateError = "";
            } else {
                dateError = "Invalid date. Format: YYYY-MM-DD";
                return false;
            }
        } else {
            stateEngine.targetTimestamp = "";
            dateError = "";
        }

        stateEngine.updateAllMetrics();
        stateEngine.persistConfig();
        return true;
    }

    function applyPresetTarget(dateStr) {
        dateError = "";
        if (!stateEngine) return;
        stateEngine.targetTimestamp = dateStr;
        var rawTitle = titleField.text.trim();
        if (rawTitle.length > 0) {
            stateEngine.customTitle = rawTitle;
        }
        stateEngine.updateAllMetrics();
        stateEngine.persistConfig();
    }

    onVisibleChanged: {
        if (visible) syncFieldsFromState();
    }

    onStateEngineChanged: syncFieldsFromState()

    Component.onCompleted: syncFieldsFromState()

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.rightMargin: 8
        contentWidth: width
        contentHeight: contentCol.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: contentCol
            width: flickable.width
            spacing: 8

            // 1. Milestone Configuration Card
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: milestoneCol.implicitHeight + 16
                radius: 8
                color: settingsRoot.colors.subCardBg
                border.width: 1
                border.color: settingsRoot.colors.cardBorder

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
                        GradientStop { position: 0.5; color: settingsRoot.colors.specularGlint }
                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.04) }
                    }
                }

                ColumnLayout {
                    id: milestoneCol
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    RowLayout {
                        spacing: 6
                        Rectangle {
                            width: 3
                            height: 10
                            radius: 1.5
                            color: settingsRoot.accentColor
                        }
                        Text {
                            text: "MILESTONE CONFIGURATION"
                            color: settingsRoot.colors.textSecondary
                            font.family: "sans-serif"
                            font.weight: Font.Bold
                            font.pixelSize: 9
                            font.letterSpacing: 1.1
                        }
                    }

                    // Milestone Title
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            text: "MILESTONE TITLE"
                            color: settingsRoot.colors.textMuted
                            font.family: "sans-serif"
                            font.weight: Font.DemiBold
                            font.pixelSize: 9
                            font.letterSpacing: 1.0
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 28
                            radius: 6
                            color: titleField.activeFocus ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.04)
                            border.width: 1
                            border.color: titleField.activeFocus ? settingsRoot.accentColor : settingsRoot.colors.cardBorder

                            TextInput {
                                id: titleField
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                verticalAlignment: TextInput.AlignVCenter
                                color: settingsRoot.colors.textPrimary
                                font.family: "sans-serif"
                                font.weight: Font.Medium
                                font.pixelSize: 11
                                selectByMouse: true
                                clip: true
                                onAccepted: {
                                    if (settingsRoot.applyManualSettings()) settingsRoot.closeSettingsRequested();
                                }
                            }
                        }
                    }

                    // Target Date
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            text: "TARGET DATE (YYYY-MM-DD)"
                            color: settingsRoot.colors.textMuted
                            font.family: "sans-serif"
                            font.weight: Font.DemiBold
                            font.pixelSize: 9
                            font.letterSpacing: 1.0
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 28
                            radius: 6
                            color: targetDateField.activeFocus ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.04)
                            border.width: 1
                            border.color: targetDateField.activeFocus ? settingsRoot.accentColor : settingsRoot.colors.cardBorder

                            TextInput {
                                id: targetDateField
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                verticalAlignment: TextInput.AlignVCenter
                                color: settingsRoot.colors.textPrimary
                                font.family: "monospace"
                                font.weight: Font.Medium
                                font.pixelSize: 11
                                selectByMouse: true
                                clip: true
                                onAccepted: {
                                    if (settingsRoot.applyManualSettings()) settingsRoot.closeSettingsRequested();
                                }
                            }
                        }

                        Text {
                            visible: settingsRoot.dateError !== ""
                            text: settingsRoot.dateError
                            color: "#F43F5E"
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }
                    }

                    // Quick presets
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: [
                                { label: "+30d", days: 30 },
                                { label: "+90d", days: 90 },
                                { label: "Year End", isYearEnd: true }
                            ]

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 24
                                radius: 4
                                color: presetMouse.containsMouse ? settingsRoot.colors.buttonBgHover : settingsRoot.colors.buttonBg
                                border.width: 1
                                border.color: settingsRoot.colors.cardBorder

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    color: presetMouse.containsMouse ? settingsRoot.colors.textPrimary : settingsRoot.colors.textSecondary
                                    font.family: "sans-serif"
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                }

                                MouseArea {
                                    id: presetMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        var targetDate;
                                        if (modelData.isYearEnd) {
                                            targetDate = settingsRoot.stateEngine ? settingsRoot.stateEngine.defaultTargetDate() : new Date(new Date().getFullYear(), 11, 31, 23, 59, 59);
                                        } else {
                                            targetDate = new Date(Date.now() + modelData.days * 86400000);
                                        }
                                        var dateStr = settingsRoot.formatDate(targetDate);
                                        targetDateField.text = dateStr;
                                        settingsRoot.applyPresetTarget(dateStr);
                                    }
                                }
                            }
                        }
                    }

                    // Journey Baseline
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 38
                        radius: 6
                        color: Qt.rgba(1, 1, 1, 0.03)
                        border.width: 1
                        border.color: settingsRoot.colors.cardBorder

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: "JOURNEY BASELINE"
                                    color: settingsRoot.colors.textSecondary
                                    font.family: "sans-serif"
                                    font.weight: Font.DemiBold
                                    font.pixelSize: 9
                                    font.letterSpacing: 1.0
                                }

                                Text {
                                    text: (settingsRoot.stateEngine && settingsRoot.stateEngine.startTimestamp && settingsRoot.stateEngine.startTimestamp.trim() !== "")
                                        ? settingsRoot.stateEngine.startTimestamp
                                        : "Default (Jan 1 of this year)"
                                    color: settingsRoot.colors.textMuted
                                    font.family: "monospace"
                                    font.pixelSize: 10
                                }
                            }

                            Rectangle {
                                implicitWidth: 126
                                implicitHeight: 24
                                radius: 4
                                color: baselineMouse.containsMouse ? settingsRoot.colors.buttonBgHover : settingsRoot.colors.buttonBg
                                border.width: 1
                                border.color: settingsRoot.colors.cardBorder

                                Text {
                                    anchors.centerIn: parent
                                    text: "Set Baseline to Today"
                                    color: baselineMouse.containsMouse ? settingsRoot.colors.textPrimary : settingsRoot.colors.textSecondary
                                    font.family: "sans-serif"
                                    font.pixelSize: 10
                                    font.weight: Font.Medium
                                }

                                MouseArea {
                                    id: baselineMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (settingsRoot.stateEngine) {
                                            settingsRoot.stateEngine.resetBaselineToNow();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 2. Display Toggles Card
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: togglesCol.implicitHeight + 16
                radius: 8
                color: settingsRoot.colors.subCardBg
                border.width: 1
                border.color: settingsRoot.colors.cardBorder

                ColumnLayout {
                    id: togglesCol
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    RowLayout {
                        spacing: 6
                        Rectangle {
                            width: 3
                            height: 10
                            radius: 1.5
                            color: settingsRoot.accentColor
                        }
                        Text {
                            text: "DISPLAY TOGGLES"
                            color: settingsRoot.colors.textSecondary
                            font.family: "sans-serif"
                            font.weight: Font.Bold
                            font.pixelSize: 9
                            font.letterSpacing: 1.1
                        }
                    }

                    Repeater {
                        model: [
                            { key: "showMilliseconds", label: "Show Centiseconds", sub: "Sub-second precision in countdown" },
                            { key: "showProgress", label: "Show Progress Bar", sub: "Visual journey progress track" },
                            { key: "showPanelBadge", label: "Show Bar Badge", sub: "Countdown badge on taskbar face" },
                            { key: "showQuoteBar", label: "Show Quote Bar", sub: "Motivational quotes capsule" },
                            { key: "hourFormat24", label: "24-Hour Format", sub: "24h military vs 12h clock" }
                        ]

                        Rectangle {
                            id: toggleRow
                            Layout.fillWidth: true
                            implicitHeight: 30
                            radius: 6
                            color: rowMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"

                            readonly property bool isChecked: settingsRoot.stateEngine ? !!settingsRoot.stateEngine[modelData.key] : false

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 6
                                anchors.rightMargin: 6
                                spacing: 8

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        text: modelData.label
                                        color: settingsRoot.colors.textPrimary
                                        font.family: "sans-serif"
                                        font.weight: Font.Medium
                                        font.pixelSize: 11
                                    }

                                    Text {
                                        text: modelData.sub
                                        color: settingsRoot.colors.textMuted
                                        font.pixelSize: 9
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 30
                                    Layout.preferredHeight: 16
                                    radius: 8
                                    color: toggleRow.isChecked ? settingsRoot.accentColor : Qt.rgba(1, 1, 1, 0.15)

                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    Rectangle {
                                        width: 12
                                        height: 12
                                        radius: 6
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: toggleRow.isChecked ? 16 : 2
                                        color: toggleRow.isChecked ? settingsRoot.colors.onAccentFg : "#EDEDED"

                                        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                                    }
                                }
                            }

                            MouseArea {
                                id: rowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (settingsRoot.stateEngine) {
                                        settingsRoot.stateEngine[modelData.key] = !settingsRoot.stateEngine[modelData.key];
                                        settingsRoot.stateEngine.updateAllMetrics();
                                        settingsRoot.stateEngine.persistConfig();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 3. Accent Color Swatches Card
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: swatchCol.implicitHeight + 16
                radius: 8
                color: settingsRoot.colors.subCardBg
                border.width: 1
                border.color: settingsRoot.colors.cardBorder

                ColumnLayout {
                    id: swatchCol
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    RowLayout {
                        spacing: 6
                        Rectangle {
                            width: 3
                            height: 10
                            radius: 1.5
                            color: settingsRoot.accentColor
                        }
                        Text {
                            text: "ACCENT COLOR"
                            color: settingsRoot.colors.textSecondary
                            font.family: "sans-serif"
                            font.weight: Font.Bold
                            font.pixelSize: 9
                            font.letterSpacing: 1.1
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: [
                                { name: "Emerald", hex: "#00E599" },
                                { name: "Sky", hex: "#38BDF8" },
                                { name: "Purple", hex: "#A855F7" },
                                { name: "Amber", hex: "#F59E0B" },
                                { name: "Rose", hex: "#F43F5E" },
                                { name: "White", hex: "#EDEDED" }
                            ]

                            Rectangle {
                                id: swatchRect
                                Layout.fillWidth: true
                                implicitHeight: 26
                                radius: 5
                                color: modelData.hex

                                readonly property bool isSelected: settingsRoot.isColorMatch(settingsRoot.stateEngine ? settingsRoot.stateEngine.accentColor : "", modelData.hex)

                                border.width: isSelected ? 2 : 1
                                border.color: isSelected ? "#FFFFFF" : Qt.rgba(0, 0, 0, 0.3)

                                Text {
                                    anchors.centerIn: parent
                                    visible: swatchRect.isSelected
                                    text: "✓"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: (modelData.hex === "#EDEDED" || modelData.hex === "#00E599") ? "#0A0A0A" : "#FFFFFF"
                                }

                                MouseArea {
                                    id: swatchMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (settingsRoot.stateEngine) {
                                            settingsRoot.stateEngine.accentColor = modelData.hex;
                                            settingsRoot.stateEngine.updateAllMetrics();
                                            settingsRoot.stateEngine.persistConfig();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 4. Action Buttons (Back / Save & Apply)
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 80
                    implicitHeight: 30
                    radius: 6
                    color: backMouse.containsMouse ? settingsRoot.colors.buttonBgHover : settingsRoot.colors.buttonBg
                    border.width: 1
                    border.color: settingsRoot.colors.cardBorder

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            text: "←"
                            color: settingsRoot.colors.textSecondary
                            font.pixelSize: 11
                        }
                        Text {
                            text: "BACK"
                            color: settingsRoot.colors.textSecondary
                            font.family: "sans-serif"
                            font.weight: Font.DemiBold
                            font.pixelSize: 10
                            font.letterSpacing: 1.0
                        }
                    }

                    MouseArea {
                        id: backMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: settingsRoot.closeSettingsRequested()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 30
                    radius: 6
                    color: saveMouse.containsMouse
                        ? Qt.rgba(settingsRoot.accentColor.r, settingsRoot.accentColor.g, settingsRoot.accentColor.b, 0.95)
                        : Qt.rgba(settingsRoot.accentColor.r, settingsRoot.accentColor.g, settingsRoot.accentColor.b, 0.82)

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "✓"
                            color: settingsRoot.colors.onAccentFg
                            font.pixelSize: 11
                            font.bold: true
                        }
                        Text {
                            text: "SAVE & APPLY"
                            color: settingsRoot.colors.onAccentFg
                            font.family: "sans-serif"
                            font.weight: Font.Bold
                            font.pixelSize: 10
                            font.letterSpacing: 1.1
                        }
                    }

                    MouseArea {
                        id: saveMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (settingsRoot.applyManualSettings()) {
                                settingsRoot.closeSettingsRequested();
                            }
                        }
                    }
                }
            }
        }
    }

    // Scrollbar Indicator
    Rectangle {
        id: scrollTrack
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 2
        width: 3
        radius: 1.5
        color: Qt.rgba(1, 1, 1, 0.05)
        visible: flickable.contentHeight > flickable.height

        Rectangle {
            id: scrollThumb
            width: parent.width
            height: Math.max(16, flickable.visibleArea.heightRatio * parent.height)
            y: flickable.visibleArea.yPosition * parent.height
            radius: 1.5
            color: Qt.rgba(1, 1, 1, 0.25)
        }
    }
}
