import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.widgets

MouseArea {
    id: root
    implicitWidth: vpnRow.implicitWidth + 10 * 2
    implicitHeight: Appearance.sizes.barHeight
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    property string vpnStatus: ""
    property string vpnServer: ""
    property string vpnLoad: ""
    property string vpnProtocol: ""
    property bool connected: vpnStatus.toLowerCase() === "connected"
    property bool loading: false

    Process {
        id: statusProcess
        command: ["bash", "-c", "protonvpn status 2>/dev/null"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (line.startsWith("Status:"))   root.vpnStatus   = line.split(":")[1].trim()
                if (line.startsWith("Server:"))   root.vpnServer   = line.substring(7).trim()
                if (line.startsWith("Load:"))     root.vpnLoad     = line.split(":")[1].trim()
                if (line.startsWith("Protocol:")) root.vpnProtocol = line.split(":")[1].trim()
            }
        }
        onRunningChanged: {
            if (!running) root.loading = false
        }
    }

    Timer {
        interval: 10000
        repeat: true
        running: true
        onTriggered: statusProcess.running = true
    }

    Process {
        id: toggleProcess
        command: root.connected
            ? ["protonvpn", "disconnect"]
            : ["protonvpn", "connect"]
        onRunningChanged: {
            if (!running) {
                root.loading = false
                statusProcess.running = true
            }
        }
    }

    onClicked: {
        if (root.loading) return
        root.loading = true
        toggleProcess.running = true
    }

    RowLayout {
        id: vpnRow
        anchors.centerIn: parent
        spacing: 4

        MaterialSymbol {
            text: root.loading ? "sync" : root.connected ? "vpn_key" : "vpn_key_off"
            iconSize: Appearance.font.pixelSize.larger
            color: root.loading
                ? Appearance.colors.colOnLayer0
                : root.connected
                    ? Appearance.colors.colPrimary
                    : Appearance.colors.colOnLayer0

            RotationAnimation on rotation {
                running: root.loading
                from: 0; to: 360
                duration: 1000
                loops: Animation.Infinite
            }
        }

        StyledText {
            text: ""
            color: Appearance.colors.colOnLayer0
            font.pixelSize: Appearance.font.pixelSize.small
        }
    }

    StyledPopup {
        id: vpnPopup
        hoverTarget: root

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 4
            StyledPopupHeaderRow {
                icon: "vpn_lock"
                label: "Proton VPN"
            }
            StyledPopupValueRow {
              icon: "circle"
              label: "status"
              value: root.vpnStatus
            }
            StyledPopupValueRow {
                icon: "dns"
                label: "Server:"
                value: root.vpnServer
            }
            StyledPopupValueRow {
                icon: "speed"
                label: "Load:"
                value: root.vpnLoad
            }
            StyledPopupValueRow {
                icon: "lock"
                label: "Protocol:"
                value: root.vpnProtocol
            }
        }
    }
}
