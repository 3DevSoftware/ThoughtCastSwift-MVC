#-------------------------------------------------
#
# Project created by QtCreator 2015-01-14T15:49:56
#
#-------------------------------------------------

QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = MagicBeep
TEMPLATE = app
CONFIG += console


SOURCES += main.cpp\
    MagicBeep.cpp


HEADERS  +=ISKN_API.h\
    MagicBeep.h


win32:{
    INCLUDEPATH += "$$PWD/../../../ISKN_API/x86_MingW/include"
    DEPENDPATH += "$$PWD/../../../ISKN_API/x86_MingW/bin"
    LIBS += -L"$$PWD/../../../ISKN_API/x86_MingW/bin"
    LIBS += -L"$$PWD/../../../ISKN_API/x86_MingW/lib"

    CONFIG(release, debug|release): {
        LIBS +=  -lISKN_API
    }
    else:CONFIG(debug, debug|release):{
        LIBS += -lISKN_APId
    }
}

QMAKE_CFLAGS = -std=c++11
QMAKE_CXXFLAGS = -std=c++11
QMAKE_LFLAGS = -std=c++11

