#include "MagicBeep.h"

// This is a little piano application using ISKN slate
// Each Pen has a different tone range
// Y axis of the tablet is the frequency
// X axis is the duration
// To play a tone touch the surface with the pen
// Enjoy

int toneMultiplier[5] = {0, 2, 5, 10, 15 };

MagicBeep::MagicBeep()
{
    prevPos = { 0.0f, 0.0f, 0.0f };
    spectrumMultiplier = 5;

    // Create SlateManager and Device
    iskn_SlateManager  = new SlateManager();
    iskn_Device     = &iskn_SlateManager->getDevice();

    // Register events Listener
    iskn_SlateManager->registerListener(this);

    // Connect to the Slate
    cout << "Attempting to connect to ISKN Slate ..." << endl;
    iskn_SlateManager->connect();

}

void MagicBeep::connectionStatusChanged(bool connected)
{
    try
    {
        if (connected)
        {
            // Request Slate description
            iskn_SlateManager->request(REQ_DESCRIPTION);
            // Subscribe to events (Status event, Software events, Hardware events and Pen 3D event)
            iskn_SlateManager->subscribe(AUTO_STATUS | AUTO_SOFTWARE_EVENTS | AUTO_HARDWARE_EVENTS | AUTO_PEN_3D);
            cout << "Slate connected !" << endl;
        }
        else
        {
            cout << "Slate could not connect !" << endl;
        }
    }
    catch (Error &err)
    {
        wcout << err.Message() << endl;
    }
}


void MagicBeep::processEvent(Event &e, unsigned int timecode)
{
    switch (e.Type)
    {
    case EVT_STATUS:
        cout<<"Battery : "<<iskn_Device->getBatteryCharge()<<endl;
        break ;
    case EVT_DESCRIPTION:
        cout<<"Device name: "<<iskn_Device->getDeviceName()<<endl;
        break;
    case EVT_SOFTWARE:
        switch (e.SoftwareEvent.getSoftwareEventType())
        {
        case SE_OBJECT_IN :
            cout<<"Pen in : "<<e.SoftwareEvent.getObjectID()<<endl;
            spectrumMultiplier = toneMultiplier[e.SoftwareEvent.getObjectID()];
            cout << "Tone changed : " << spectrumMultiplier << endl;
            break ;
        case SE_OBJECT_OUT :
            cout << " -----------------" << endl;
            break ;

        case SE_HANDSHAKE :
            break ;

        case SE_UNKNOWN :
            break ;

        }
        break ;

    case EVT_HARDWARE:
        cout << "Device hardware event : " << e.HardwareEvent.getHardwareEventType() << endl;
        switch (e.HardwareEvent.getHardwareEventType())
        {
        case HE_BUTTON1_PRESSED:
            cout << "Button 1 pressed" << endl;
            break;
        case HE_BUTTON2_PRESSED:
            cout << "Button 2 pressed" << endl;
            break;
        case HE_BUTTON1_LONGPRESS:
            cout << "Button 1 long pressed" << endl;
            break;
        case HE_BUTTON2_LONGPRESS:
            cout << "Button 2 long pressed" << endl;
            break;
        case HE_SDCARD_IN:
            // not used in this example
            break;

        case HE_SDCARD_OUT:
            // not used in this example
            break;

        case HE_UNKNOWN:
            // not used in this example
            break;
        case HE_REFRESH_DONE:
            // not used in this example
            break;
        }
        break;

    case EVT_PEN_3D :
    {
        // Get pen tip position
        Vector3D pos = e.Pen3D.getPosition();

        // Compute tone parameters
        DWORD freq = pos.Y*spectrumMultiplier;
        DWORD duration = pos.X * 2;

        // Detect that the pen tip has exceeded the 15mm threshold
        if (prevPos.Z>15 && pos.Z<15)
        {
            // Display frequency bar
            cout << "Freq ";
            for (int i = 0; i < (int)pos.Y/10; i++)
                cout << "|";
            cout << endl;

            // Display duration bar
            cout << "Dur ";
            for (int i = 0; i < (int)pos.X / 10; i++)
                cout << "-";
            cout << endl;

            // Play tone
            Beep(freq, duration);
        }
        prevPos = pos;
    }
        break ;

    default:
        if (e.Type>=EVT_ERROR)
            cout<<"Event : "<<(int)e.Type<<endl;
        break ;
    }

    // Unused variable
    (void)timecode;
}

MagicBeep::~MagicBeep()
{
}

