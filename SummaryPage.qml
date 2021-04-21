import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Universal 2.12

Page {
    id: root
    width: 600
    height: 400

    property bool isPopupOpened: initPopup.opacity > 0

    Label {
        id: label
        anchors {
            top: parent.top
            topMargin: 40
        }

        leftPadding: 20
        rightPadding: 20

        text: "Summary for " + monthSelector.monthStrings[monthSelector.month]
        + " " + monthSelector.year
    }

    Rectangle {
        id: initRect
        width: parent.width - 40
        height: 30
        anchors {
            top: label.bottom
            topMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        border {
            width: 1
            color: "lightgray"
        }
        color: initMouseArea.pressed ? "lightgray" : "transparent"

        SummaryRow {
            id: initRow
            anchors.centerIn: parent
            title: "Init"
            sign: "+"
            amount: monthlyList.initAmount
            padding: 0
        }

        MouseArea {
            id: initMouseArea
            anchors.fill: initRect
            onClicked: {
                initPopup.open()
            }
        }
    }

    SummaryRow {
        id: incomeRow
        title: "Income"
        sign: "+"
        anchors {
            top: initRect.bottom
        }

        amount: incomeProxy.totalAmount
    }

    SummaryRow {
        id: expenseRow
        title: "Expense"
        sign: "-"
        amount: expenseProxy.totalAmount
        anchors {
            top: incomeRow.bottom
        }
    }

    SummaryRow {
        id: debtRow
        title: "Debt paying"
        sign: "-"
        amount: debtProxy.totalAmount
        anchors {
            top: expenseRow.bottom
        }
    }

    Rectangle {
        id: rowDivider
        anchors {
            top: remainingRow.top
            topMargin: 0
        }

        height: 1
        width: parent.width
        color: "lightgrey"
    }

    SummaryRow {
        id: remainingRow
        title: "Remaining"
        amount: monthlyList.initAmount + incomeProxy.totalAmount - expenseProxy.totalAmount - debtProxy.totalAmount
        anchors {
            top: debtRow.bottom
            topMargin: 20
        }
    }

    Item {
        height: 100
        width: btnExport.width + btnImport.width + 10

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 50
        }

        Button {
            id: btnExport
            width: 100
            text: "Export"

            onClicked: monthlyList.exportToFile()
        }

        Button {
            id: btnImport
            width: 100
            anchors.left: btnExport.right
            anchors.leftMargin: 10

            text: "Import"

            onClicked: monthlyList.importFromFile()
        }
    }

    Popup {
        id: initPopup
        width: 200
        height: 150
        opacity: 0

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2 - 100

        Label {
            id: newInitLabel
            text: "Input new:"
            anchors {
                top: parent.top
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
        }

        TextField {
            id: initEditText
            width: parent.width
            anchors {
                top: newInitLabel.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            horizontalAlignment: TextEdit.AlignHCenter
            validator: IntValidator {bottom: 0}

            text: "0"
            onFocusChanged: {
                if (focus) {
                    selectAll()
                }
            }
        }
        Button {
            width: parent.width
            anchors {
                bottom: parent.bottom
            }
            text: "Save"
            onClicked: {
                monthlyList.setInitAmount(+initEditText.text)
                initPopup.close()
            }
        }

        onOpened: {
            console.log("initAmount", monthlyList.initAmount)
            initEditText.text = monthlyList.initAmount
        }

        enter: Transition {
            NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: 100}
        }
        exit: Transition {
            NumberAnimation { properties: "opacity"; from: 1; to: 0; duration: 100}
        }
    }

}
