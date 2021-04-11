#ifndef JSONDB_H
#define JSONDB_H

#include <QString>
#include <QDateTime>
#include <QList>

#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>

#include "logger.h"
#include "enums.h"

struct Record {
    QString id;
    QDateTime dt;
    QString title;
    qint64 amount;
    Enums::RecordType type = Enums::RecordType::EXPENSE;

    QJsonObject toJson() const {
        return {
            {"id", id},
            {"timestamp", dt.toMSecsSinceEpoch()},
            {"title", title},
            {"amount", amount},
            {"type", QMetaEnum::fromType<Enums::RecordType>().valueToKey(static_cast<int>(type))}
        };
    }
};

class JsonDb
{
public:
    static JsonDb *getInstance();

    void setFilePath(const QString & _path);
    void save();

    bool remove(const QString & _id);
    bool remove(const int & _index);
    bool add(const Record & _record);
    bool insert(const Record & _record, const int & _index);
    int rowCount() const;
    bool get(const QString & _id, Record & _record) const;
    bool get(const int & _index, Record & _record) const;
    bool set(const QString & _id, const Record & _record);
    bool set(const int & _index, const Record & _record);
    int indexOf(const QString & _id);

    bool exportToFile();
    bool importFromFile();

private:
    void sort();
    JsonDb();
    ~JsonDb();

    bool openFile();
    void parseFile();

    static JsonDb * m_instance;
    QFile m_file;
    QList<Record> m_records;
};

#endif // JSONDB_H
