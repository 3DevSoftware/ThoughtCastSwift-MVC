//
//  MagicBeep.h
//  MagicBeep
//
//  Created by ALOUI Rabeb on 16/02/15.
//  Copyright (c) 2015 ISKN. All rights reserved.
//

#ifndef __MagicBeep__MagicBeep__
#define __MagicBeep__MagicBeep__

#include <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ViewController.h"

#include "ISKN_API.h"

using namespace ISKN_API;

// Listener class
class MagicBeep : public Listener
{
    
public:
    
    // ISKN API attributes
    SlateManager * iskn_SlateManager ;
    
    // Application specific attributes
    SystemSoundID beepTone1,beepTone2,beepTone3;
    ViewController *viewController;
    
    // Constructor
    MagicBeep(ViewController *viewController);
    
    // Inherited attributes
    void connectionStatusChanged(bool connected);
    void processEvent(ISKN_API::Event &event, unsigned int timecode);
    
    // Application specific methods
    void addTextToView(NSString *str);
    void playSound(int soundID);
    NSString* WString2NSString(const std::wstring& ws);
    
    
};




#endif /* defined(__MagicBeep__MagicBeep__) */
