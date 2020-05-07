#include "slatetheremin.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    SlateTheremin w;
    w.show();

    return a.exec();
}
