import QtQuick
import qs.Commons
import qs.Ui

// White field + black type when highlighted. Idle is black + white type.
BorderSurface {
  id: root

  property string text: ""
  property string iconText: ""
  property string tooltipText: ""
  property bool selected: false
  property bool active: false
  property bool hasCursor: false
  property bool focusable: false
  property color foreground: "#FFFFFF"
  property color paper: "#FFFFFF"
  property color ink: "#000000"
  property string fontFamily: Style.font.family
  property real fontSize: Style.font.body
  property real iconSize: Style.font.icon
  property real horizontalPadding: Style.spacing.controlPaddingX
  property real verticalPadding: Style.spacing.controlPaddingY
  property bool leftAlign: false
  property bool bordered: false

  signal clicked()
  signal hovered(bool isHovered)

  readonly property bool hot: mouseArea.containsMouse || hasCursor
  readonly property bool inverted: hot || selected || active || (focusable && activeFocus)

  color: inverted ? root.paper : "transparent"
  radius: 0
  borderSpec: Border.none()

  implicitWidth: row.implicitWidth + horizontalPadding * 2
  implicitHeight: Math.max(row.implicitHeight + verticalPadding * 2, Style.spacing.controlHeight)

  activeFocusOnTab: focusable
  Keys.onReturnPressed: if (focusable) root.clicked()
  Keys.onEnterPressed: if (focusable) root.clicked()
  Keys.onSpacePressed: if (focusable) root.clicked()

  Row {
    id: row
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: root.leftAlign ? parent.left : undefined
    anchors.leftMargin: root.leftAlign ? root.horizontalPadding : 0
    anchors.horizontalCenter: root.leftAlign ? undefined : parent.horizontalCenter
    spacing: Style.spacing.controlGap

    Text {
      visible: root.iconText !== ""
      text: root.iconText
      color: root.inverted ? root.ink : root.paper
      font.family: root.fontFamily
      font.pixelSize: root.iconSize
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      visible: root.text !== ""
      text: root.text
      color: root.inverted ? root.ink : root.paper
      font.family: root.fontFamily
      font.pixelSize: root.fontSize
      font.bold: root.selected || root.active
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
    onContainsMouseChanged: root.hovered(containsMouse)
  }
}
