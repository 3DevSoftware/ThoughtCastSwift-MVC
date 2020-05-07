//
//  MagicBeep.cpp
//  MagicBeep
//
//  Created by ALOUI Rabeb on 16/02/15.
//  Copyright (c) 2015 ISKN. All rights reserved.
//

#include "MagicBeep.h"

MagicBeep * magicBeep ;


// Cpp/Objective-C Wrapper function

extern "C"
void launchMagicBeep(ViewController *viewController)
{
    try
    {
        magicBeep=new MagicBeep(viewController);
    }
    catch (Error &err)
    {
        NSLog(@"Error");
    }
}

//MagicBeep constructor

MagicBeep::MagicBeep(ViewController *viewController)
{
    
    // Create slate manager
    iskn_SlateManager  = new SlateManager();
    
    //Register the MagicBeep class as a Listener
    iskn_SlateManager->registerListener(this) ;
    
    
    //Send the connect command
    NSLog(@"Attempting to connect to ISKN Slate...");
    addTextToView(@"Attempting to connect to ISKN Slate...");
    iskn_SlateManager->connect() ;
    
    // Get a pointer to the ViewController
    this->viewController=viewController;
    
    //Create first sound path
    NSURL *soundURL1=[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Beep" ofType:@"wav"]];
    // Create the first sound
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) soundURL1, &beepTone1);
    
    
    //Create second sound path
    NSURL *soundURL2=[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Beep 2" ofType:@"wav"]];
    // Create the second sound
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) soundURL2, &beepTone2);
    
    
    //Create third sound path
    NSURL *soundURL3=[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Beep 3" ofType:@"wav"]];
    // Create the third sound
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) soundURL3, &beepTone3);
    
}

void MagicBeep::connectionStatusChanged(bool connected)
{
    if(connected)
    {
        // Request Slate description
        iskn_SlateManager->request(REQ_DESCRIPTION);
        
        // Subscribe to events (Status, Software events, Hardware events and Pen 2D event)
        
        iskn_SlateManager->subscribe(
                                 AUTO_STATUS |
                                 AUTO_SOFTWARE_EVENTS |
                                 AUTO_HARDWARE_EVENTS |
                                 AUTO_PEN_2D
                                 ) ;
        addTextToView(@"[Connected]");
    }
    else
    {
        addTextToView(@"[Could not connect]");
    }
}


void MagicBeep::processEvent(ISKN_API::Event &event, timecode_t timecode)
{
    switch (event.Type)
    {
        case EVT_STATUS :
        {
            EventStatus &ev=event.Status ;
            int bat=ev.getBattery() ;
            addTextToView([NSString stringWithFormat:@"Battery %d", bat]) ;
        }
            break ;
            
        case EVT_PEN_2D :
        {
            EventPen2D &ev=event.Pen2D ;
            Vector2D po=ev.getPosition() ;
            NSLog(@"%@", [NSString stringWithFormat:@"EvtPen2D : %d : (%f , %f)\n", ev.Touch() ? 1 : 0, po.X, po.Y]) ;
        
        }
            break ;
            
        case EVT_HARDWARE :
        {
            EventHardware &ev=event.HardwareEvent ;
            switch (ev.getHardwareEventType())
            {
                case HE_BUTTON1_PRESSED :
                    addTextToView([NSString stringWithFormat:@"Button 1 pressed"]) ;
                    break ;
                case HE_BUTTON2_PRESSED :
                    addTextToView([NSString stringWithFormat:@"Button 2 pressed"]) ;
                    break ;
                default :
                    break ;
            }
        }
            break ;
            
        case EVT_DESCRIPTION :
        {
            EventDescription &ev=event.Description ;
            NSString *nss_deviceName=[NSString stringWithUTF8String:ev.getDeviceName()];
            addTextToView([@"Connected to slate " stringByAppendingString:nss_deviceName]) ;
        }
            break ;
            
            
        case EVT_SOFTWARE :
        {
            EventSoftware &ev=event.SoftwareEvent ;
            switch (ev.getSoftwareEventType())
            {
                case SE_OBJECT_IN :
                {
                    addTextToView([NSString stringWithFormat:@"Object in"]) ;
                    playSound(1);
                }
                    break ;
                case SE_OBJECT_OUT :
                {
                    addTextToView([NSString stringWithFormat:@"Object out"]) ;
                    playSound(2);
                }
                    break;
                case SE_HANDSHAKE:
                    // Nothing to do
                    break;
                    
                case SE_UNKNOWN:
                    // Nothing to do
                    break;
            }
        }
            break ;
            
        default :
        break ;
            
}
    
}

// addTextToView function

void MagicBeep::addTextToView(NSString *str)
{
    viewController.maintext.stringValue=[viewController.maintext.stringValue stringByAppendingString:str] ;
    viewController.maintext.stringValue=[viewController.maintext.stringValue stringByAppendingString:@"\n"] ;
    NSLog(@"%@", str) ;
}

// playSound function

void MagicBeep::playSound(int soundID)
{
    switch (soundID)
    {
        case  1:
        {
            AudioServicesPlaySystemSound(beepTone1);
        }
            break ;
            
        case  2:
        {
            AudioServicesPlaySystemSound(beepTone2);
        }
            break ;
            
        default:
        {
            AudioServicesPlaySystemSound(beepTone3);
        }
            break ;
            
    }
}

//Convert to NSString function

NSString* MagicBeep::WString2NSString(const std::wstring& ws)
{
    NSString* result = [[NSString alloc] initWithBytes:ws.data() length:ws.size()*sizeof(wchar_t)  encoding:NSUTF32LittleEndianStringEncoding];
    return result;
}



