#ifndef LOGGER_H
#define LOGGER_H

#define _LOG(level, text) qDebug() << QString("%1 %2 %3 [%4] %5")\
    .arg(\
    QString(#level)\
    ,QString(__FILE__)\
    ,QString(__FUNCTION__)\
    ,QString::number(__LINE__)\
    ,QString(text))

#define LOGI(text) _LOG(I, text)
#define LOGD(text) _LOG(D, text)
#define LOGE(text) _LOG(E, text)
#endif // LOGGER_H
