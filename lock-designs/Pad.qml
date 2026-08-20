// SpaceX pad lock: Cinema letterbox + mission-elapsed clock.
import QtQuick
import qs.Commons
import "../plugins/io.github.sirjul1337.lock-explorer/designs"

DesignBase {
  id: lock
  inputItem: field.input

  readonly property int barH: Math.round(height * 0.10)
  readonly property int pad: 48
  readonly property color steel: "#FFFFFF"
  readonly property color ink: "#FFFFFF"
  readonly property color dim: "#FFFFFF"

  Wallpaper {
    anchors.fill: parent
    lock: lock
    blur: 0.0
    dim: 0.0
    vignette: false
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
    opacity: 1
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
      opacity: 1
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
        color: "#000000"
        placeholder: "PASSWORD"
      }
    }
  }
}
