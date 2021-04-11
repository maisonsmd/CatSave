import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Universal 2.12

import CatSave 1.0
import "util.js" as Util

Item {
    id: root
    implicitHeight: 100
    implicitWidth: parent.width

    property int recordType: Enums.EXPENSE

    property string recordId: ""
    property date recordDatetime: new Date()
    property string recordTitle: ""
    property int recordAmount: 0

    property bool isEditing: false
    property bool isOpen: state === "opened"

    anchors {
        bottom: parent.bottom
        bottomMargin: -height
    }

    signal saveEdit(string id, date datetime, string title, int amount)
    signal createNew(date datetime, string title, int amount, int type)

    onRecordTypeChanged: console.log("record type:", recordType)

    Pane {
        id: inputPane

        height: newTitleText.height + padding * 2
        width: parent.width
        padding: 10
        clip: true
        anchors {
            bottom: parent.bottom
        }

        DatePicker {
            id: datePicker
            maxWidth: parent.width
            z: 999
        }

        TextField {
            id: newTitleText
            height: 70
            anchors {
                left: datePicker.left
                right: newAmountText.left
                leftMargin: datePicker.buttonWidth + 5
                rightMargin: 5
            }
            verticalAlignment: Text.AlignVCenter
            wrapMode: TextField.Wrap
            selectByMouse: true

            onAccepted: newAmountText.focus = true
        }

        TextField {
            id: newAmountText
            width: 100
            anchors {
                right: saveBtn.left
                rightMargin: 5
            }
            height: parent.height

            verticalAlignment: Text.AlignVCenter
            validator: IntValidator {bottom: 0}
            horizontalAlignment: TextField.AlignRight
            wrapMode: TextField.Wrap

            onFocusChanged: if(focus) selectAll()
            onAccepted: submitEdit()
        }
        Button {
            id: saveBtn
            width: 50
            height: parent.height
            anchors.right: parent.right
            padding: 10

            icon {
                name: root.isEditing ? "tick" : "plus"
                height: parent.height
            }

            onPressed: {
                submitEdit()
                root.isEditing = false
            }
        }
    }

    states: [
        State {
            name: "opened"
            PropertyChanges {
                target: root
                anchors.bottomMargin: 0
            }
        },
        State {
            name: "closed"
            PropertyChanges {
                target: root
                anchors.bottomMargin: -inputPane.height
            }
        }
    ]
    transitions: Transition {
        PropertyAnimation {
            property: "anchors.bottomMargin"
            duration: 100
            easing.type: Easing.Bezier
        }
    }

    function open() {
        if (isEditing) {
            newTitleText.text = root.recordTitle
            newAmountText.text = root.recordAmount
        } else {
            resetInputs()
            root.recordDatetime = new Date()

        }
        newTitleText.focus = true
        datePicker.currentDate = root.recordDatetime.getDate()
        root.state = "opened"
    }

    function close() {
        newTitleText.focus = false
        newAmountText.focus = false
        datePicker.close()
        root.state = "closed"
    }

    function submitEdit() {
        root.recordDatetime = new Date(root.recordDatetime.getFullYear(),
                                       root.recordDatetime.getMonth(),
                                       datePicker.currentDate)

        console.log("submit", root.recordDatetime.toString())

        root.recordTitle = newTitleText.text
        root.recordAmount = Util.removeThousandSeperator(newAmountText.text)

        if (root.isEditing)
            root.saveEdit(root.recordId, root.recordDatetime, root.recordTitle, root.recordAmount)
        else
            root.createNew(root.recordDatetime, root.recordTitle, root.recordAmount, root.recordType)

        root.isEditing = false
        resetInputs()
    }

    function resetInputs() {
        newTitleText.text = ""
        newAmountText.text = "0"
    }
}
