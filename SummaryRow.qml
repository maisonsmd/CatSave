import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Universal 2.12
import "util.js" as Util

Item {
    id: root
    required property string title
    required property int amount
    property string sign: " "
    property int padding: 20

    implicitHeight: 30
    implicitWidth: parent.width


    Item {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right

            leftMargin: root.padding
            rightMargin: root.padding
        }

        height: parent.height

        Item {
            id: sign
            height: parent.height
            width: 10
            anchors.left: parent.left
            anchors.leftMargin: 10
            Label {
                anchors.centerIn: parent
                padding: 0
                text: root.sign
            }
        }

        Item {
            height: parent.height
            anchors.left: sign.right
            anchors.leftMargin: 10
            anchors.right: amount.left

            Label {
                width: parent.width
                leftPadding: 10
                rightPadding: 10
                wrapMode: Label.Wrap
                anchors.verticalCenter: parent.verticalCenter

                text: root.title
            }
        }

        Item {
            id: amount
            height: parent.height
            width: 80
            anchors.right: parent.right

            Label {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                rightPadding: 10
                leftPadding: 10

                text: Util.addThousandSeperator(root.amount)
            }
        }
    }
}
