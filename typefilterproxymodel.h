#ifndef TYPEFILTERPROXYMODEL_H
#define TYPEFILTERPROXYMODEL_H

#include <QSortFilterProxyModel>
#include "enums.h"
#include "monthlylist.h"

class TypeFilterProxyModel : public QSortFilterProxyModel {
Q_OBJECT

    Q_PROPERTY(qint64 totalAmount READ totalAmount NOTIFY totalAmountChanged)
public:
    explicit TypeFilterProxyModel (QObject * parent, const Enums::RecordType & type);
    void setSourceModel(QAbstractItemModel *sourceModel) override;

    qint64 totalAmount();

signals:
    void totalAmountChanged();

public slots:
    void onTotalAmountChanged();

private:
    const Enums::RecordType m_type;
};

#endif // TYPEFILTERPROXYMODEL_H
