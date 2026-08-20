// SpaceX cinema lock: full-bleed wallpaper, letterbox, steel type.
import QtQuick
import qs.Commons
import "../plugins/io.github.sirjul1337.lock-explorer/designs"

DesignBase {
  id: lock
  inputItem: field.input

  readonly property int barHeight: Math.round(height * 0.10)
  readonly property int pad: 48
  readonly property color steel: "#FFFFFF"
  readonly property color ink: "#FFFFFF"

  Wallpaper { anchors.fill: parent; lock: lock; blur: 0.0; dim: 0.0; vignette: false }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onClicked: { lock.wakeRequested(); lock.forcePasswordFocus() }
    onPositionChanged: lock.wakeRequested()
  }

  Rectangle {
    anchors.top: parent.top
    width: parent.width
    height: lock.barHeight
    color: "#000000"

    Text {
      anchors.left: parent.left
      anchors.leftMargin: lock.pad
      anchors.verticalCenter: parent.verticalCenter
      text: Qt.formatTime(lock.now, "HH:mm")
      color: lock.ink
      font.family: Style.font.family
      font.pixelSize: Style.font.displayLarge
      font.weight: Font.DemiBold
    }
    Text {
      anchors.right: parent.right
      anchors.rightMargin: lock.pad
      anchors.verticalCenter: parent.verticalCenter
      text: Qt.formatDate(lock.now, "dddd d MMMM yyyy").toUpperCase()
      color: lock.steel
      font.family: Style.font.family
      font.pixelSize: Style.font.subtitle
      font.letterSpacing: 8
      font.capitalization: Font.AllUppercase
    }
  }

  Rectangle {
    anchors.bottom: parent.bottom
    width: parent.width
    height: lock.barHeight
    color: "#000000"

    Column {
      anchors.centerIn: parent
      spacing: 12
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: lock.errorState ? lock.failureMessage
          : (lock.authenticatingPassword ? "Checking…"
          : lock.greeting() + ", " + lock.userName + ". Enter your password to continue.")
        color: lock.errorState ? Color.lock.textError : lock.ink
        font.family: Style.font.family
        font.pixelSize: Style.font.heading
        font.italic: true
      }
      PasswordField {
        id: field
        lock: lock
        anchors.horizontalCenter: parent.horizontalCenter
        width: 400
        height: 42
        radius: 0
        outlineThickness: 1
        showLockGlyph: false
        color: "#000000"
        placeholder: "Password"
      }
    }
  }
}
