#include "monthlylist.h"
#include <QCalendar>
#include <QDateTime>
#include <QDebug>
#include <QStandardPaths>

#include "logger.h"

MonthlyList::MonthlyList(QObject * parent)
    : QAbstractListModel(parent)
{
    m_db = JsonDb::getInstance();
    const auto dt = QDateTime::currentDateTime();
    m_currentMonth = dt.date().month();
    m_currentYear = dt.date().year();
    updateFilePath();

    LOGI(dt.toString());

    connect(this, &MonthlyList::currentMonthChanged, this, &MonthlyList::daysInMonthChanged);
    connect(this, &MonthlyList::currentYearChanged, this, &MonthlyList::daysInMonthChanged);
}

qint64 MonthlyList::totalIncome() const
{
    qint64 sum = 0;

    for (int i = 0; i < rowCount(); ++i) {
        Record r;
        if (getRecord(i, r))
            if (r.type == Enums::RecordType::INCOME)
                sum += r.amount;
    }

    return sum;
}

qint64 MonthlyList::totalExpense() const
{
    qint64 sum = 0;

    for (int i = 0; i < rowCount(); ++i) {
        Record r;
        if (getRecord(i, r))
            if (r.type == Enums::RecordType::EXPENSE)
                sum += r.amount;
    }

    return sum;
}

qint16 MonthlyList::currentMonth() const
{
    return m_currentMonth;
}

qint16 MonthlyList::currentYear() const
{
    return m_currentYear;
}

int MonthlyList::daysInMonth() const
{
    return QCalendar().daysInMonth(currentMonth(), currentYear());
}

qint64 MonthlyList::initAmount() const
{
    return m_db->getInitAmount();
}

void MonthlyList::setCurrentMonth(qint16 _month)
{
    if(_month != m_currentMonth){
        m_currentMonth = _month;
        updateFilePath();
        emit currentMonthChanged();
    }
}

void MonthlyList::setCurrentYear(qint16 _year)
{
    if(_year != m_currentYear){
        m_currentYear = _year;
        updateFilePath();
        emit currentYearChanged();
    }
}

bool MonthlyList::addRecord(const QDateTime &_dt, const QString &_title, const qint64 &_amount, const Enums::RecordType &_type)
{
    Record r;
    r.dt = _dt;
    r.title = _title;
    r.amount = _amount;
    r.type = _type;

    auto newIndex = getIndexToAdd(r);
    LOGI(QString::number(newIndex));

    beginInsertRows(QModelIndex(), newIndex, newIndex);
    bool success = m_db->insert(r, newIndex);
    endInsertRows();

    if (_amount != 0) {
        emit totalAmountChanged();
    }

    return success;
}

bool MonthlyList::removeRecord(const QString &_id)
{
    auto idx = m_db->indexOf(_id);
    if (idx == -1)
        return false;

    beginRemoveRows(QModelIndex(), idx, idx);
    bool success = m_db->remove(idx);
    endRemoveRows();

    emit totalAmountChanged();

    return success;
}

bool MonthlyList::editRecord(const QString &_id, const QDateTime & _dt, const QString &_title, const qint64 &_amount)
{
    Record oldVal;
    if (!getRecord(_id, oldVal))
        return false;

    oldVal.dt = _dt;
    oldVal.title = _title;
    oldVal.amount = _amount;

    return setRecord(_id, oldVal);
}

void MonthlyList::exportToFile()
{
    emit showNotification("Notice", "Not implemented, goto /storage/emulated/0/Android/data/org.qtproject.example.CatSave/files/Documents/ to get files");
    return;

    if (m_db->rowCount() == 0) {
        emit showNotification("Error", "Nothing to export");
        return;
    }

    if (!m_db->exportToFile()) {
        emit showNotification("Error", "Export failed!");
        return;
    }

    emit showNotification("Message", "Export succeeded!");
}

