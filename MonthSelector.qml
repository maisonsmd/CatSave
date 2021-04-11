import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Universal 2.12

Item {
    width: parent.width
    implicitHeight: monthYearRect.height
    property variant monthStrings: ["invalid", "January","February","March","April","May","June","July","August","September","October","November","December"]
    property int month: 0
    property int year: 1970

    signal nextMonth()
    signal prevMonth()

    Pane {
        anchors.fill: parent
        height: 40
        padding: 0

        Button {
            id: prevMonthBtn
            height: 100;  width: 40
            topPadding: 15; bottomPadding: 15
            anchors {
                verticalCenter: parent.verticalCenter
            }

            icon {
                name: "back"
                height: parent.height
            }
            background: Rectangle { color: "transparent" }
            onClicked: prevMonth()
        }

        Button {
            id: nextMonthBtn
            height: 100;  width: 40
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            topPadding: 15; bottomPadding: 15
            rotation: 180
            icon {
                name: "back"
                height: parent.height
            }
            background: Rectangle { color: "transparent" }

            onClicked: nextMonth()
        }

        Pane {
            id: monthYearRect
            width: monthStr.width + yearStr.width + 20
            height: monthStr.height

            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }

            Label {
                id: monthStr
                text: monthStrings[month].toUpperCase()
                anchors.verticalCenter: parent.verticalCenter

                Universal.foreground: Universal.Red
                font {
                    family: Qt.application.font.family
                    pixelSize: Qt.application.font.pixelSize * 2
                }
            }

            Label {
                id: yearStr
                text: year
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: monthStr.right
                }
                Universal.foreground: "lightgrey"
                font {
                    family: Qt.application.font.family
                    pixelSize: Qt.application.font.pixelSize * 2
                    bold: true
                }
            }
        }
    }
}
