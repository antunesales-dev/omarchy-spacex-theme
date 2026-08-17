// SpaceX pad lock: letterbox + telemetry over the theme wallpaper.
import QtQuick
import qs.Commons
import "../plugins/io.github.sirjul1337.lock-explorer/designs"

DesignBase {
  id: lock
  inputItem: field.input

  readonly property int barH: Math.round(height * 0.16)
  readonly property int pad: Math.round(Math.min(width, height) * 0.04)
  readonly property color steel: "#C4C8CC"
  readonly property color ink: "#F5F5F5"
  readonly property color dim: "#8A8A8A"

  Wallpaper {
    anchors.fill: parent
    lock: lock
    blur: 0.15
    dim: 0.22
    vignette: true
    vignetteTop: 0.45
    vignetteBottom: 0.55
  }

  Canvas {
    anchors.fill: parent
    opacity: 0.08
    onPaint: {
      var ctx = getContext("2d")
      ctx.clearRect(0, 0, width, height)
      ctx.fillStyle = "#000000"
      for (var y = 0; y < height; y += 3)
        ctx.fillRect(0, y, width, 1)
    }
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onClicked: { lock.wakeRequested(); lock.forcePasswordFocus() }
    onPositionChanged: lock.wakeRequested()
  }

  Rectangle {
    id: topBar
    anchors.top: parent.top
    width: parent.width
    height: lock.barH
    color: "#000000"

    Column {
      anchors.left: parent.left
      anchors.leftMargin: lock.pad
      anchors.verticalCenter: parent.verticalCenter
      spacing: 2
      Text {
        text: "T+" + Qt.formatTime(lock.now, "HH:mm:ss")
        color: lock.steel
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        font.letterSpacing: 3
      }
      Text {
        text: Qt.formatTime(lock.now, "HH:mm")
        color: lock.ink
        font.family: Style.font.family
        font.pixelSize: Style.font.displayLarge
        font.weight: Font.DemiBold
      }
    }

    Column {
      anchors.right: parent.right
      anchors.rightMargin: lock.pad
      anchors.verticalCenter: parent.verticalCenter
      spacing: 4
      Text {
        anchors.right: parent.right
        text: lock.hostName.toUpperCase()
        color: lock.steel
        font.family: Style.font.family
        font.pixelSize: Style.font.subtitle
        font.letterSpacing: 6
      }
      Text {
        anchors.right: parent.right
        text: Qt.formatDate(lock.now, "ddd d MMM yyyy").toUpperCase()
        color: lock.dim
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        font.letterSpacing: 3
      }
    }
  }

  Rectangle {
    anchors.top: topBar.bottom
    width: parent.width
    height: 1
    color: lock.steel
    opacity: 0.35
  }

  Rectangle {
    id: bottomBar
    anchors.bottom: parent.bottom
    width: parent.width
    height: lock.barH
    color: "#000000"

    Rectangle {
      anchors.top: parent.top
      width: parent.width
      height: 1
      color: lock.steel
      opacity: 0.35
    }

    Column {
      anchors.centerIn: parent
      spacing: 10
      width: Math.min(parent.width - lock.pad * 2, 480)

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: lock.errorState ? "NO-GO  ·  " + (lock.failureMessage || "AUTH FAIL")
          : (lock.authenticatingPassword ? "HOLD  ·  CHECKING"
          : "GO  ·  " + lock.greeting().toUpperCase() + "  ·  " + lock.userName.toUpperCase())
        color: lock.errorState ? Color.lock.textError : lock.steel
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        font.letterSpacing: 3
      }

      PasswordField {
        id: field
        lock: lock
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: 42
        radius: 2
        outlineThickness: 1
        showLockGlyph: false
        color: "#0A0A0A"
        placeholder: "PASSWORD"
      }
    }
  }
}
