#-------------------------------------------------
#
# Project created by QtCreator 2015-01-29T11:41:49
#
#-------------------------------------------------

QT       += core

QT       -= gui

TARGET = MyFirstTest
CONFIG   += console
CONFIG   -= app_bundle

TEMPLATE = app


SOURCES += main.cpp \
    myfirsttest.cpp

HEADERS += \
    myfirsttest.h

win32:CONFIG(release, debug|release): LIBS += -L$$PWD/../../../ISKN_API/x86_MingW/lib/ -lISKN_API
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/../../../ISKN_API/x86_MingW/lib/ -lISKN_APId
else:unix: LIBS += -L$$PWD/../../../ISKN_API/x86_MingW/lib/ -lISKN_API

INCLUDEPATH += $$PWD/../../../ISKN_API/x86_MingW/include
DEPENDPATH += $$PWD/../../../ISKN_API/x86_MingW/include

QMAKE_CFLAGS = -std=c++11
QMAKE_CXXFLAGS = -std=c++11
QMAKE_LFLAGS = -std=c++11
