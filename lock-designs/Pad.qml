// SpaceX pad lock: Cinema letterbox + mission-elapsed clock.
import QtQuick
import qs.Commons
import "../plugins/io.github.sirjul1337.lock-explorer/designs"

DesignBase {
  id: lock
  inputItem: field.input

  readonly property int barH: Math.round(height * 0.13)
  readonly property int pad: 36
  readonly property color steel: "#C4C8CC"
  readonly property color ink: "#F5F5F5"
  readonly property color dim: "#8A8A8A"

  Wallpaper {
    anchors.fill: parent
    lock: lock
    blur: 0.0
    dim: 0.08
    vignette: false
  }

  Canvas {
    anchors.fill: parent
    opacity: 0.05
    onPaint: {
      var ctx = getContext("2d")
      ctx.clearRect(0, 0, width, height)
      ctx.fillStyle = "#000000"
      for (var y = 0; y < height; y += 4)
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

    Row {
      anchors.left: parent.left
      anchors.leftMargin: lock.pad
      anchors.verticalCenter: parent.verticalCenter
      spacing: 18

      Text {
        text: Qt.formatTime(lock.now, "HH:mm")
        color: lock.ink
        font.family: Style.font.family
        font.pixelSize: Style.font.displayLarge
        font.weight: Font.DemiBold
      }
      Column {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2
        Text {
          text: "T+" + Qt.formatTime(lock.now, "HH:mm:ss")
          color: lock.steel
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          font.letterSpacing: 2
        }
        Text {
          text: "MET"
          color: lock.dim
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          font.letterSpacing: 3
        }
      }
    }

    Column {
      anchors.right: parent.right
      anchors.rightMargin: lock.pad
      anchors.verticalCenter: parent.verticalCenter
      spacing: 3
      Text {
        anchors.right: parent.right
        text: lock.hostName.toUpperCase()
        color: lock.steel
        font.family: Style.font.family
        font.pixelSize: Style.font.subtitle
        font.letterSpacing: 5
      }
      Text {
        anchors.right: parent.right
        text: Qt.formatDate(lock.now, "dddd d MMMM yyyy").toUpperCase()
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
    opacity: 0.4
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
      opacity: 0.4
    }

    Row {
      anchors.left: parent.left
      anchors.leftMargin: lock.pad
      anchors.verticalCenter: parent.verticalCenter
      spacing: 10
      Rectangle {
        width: 8
        height: 8
        radius: 0
        anchors.verticalCenter: parent.verticalCenter
        color: lock.errorState ? Color.lock.textError : lock.steel
      }
      Text {
        text: lock.errorState ? "NO-GO"
          : (lock.authenticatingPassword ? "HOLD" : "GO")
        color: lock.errorState ? Color.lock.textError : lock.steel
        font.family: Style.font.family
        font.pixelSize: Style.font.subtitle
        font.letterSpacing: 4
        font.weight: Font.DemiBold
      }
    }

    Column {
      anchors.centerIn: parent
      spacing: 8

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: lock.errorState ? (lock.failureMessage || "AUTH FAIL")
          : (lock.authenticatingPassword ? "CHECKING CREDENTIALS"
          : lock.greeting() + ", " + lock.userName + ".")
        color: lock.errorState ? Color.lock.textError : lock.ink
        font.family: Style.font.family
        font.pixelSize: Style.font.heading
      }

      PasswordField {
        id: field
        lock: lock
        anchors.horizontalCenter: parent.horizontalCenter
        width: 400
        height: 40
        radius: 0
        outlineThickness: 1
        showLockGlyph: false
        color: "#0A0A0A"
        placeholder: "PASSWORD"
      }
    }
  }
}
