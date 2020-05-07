/**
 * \file main.cpp
 * \brief Demo ISKN API
 * \author ISKN
 * \version 0.1
 * \date 21 janvier 2015
 *
 * This file is part of the examples of the ISKN API.
 *
 * Demonstrate the possibilities given by the ISKN API for developping drawing applications.
 *
 */


#include <QApplication>
#include <iostream>

#include "WritingWindow.h"

using namespace std;
int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    WritingWindow w;
    w.show();


    return a.exec();
}
