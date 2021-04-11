import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Universal 2.12
import "util.js" as Util

Item {
    id: root
    required property string title
    required property int amount

    implicitHeight: 30
    implicitWidth: parent.width

    Item {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right

            leftMargin: 20
            rightMargin: 20
        }

        height: 50

        Item {
            height: parent.height
            anchors.left: parent.left
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
