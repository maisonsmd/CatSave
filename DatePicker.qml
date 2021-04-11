import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Universal 2.12

Pane {
    id: root
    implicitHeight: parent.height
    width: btnOpenClose.width
    padding: 0
    clip: true
    state: "closed"

    property int currentDate: 1
    property int maxWidth: width
    property int buttonWidth: 50
    property bool isOpen: state === "opened"

    signal selected(int date)

    Pane {
        id: carousel
        height: parent.height
        width: root.maxWidth - btnOpenClose.width
        anchors.right: btnOpenClose.left
        padding: 0

        ListView {
            id: dayList
            height: carousel.height
            width: carousel.width
            model: monthlyList.daysInMonth
            orientation: ListView.Horizontal
            clip: true

            maximumFlickVelocity: 1000000

            delegate: Item {
                height: dayList.height
                width: 50

                Pane {
                    height: parent.height
                    width: 48
                    padding: 0

                    Universal.background: index != dayList.currentIndex ? "#f0f0f0" : Universal.accent

                    Label {
                        text: index + 1
                        anchors.centerIn: parent
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        close()
                        currentDate = index + 1
                        selected(currentDate)
                    }
                }
            }
        }
    }

    Item {
        id: btnOpenClose
        width: root.buttonWidth
        height: parent.height
        anchors.right: parent.right

        Button {
            id: _btnOpen
            anchors.fill: parent
            padding: 0
            visible: root.state === "closed"
            text: currentDate
        }
        Button {
            id: _btnClose
            anchors.fill: parent
            padding: 0
            visible: root.state === "opened"
            icon { name: "close" }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.isOpen ? close() : open()
        }

    }

    Behavior on width {
        NumberAnimation {
            target: root
            property: "width"
            duration: 200
            easing.type: Easing.InOutQuint
        }
    }

    states: [
        State {
            name: "opened"
            PropertyChanges { target: root; width: root.maxWidth }
        },
        State {
            name: "closed"
            PropertyChanges { target: root; width: btnOpenClose.width }
        }
    ]

    function open() {
        root.state = "opened"
        dayList.currentIndex = currentDate - 1
        dayList.positionViewAtIndex(dayList.currentIndex, ListView.Center)
    }

    function close() {
        root.state = "closed"
    }
}
