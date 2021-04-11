#include "jsondb.h"
#include <QVariantList>
#include <QTimer>
#include <QDir>
#include <QFileDialog>
#include <QQmlFile>
#include <algorithm>

#include "logger.h"

JsonDb * JsonDb::m_instance = nullptr;
JsonDb *JsonDb::getInstance()
{
    if(!JsonDb::m_instance) {
        JsonDb::m_instance = new JsonDb();
    }
    return JsonDb::m_instance;
}

void JsonDb::setFilePath(const QString & _path)
{
    if(m_file.isOpen())
        m_file.close();
    m_records.clear();

    m_file.setFileName(_path);
    LOGI(QString("file name: %1").arg(m_file.fileName()));

    if (!m_file.exists()) {
        LOGI("File not exist");
    } else parseFile();
}

void JsonDb::save()
{
    LOGI("save file");

    if (!m_file.isOpen()) {
        // LOGI("file is not opened, maybe it doesn't exist, now open!");
    }

    auto toJson = [](const QList<Record> & list)->QJsonArray{
        QJsonArray array;
        for (auto & user : list)
            array.append(user.toJson());
        return array;
    };

    QJsonDocument doc = QJsonDocument(toJson(m_records));

    if(!openFile())
        return;

    m_file.resize(0);
    m_file.write(doc.toJson().constData());
    m_file.close();
}

bool JsonDb::remove(const QString & _id)
{

    for (int i = 0; i < m_records.size(); ++i)
        if(m_records[i].id == _id) {
            return remove(i); // then save
        }
    return false;
}

bool JsonDb::remove(const int &_index)
{
    if (_index < 0 || _index >= rowCount())
        return false;
    m_records.removeAt(_index);

    save();
    return true;
}

bool JsonDb::add(const Record & _record)
{
    return insert(_record, rowCount());
}

bool JsonDb::insert(const Record &_record, const int &_index)
{
    if (_index < 0 || _index > rowCount())
        return false;

    Record newRecord = _record;
    // pseudo random ID
    newRecord.id = QString("id_%1_%2").arg(QDateTime::currentMSecsSinceEpoch()).arg(rand());

    if (_index == rowCount())
        m_records.append(newRecord);
    else
        m_records.insert(_index, newRecord);

    save();
    return true;
}

int JsonDb::rowCount() const
{
    return m_records.length();
}

bool JsonDb::get(const QString & _id, Record &_record) const
{
    for (int i = 0; i < m_records.size(); ++i)
        if(m_records[i].id == _id)
            return get(i, _record);
    return false;
}

bool JsonDb::get(const int &_index, Record &_record) const
{
    if (_index < 0 || _index >= rowCount())
        return false;

    _record = m_records.at(_index);
    return true;
}

bool JsonDb::set(const QString &_id, const Record &_record)
{
    for (int i = 0; i < m_records.size(); ++i)
        if(m_records[i].id == _id)
            return set(i, _record);
    return false;
}

bool JsonDb::set(const int &_index, const Record &_record)
{
    if (_index < 0 || _index >= rowCount())
        return false;

    m_records[_index] = _record;
    save();
    return true;
}

int JsonDb::indexOf(const QString &_id)
{
    for (int i = 0; i < m_records.size(); ++i)
        if(m_records[i].id == _id)
            return i;
    return -1;
}

void JsonDb::sort()
{
    std::sort(m_records.begin(), m_records.end(), [](const Record & l, const Record & r) {
        return l.dt < r.dt;
    });
}

#include <QUrl>
bool JsonDb::exportToFile()
{
    LOGI();

    // android workaround
    QString dir = "/storage/emulated/0/";

    const auto from = QUrl(m_file.fileName());
    const auto to = dir + from.fileName();

    LOGI(QString("exporting from %1").arg(from.path()));
    LOGI(QString("to %1").arg(to));

    QFile file(to);
    if (!file.open(QIODevice::WriteOnly)) {
        LOGE(QString("Canot open file %1").arg(file.fileName()));
        return false;
    }

    openFile();
    file.resize(0);
    if (file.write(m_file.readAll()) == 0) {
        LOGE("Write error!");
        file.close();
        return false;
    }
    file.close();

    return true;
}

bool JsonDb::importFromFile()
{
    LOGI();

    const auto from = QFileDialog::getOpenFileName(nullptr, "Select a .json file",
                                                    "", "JSON file (*.json)");
    const auto to = m_file.fileName();

    LOGI(from);
    if (!from.endsWith(".json"))
        return false;

    if (m_file.isOpen()) {
        m_file.close();
    }

    LOGI(QString("importing from %1").arg(from));
    LOGI(QString("to %1").arg(to));

    if (QFile::exists(to)) {
        LOGI("removing old file...");
        QFile::remove(to);
    }

    if (!QFile::copy(from, to)) {
        LOGE("Copy error!");
        return false;
    }

    return true;
}

JsonDb::JsonDb()
{
}

JsonDb::~JsonDb()
{
    if(m_file.isOpen()) {
        save();
        m_file.close();
    }
}

bool JsonDb::openFile()
{
    LOGI("opening file");
    if (m_file.isOpen()) {
        LOGI("file is already opened!");
    }
    if (m_file.fileName().length() == 0) {
        LOGI("Invalid filename");
        return false;
    }

    m_file.open(QIODevice::ReadWrite | QIODevice::Text);
    return true;
}

void JsonDb::parseFile()
{
    openFile();

    if (m_file.size() == 0)
        return;

    auto json = m_file.readAll();
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(json, &error);
    LOGI(QString("File size: %1").arg(m_file.size()));

    if (error.error != QJsonParseError::ParseError::NoError) {
        LOGI(QString("file is corrupted or empty, msg: %1").arg(error.errorString()));
        m_file.close();
        {
            QFile::remove(m_file.fileName());
            openFile();

            if (m_file.size() == 0)
                return;

            auto json = m_file.readAll();
            QJsonParseError error;
            QJsonDocument doc = QJsonDocument::fromJson(json, &error);
            LOGI(QString("File size: %1").arg(m_file.size()));
        }

       /* m_file.setFileName("other_" + m_file.fileName());

        LOGI("create another file with empty json");
        m_file.open(QIODevice::ReadWrite | QIODevice::Text);
        m_file.write("{}");
        m_file.close();
        m_file.open(QIODevice::ReadWrite | QIODevice::Text);
        json = m_file.readAll();

        doc = QJsonDocument::fromJson(json, &error);

        if (error.error != QJsonParseError::ParseError::NoError) {
            LOGI(QString("file is corrupted or empty, or no permission to read/write, msg: %1")
                 .arg(error.errorString()));
        }*/
    }

    //    LOGI(QString("json: %1").arg(doc.toJson().toStdString().c_str()));

    for (const auto & v : doc.array()) {
        auto data = v.toVariant().toMap();
        Record r;
        r.id = data.value("id", "").toString();
        r.dt = QDateTime::fromMSecsSinceEpoch(data.value("timestamp", 0).toLongLong());
        r.title = data.value("title", "").toString();
        r.amount = data.value("amount", 0).toLongLong();

        auto enumString = data.value("type", "EXPENSE").toString();
        if (enumString.length() > 0) {
            auto && metaEnum = QMetaEnum::fromType<Enums::RecordType>();
            r.type = static_cast<Enums::RecordType>(metaEnum.keyToValue(enumString.toUtf8()));
        }

        if(r.id.length() == 0)
            continue;

        m_records.push_back(r);
    }

    LOGI(QString("record count for month: %1").arg(m_records.length()));

    sort();
    save();
}
