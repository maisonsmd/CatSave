TEMPLATE = app
QT += quick quickcontrols2 core widgets

CONFIG += c++11
ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android-sources

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        jsondb.cpp \
        main.cpp \
        monthlylist.cpp \
        typefilterproxymodel.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target


HEADERS += \
    enums.h \
    jsondb.h \
    logger.h \
    monthlylist.h \
    typefilterproxymodel.h

DISTFILES += \
    android-sources/AndroidManifest.xml
