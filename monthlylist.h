#ifndef MONTHLYLIST_H
#define MONTHLYLIST_H

#include <QAbstractListModel>

#include "jsondb.h"

class MonthlyList : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(qint16 currentMonth READ currentMonth WRITE setCurrentMonth NOTIFY currentMonthChanged)
    Q_PROPERTY(qint16 currentYear READ currentYear WRITE setCurrentYear NOTIFY currentYearChanged)
    Q_PROPERTY(qint32 rowCount READ rowCount NOTIFY rowCountChanged)
    Q_PROPERTY(int daysInMonth READ daysInMonth NOTIFY daysInMonthChanged)
    Q_PROPERTY(qint64 initAmount READ initAmount WRITE setInitAmount NOTIFY initAmountChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        DateTimeRole,
        DayInMonthRole,
        TitleRole,
        AmountRole,
        TypeRole
    };

    explicit MonthlyList(QObject * parent = nullptr);
    qint64 totalIncome() const;
    qint64 totalExpense() const;
    qint16 currentMonth() const;
    qint16 currentYear() const;
    int daysInMonth() const;
    qint64 initAmount() const;

    Q_INVOKABLE void setCurrentMonth(qint16 _month);
    Q_INVOKABLE void setCurrentYear(qint16 _year);

    Q_INVOKABLE bool addRecord(const QDateTime & _dt, const QString & _title, const qint64 & _amount, const Enums::RecordType & _type);
    Q_INVOKABLE bool removeRecord(const QString & _id);
    Q_INVOKABLE bool editRecord(const QString & _id, const QDateTime & _dt, const QString & _title, const qint64 & _amount);

    Q_INVOKABLE void exportToFile();
    Q_INVOKABLE void importFromFile();
    Q_INVOKABLE void setInitAmount(const qint64 & _val);

    bool getRecord(const QString _id, Record & _record) const;
    bool getRecord(const int _index, Record & _record) const;
    bool setRecord(const QString _id, const Record & _record);
    bool setRecord(const int _index, const Record & _record);

    int rowCount(const QModelIndex &_parent = QModelIndex()) const override;
    Qt::ItemFlags flags(const QModelIndex& _index) const override;
    QVariant data(const QModelIndex &_index, int _role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &_index, const QVariant &_value,
                 int role = Qt::EditRole) override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void totalAmountChanged();
    void currentMonthChanged();
    void currentYearChanged();
    void rowCountChanged();
    void daysInMonthChanged();
    void showNotification(QString _title, QString _message);
    void initAmountChanged();

protected:
    int getIndexToAdd(const Record & _record) const;

private:
    void updateFilePath();

    qint16 m_currentMonth = 0;
    qint16 m_currentYear = 0;

    JsonDb * m_db = nullptr;
};

#endif // MONTHLYLIST_H
