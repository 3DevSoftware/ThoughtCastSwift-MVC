#include <QCoreApplication>

#include <iostream>

#include "ISKN_API.h"
using namespace std;

using namespace ISKN_API;


int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    cout<<"Hello World !"<<endl;

    return a.exec();
}
