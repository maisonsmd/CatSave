import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Universal 2.12

import CatSave 1.0

ApplicationWindow {
    id: window
    width: 360
    height: 616
    visible: true
    title: qsTr("maisonsmd")

    Component.onCompleted: {
        console.log(width, height);
    }

    Connections {
        target: monthlyList
        function onShowNotification(title, message) {
            messagePopup.show(title, message)
        }
    }

    Popup {
        id: messagePopup
        z: 9999
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: 200
        padding: 0

        property string title: ""
        property string message: ""

        Pane {
            id: titlePane
            width: parent.width
            height: 40
            clip: true
            Universal.background: "gray"
            Universal.foreground: "white"

            padding: 0

            Button {
                id: btnClosePopup
                anchors.right: parent.right
                height: parent.height
                width: parent.height
                padding: 0

                icon {
                    name: "close"
                }

                onClicked: messagePopup.close()
            }

            Item {
                anchors {
                    left: parent.left
                    leftMargin: 10
                    right: btnClosePopup.left
                    verticalCenter: parent.verticalCenter
                }
                Label {
                    text: messagePopup.title
                    anchors.centerIn: parent
                    wrapMode: Label.Wrap
                }
            }
        }

        Pane {
            width: parent.width
            anchors.top: titlePane.bottom
            anchors.bottom: parent.bottom
            clip: true

            Label {
                text: messagePopup.message
                anchors.fill: parent
                wrapMode: Label.Wrap
            }
        }

        function show(_title, _message) {
            title = _title
            message = _message
            open()
        }

        enter: Transition {
            NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: 100}
        }
        exit: Transition {
            NumberAnimation { properties: "opacity"; from: 1; to: 0; duration: 100}
        }
    }

    Item {
        id: content
        anchors.fill: parent

        MonthSelector {
            id: monthSelector
            month: monthlyList.currentMonth
            year: monthlyList.currentYear

            onNextMonth: {
                if (month == 12) {
                    monthlyList.setCurrentMonth(1);
                    monthlyList.setCurrentYear(year + 1)
                } else {
                    monthlyList.setCurrentMonth(month + 1);
                }
            }
            onPrevMonth: {
                if (month == 1) {
                    monthlyList.setCurrentMonth(12);
                    monthlyList.setCurrentYear(year - 1)
                } else {
                    monthlyList.setCurrentMonth(month - 1);
                }
            }
        }

        TabBar {
            id: tabBar
            width: parent.width

            anchors {
                top: monthSelector.bottom
            }

            currentIndex: swipeView.currentIndex

            TabButton {
                text: qsTr("Expense")
            }
            TabButton {
                text: qsTr("Income")
            }
            TabButton {
                text: qsTr("Summary")
            }
        }

        SwipeView {
            id: swipeView
            width: parent.width

            anchors {
                top: tabBar.bottom
                bottom:  parent.bottom
            }

            currentIndex: tabBar.currentIndex
            onCurrentIndexChanged: {
                editPanel.recordType = swipeView.currentIndex === 0 ? Enums.EXPENSE : Enums.INCOME
                editPanel.close()
            }

            FilterPage {
                dataModel: expenseProxy
                onEdit: {
                    console.log("on edit")
                    console.log(id, newDate, newTitle, newAmount)

                    editPanel.recordId = id
                    editPanel.recordTitle = newTitle
                    editPanel.recordDatetime = newDate
                    editPanel.recordAmount = newAmount
                    editPanel.recordType = Enums.EXPENSE
                    editPanel.isEditing = true
                    editPanel.open()
                }

                onRemove: {
                    deleteRecord(id)
                }
            }
            FilterPage {
                dataModel: incomeProxy
                onEdit: {
                    console.log("on edit")
                    console.log(id, newDate, newTitle, newAmount)

                    editPanel.recordId = id
                    editPanel.recordTitle = newTitle
                    editPanel.recordDatetime = newDate
                    editPanel.recordAmount = newAmount
                    editPanel.recordType = Enums.INCOME
                    editPanel.isEditing = true
                    editPanel.open()
                }

                onRemove: {
                    deleteRecord(id)
                }
            }

            SummaryPage {
            }
        }
    }

    /*GaussianBlur {
        id: blur
        visible: contentBlur.visible
        anchors.fill: source
        source: content
        radius: 4
        samples: 1 + radius * 2
    }*/

    Pane {
        id: contentBlur
        anchors.fill: content
        opacity: 0.2
        Universal.background: "black"
        visible: editPanel.isOpen || messagePopup.opened

        MouseArea {
            anchors.fill: parent
            onClicked: {
                editPanel.close()
            }
        }
    }

    RoundButton {
        width: 50
        height: 50

        opacity: editPanel.isOpen ? 0 : 0.7
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: 20
            bottomMargin: 10
        }
        icon {
            name: "plus"
        }
        onClicked: {
            editPanel.isEditing = false
            editPanel.open()
        }
        visible: swipeView.currentIndex != 2
    }


    EditPanel {
        id: editPanel
        onSaveEdit: saveRecordEdit(id, datetime, title, amount)
        onCreateNew: createNewRecord(datetime, title, amount, type)
    }

    function saveRecordEdit(id, newDate, newTitle, newAmount) {
        newTitle = newTitle.trim()
        if (newTitle.length === 0)
            return
        console.log("edit", id, newDate, newTitle, newAmount)
        monthlyList.editRecord(id, newDate, newTitle, +newAmount)
    }

    function createNewRecord(newDate, newTitle, newAmount, type) {
        newTitle = newTitle.trim()
        if (newTitle.length === 0)
            return
        console.log("create", newDate, newTitle, newAmount, type)
        monthlyList.addRecord(newDate, newTitle, +newAmount, type)
    }

    function deleteRecord(id) {
        console.log("delete", id)
        monthlyList.removeRecord(id);
    }
}
