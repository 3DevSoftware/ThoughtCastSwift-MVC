#-------------------------------------------------
#
# Project created by QtCreator 2015-01-26T10:14:58
#
#-------------------------------------------------

QT       += core gui multimedia

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = SlateTheremin
TEMPLATE = app

QMAKE_CFLAGS = -std=gnu++11
QMAKE_CXXFLAGS = -std=gnu++11
QMAKE_LFLAGS = -std=gnu++11


SOURCES += main.cpp \
    slatetheremin.cpp

HEADERS  += slatetheremin.h

FORMS    += \
    slatetheremin.ui


win32:{
    INCLUDEPATH += $$PWD/../../../ISKN_API/x86_MingW/include
    DEPENDPATH += $$PWD/../../../ISKN_API/x86_MingW/bin
    LIBS += -L$$PWD/../../../ISKN_API/x86_MingW/bin
    LIBS += -L$$PWD/../../../ISKN_API/x86_MingW/lib

    CONFIG(release, debug|release): {
        LIBS +=  -lISKN_API
    }
    else:CONFIG(debug, debug|release):{
        LIBS += -lISKN_APId
    }
}

macx:{
    INCLUDEPATH += "$$PWD/../../../ISKN_API/x64_MACOS_Clang/include"
    #-DYLIB (.a/.dll) IN /usr/local/lib --> CP dans POSTBUILD
    #DEPENDPATH += "$$PWD/../ISKN_API/x64_MACOS_Clang/bin"
    LIBS += -L"$$PWD/../../../ISKN_API/x64_MACOS_Clang/bin"

    CONFIG(release, debug|release): {
        LIBS += -L/usr/local/lib -lISKN_API
    }
    else:CONFIG(debug, debug|release):{
        LIBS += -L/usr/local/lib -lISKN_APId
    }
}


linux:{
    DEFINES+=linux

    INCLUDEPATH += $$PWD/../../../ISKN_API/x64_Linux_GCC/include
    DEPENDPATH += $$PWD/../../../ISKN_API/x64_Linux_GCC/bin
    LIBS += -L$$PWD/../../../ISKN_API/x64_Linux_GCC/bin

    LIBS += -lISKN_API
}

ios:{
    INCLUDEPATH += $$PWD/../../../ISKN_API/arm_iOS/include
    LIBS += -L$$PWD/../../../ISKN_API/arm_iOS/lib

    LIBS += -lISKN_API

    LIBS += -framework CoreBluetooth
}

RESOURCES += \
    resources.qrc

