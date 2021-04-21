
#ifndef ENUMS_H
#define ENUMS_H

#include <QMetaEnum>
#include <QObject>

class Enums : public QObject {
    Q_OBJECT
public:
    enum class RecordType {
        EXPENSE,
        INCOME,
        DEBT
    };

    Q_ENUM(RecordType);
};

Q_DECLARE_METATYPE(Enums::RecordType);


#endif // ENUMS_H