void MonthlyList::importFromFile()
{
    if (m_db->importFromFile()) {
        updateFilePath();
        emit showNotification("Message", "Import succeeded!");
        emit initAmountChanged();
        return;
    }

    emit showNotification("Error", "Import failed!");
}

void MonthlyList::setInitAmount(const qint64 & _val)
{
    if (_val != m_db->getInitAmount()) {
        m_db->setInitAmount(_val);
        emit initAmountChanged();
    }
}

bool MonthlyList::getRecord(const QString _id, Record &_record) const
{
    return m_db->get(_id, _record);
}

bool MonthlyList::getRecord(const int _index, Record &_record) const
{
    return m_db->get(_index, _record);
}

bool MonthlyList::setRecord(const QString _id, const Record &_record)
{
    auto idx = m_db->indexOf(_id);
    return setRecord(idx, _record);
}

bool MonthlyList::setRecord(const int _index, const Record &_record)
{
    bool success = false;
    int newIndex = getIndexToAdd(_record);

    if (newIndex == _index){
        LOGD("data index not changed");
        success = m_db->set(_index, _record);
        emit dataChanged(index(_index), index(_index));
    } else {

        beginRemoveRows(QModelIndex(), _index, _index);
        m_db->remove(_index);
        endRemoveRows();

        // update new index after removal
        newIndex = getIndexToAdd(_record);

        LOGD(QString("data index changed from %1 to %2")
             .arg(QString::number(_index))
             .arg(QString::number(newIndex)));

        beginInsertRows(QModelIndex(), newIndex, newIndex);
        success = m_db->insert(_record, newIndex);
        endInsertRows();
    }

    emit totalAmountChanged();

    return success;
}

int MonthlyList::rowCount(const QModelIndex &_parent) const
{
    if (_parent.isValid())
        return 0;
    return m_db->rowCount();
}

Qt::ItemFlags MonthlyList::flags(const QModelIndex &_index) const
{
    if (!_index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEditable;
}

QVariant MonthlyList::data(const QModelIndex &_index, int _role) const
{
    Record r;

    if (!_index.isValid())
        return QVariant();

    if (!m_db->get(_index.row(), r))
        return QVariant();

    switch (_role) {
    case IdRole: return r.id;
    case DateTimeRole: return r.dt;
    case DayInMonthRole: return r.dt.date().day();
    case TitleRole: return r.title;
    case AmountRole: return r.amount;
    case TypeRole: return QMetaEnum::fromType<Enums::RecordType>()
                .valueToKey(static_cast<int>(r.type));
    }

    return QVariant();
}

bool MonthlyList::setData(const QModelIndex &_index, const QVariant &value, int _role)
{
    if (data(_index, _role) == value)
        return false;

    Record oldData;

    if (!m_db->get(_index.row(), oldData))
        return false;

    switch (_role) {
    case TypeRole:
    case DayInMonthRole:
    case IdRole: return false;
    case DateTimeRole:
        oldData.dt = value.toDateTime();
        break;
    case TitleRole:
        oldData.title = value.toString();
        break;
    case AmountRole:
        oldData.amount = value.toLongLong();
        break;
    }

    return setRecord(_index.row(), oldData);
}

QHash<int, QByteArray> MonthlyList::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[DateTimeRole] = "datetime";
    roles[DayInMonthRole] = "day";
    roles[TitleRole] = "title";
    roles[AmountRole] = "amount";
    roles[TypeRole] = "type";
    return roles;
}

int MonthlyList::getIndexToAdd(const Record & _record) const
{
    for (int i = 0; i < rowCount(); i++) {
        Record r;
        getRecord(i, r);
        if (_record.dt < r.dt)
            return i;
    }
    return rowCount();
}

void MonthlyList::updateFilePath()
{
    beginResetModel();
    m_db->setFilePath(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation)
                      + QString("/monthly_%1_%2.json").arg(m_currentMonth).arg(m_currentYear));
    endResetModel();

    emit totalAmountChanged();
    emit initAmountChanged();
}
