#ifndef THESLATE_H
#define THESLATE_H

#include "ISKN_API.h"
#include <QString>
#include <iostream>
#include <windows.h>

using namespace ISKN_API;
using namespace std;

class MagicBeep : public ISKN_API::Listener
{

public:



    // ISKN API attributes
    SlateManager   *iskn_SlateManager;
    Device      *iskn_Device;

    //Application specific attributes
    Vector3D prevPos;
    int spectrumMultiplier;

    //Constructor
    MagicBeep();
    ~MagicBeep();

    //Inherited methods
    void processEvent(Event &e, unsigned int timecode);
    void connectionStatusChanged(bool connected);
};

#endif // THESLATE_H
