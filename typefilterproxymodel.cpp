#include "typefilterproxymodel.h"

TypeFilterProxyModel::TypeFilterProxyModel(QObject *parent, const Enums::RecordType & type) :
    QSortFilterProxyModel(parent),
    m_type(type)
{
    QSortFilterProxyModel::setFilterRole(MonthlyList::Roles::TypeRole);
    QSortFilterProxyModel::setFilterFixedString(QMetaEnum::fromType<Enums::RecordType>().valueToKey(static_cast<int>(type)));
}

void TypeFilterProxyModel::setSourceModel(QAbstractItemModel *sourceModel)
{
    MonthlyList * monthly = static_cast<MonthlyList*>(this->sourceModel());

    if (this->sourceModel() != nullptr)
        disconnect(monthly, &MonthlyList::totalAmountChanged, this, &TypeFilterProxyModel::onTotalAmountChanged);

    QSortFilterProxyModel::setSourceModel(sourceModel);

    monthly = static_cast<MonthlyList*>(sourceModel);
    connect(monthly, &MonthlyList::totalAmountChanged, this, &TypeFilterProxyModel::onTotalAmountChanged);
}

qint64 TypeFilterProxyModel::totalAmount()
{
    qint64 sum = 0;
    for (int i = 0; i < rowCount(); ++i) {
        sum += data(index(i, 0), MonthlyList::Roles::AmountRole).toLongLong();
    }
    return sum;
}

void TypeFilterProxyModel::onTotalAmountChanged()
{
    emit totalAmountChanged();
}
