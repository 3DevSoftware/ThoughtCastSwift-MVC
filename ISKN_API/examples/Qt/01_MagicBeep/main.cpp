
#include <QApplication>
#include "MagicBeep.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    new MagicBeep();

    return a.exec();
}
