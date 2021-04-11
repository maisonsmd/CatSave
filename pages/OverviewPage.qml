import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Universal 2.12

import "../"

Page {
    id: root
    width: 600
    height: 400

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

    SummaryRow {
        id: incomeRow
        title: "Income"
        anchors {
            top: label.bottom
            topMargin: 20
        }

        amount: incomeProxy.totalAmount
    }

    SummaryRow {
        id: expenseRow
        title: "Expense"
        amount: expenseProxy.totalAmount
        anchors {
            top: incomeRow.bottom
        }
    }

    Rectangle {
        id: rowDivider
        anchors {
            top: totalRow.top
            topMargin: 0
        }

        height: 1
        width: parent.width
        color: "lightgrey"
    }

    SummaryRow {
        id: totalRow
        title: "Total"
        amount: incomeProxy.totalAmount - expenseProxy.totalAmount
        anchors {
            top: expenseRow.bottom
            topMargin: 20
        }
    }

    Item {
        height: 100
        width: btnExport.width + btnImport.width

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
}
