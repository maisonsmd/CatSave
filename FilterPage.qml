import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Universal 2.12

import CatSave 1.0
import "util.js" as Util

Page {
    id: root
    width: 600
    height: 400

    signal edit(string id, date newDate, string newTitle, int newAmount)
    signal remove(string id)
    required property var dataModel

    ListView {
        id: flickArea
        anchors.fill: parent
        clip: true

        // focus to last item when add to last
        property int lastCount: 0
        onCountChanged: {
            if(count > lastCount)
                flickArea.currentIndex = count - 1
            lastCount = count
        }

        model:  dataModel
        section.property: "day"
        section.criteria: ViewSection.FullString
        section.delegate: Rectangle {
            width: 30; height: 0
            Rectangle {
                width: parent.width
                height: 35
                color: "gray"
                Label {
                    text: section
                    color: "white"
                    anchors.centerIn: parent
                }
            }
        }

        delegate: Pane {
            id: pane
            width: flickArea.width
            height: titlePane.height
            padding: 0

            Universal.foreground: model.id === toolTip.recordId ? Universal.Red : Universal.Steel

            Rectangle {
                id: colDividerLine
                anchors {
                    right: amountPane.left
                    rightMargin: 1
                }
                width: 1
                height: parent.height
                color: "lightgrey"
            }

            Rectangle {
                id: rowDividerLine
                anchors {
                    left: titlePane.left
                    leftMargin: 10
                }
                height: 1
                width: titlePane.width + amountPane.width - 10
                visible: index > 0
                color: "lightgrey"
            }

            Item {
                id: dayPlaceholder
                width: 30
            }

            Item {
                id: titlePane
                height: Math.max(35, titleText.height + 10)
                anchors.left: dayPlaceholder.right
                anchors.right: colDividerLine.left

                Label {
                    id: titleText
                    width: parent.width
                    leftPadding: 10
                    rightPadding: 10
                    wrapMode: Label.Wrap
                    anchors.verticalCenter: parent.verticalCenter

                    text: model.title
                }
            }

            Item {
                id: amountPane
                height: parent.height
                width: Math.max (80, amountText.width)
                anchors.right: parent.right

                Label {
                    id: amountText
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    rightPadding: 20 //(scrollbar.myIsVisible ? scrollbar.width : 0) + 10
                    leftPadding: 10

                    text: Util.addThousandSeperator(model.amount)
                }
            }

            MouseArea {
                anchors.fill: parent
                onPressAndHold: {
                    toolTip.x = mapToItem(flickArea, mouseX, mouseY).x
                    toolTip.y = mapToItem(flickArea, mouseX, mouseY).y
                    toolTip.recordId = model.id
                    toolTip.recordTitle = titleText.text
                    toolTip.recordAmount = Util.removeThousandSeperator(amountText.text)
                    toolTip.recordDatetime = model.datetime
                    toolTip.open()
                }
            }
        }

        ScrollBar.vertical: ScrollBar { width: 10 }

        footer: Item {
            height: 200
            width: flickArea.width

            Rectangle {
                id: footerRowDividerLine
                anchors {
                    top: footerColDividerLine.top
                    topMargin: 5
                }

                height: 1
                width: parent.width
                color: "lightgrey"
            }

            Rectangle {
                id: footerColDividerLine
                anchors {
                    right: footerTotalAmountPane.left
                    rightMargin: 1
                    verticalCenter: parent.verticalCenter
                }
                width: 0
                height: parent.height / 2
                color: "lightgrey"
            }

            Item {
                id: footerDayPlaceholder
                width: 30
            }

            Item {
                id: footerTitlePane
                height: parent.height
                anchors.left: footerDayPlaceholder.right
                anchors.right: footerColDividerLine.left

                Label {
                    width: parent.width
                    leftPadding: 10
                    rightPadding: 10
                    wrapMode: Label.Wrap
                    anchors.verticalCenter: parent.verticalCenter

                    text: "Total"
                }
            }

            Item {
                id: footerTotalAmountPane
                height: parent.height
                width: 80
                anchors.right: parent.right

                Label {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    rightPadding: 20
                    leftPadding: 10

                    text: Util.addThousandSeperator(dataModel.totalAmount)
                }
            }
        }
    }

    Popup {
        id: toolTip
        width: 150
        height: toolTipText.height + btnRemove.height + btnEdit.height + padding * 2
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property string recordId: ""
        property string recordTitle: ""
        property int recordAmount: 0
        property date recordDatetime: new Date()

        Label {
            id: toolTipText
            height: 70; width: parent.width
            wrapMode: Label.Wrap
            maximumLineCount: 3
            elide: Label.ElideRight
            text: toolTip.recordTitle
        }

        Button {
            id: btnRemove
            width: parent.width
            anchors.top: toolTipText.bottom

            text: "Remove"
            icon {
                name: "close"
                height: parent.height * 1.2
            }
            onPressed: {
                remove(toolTip.recordId)
                toolTip.close()
            }
        }

        Button {
            id: btnEdit
            width: parent.width
            anchors.top: btnRemove.bottom
            anchors.topMargin: 5
            text: "Edit"
            icon {
                name: "pencil"
                height: parent.height
            }

            onPressed: {
                toolTip.close()

                root.edit(toolTip.recordId, toolTip.recordDatetime, toolTip.recordTitle, toolTip.recordAmount);
            }
        }

        onClosed: {
            // remove highlight color
            recordId = ""
            console.log("tooltip closed")
        }

        onXChanged: {
            if (x + width > parent.width) {
                x = parent.width - width - 10
            }
        }

        onYChanged: {
            if (y + height > parent.height) {
                y = parent.height - height - 10
            }
        }
        enter: Transition {
            NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: 100}
        }
        exit: Transition {
            NumberAnimation { properties: "opacity"; from: 1; to: 0; duration: 100}
        }
    }

    header: Pane {
        height: 30; width: parent.width
        topPadding: 0

        Label {
            id: dateLabel
            text: "Date"
        }
        Label {
            id: leftSlash
            anchors.left: dateLabel.right
            anchors.right: titleLabel.left
            horizontalAlignment: Text.AlignHCenter
            text: "¯\\_(ツ)_/¯"
            color: "lightgray"
        }
        Label {
            id: titleLabel
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Title"
        }
        Label {
            id: rightSlash
            anchors.left: titleLabel.right
            anchors.right: amountLabel.left
            horizontalAlignment: Text.AlignHCenter
            text: "(￣﹃￣)"
            color: "lightgray"
        }
        Label {
            id: amountLabel
            anchors.right: parent.right
            text: "Amount"
        }
    }
}
