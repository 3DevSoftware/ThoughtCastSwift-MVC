//
//  MagicBeep.h
//  MagicBeep
//
//  Created by ALOUI Rabeb on 08/02/15.
//  Copyright (c) 2015 ISKN. All rights reserved.
//

#ifndef __MagicBeep__MagicBeep__
#define __MagicBeep__MagicBeep__

#include <ISKN_API.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ViewController.h"


using namespace ISKN_API;

class MagicBeep :public Listener, BleScanListener
{
    
public:
    
    // ISKN API attributes
    SlateManager   *iskn_SlateManager;
    
    // Application specific attributes
    SystemSoundID beepTone1,beepTone2,beepTone3;
    ViewController *viewController;
    
    // Constructor
    MagicBeep(ViewController *viewController);
    
    // Inherited methods
    
    // Listener
    void connectionStatusChanged(bool connected);
    void processEvent(ISKN_API::Event &event, unsigned int timecode);
    
    // BleScanListener
    void newDeviceFound(CBPeripheral *p_device);
    void notify(ScannerEvent evt);
    void scanFinished();
    
    // Application specific methods
    void addTextToView(NSString *str);
    void playSound(int soundID);
};


#endif /* defined(__MagicBeep__MagicBeep__) */
