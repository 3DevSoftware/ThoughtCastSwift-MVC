//
//  MagicBeep.cpp
//  MagicBeep
//
//  Created by ALOUI Rabeb on 08/02/15.
//  Copyright (c) 2015 ISKN. All rights reserved.
//

#include "MagicBeep.h"

MagicBeep * magicBeep ;


// Cpp/Objective-C Wrapper function

extern "C"
{
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

    void deviceSelected(int deviceID)
    {
        magicBeep->iskn_SlateManager->stopScan();
        CBPeripheral *p_device =magicBeep->iskn_SlateManager->getDeviceByID(deviceID);
        magicBeep->iskn_SlateManager->connect(p_device);
        [magicBeep->viewController.devicesList setHidden:YES];
 
    }
}

//MagicBeep constructor
MagicBeep::MagicBeep(ViewController *viewController)
{
    // Get a pointer to the ViewController
    this->viewController=viewController;
    
    // Create slate manager
    iskn_SlateManager  = new SlateManager();
    
    //Register the MagicBeep class as a Listener
    iskn_SlateManager->registerListener(this) ;
    
   
    addTextToView(@"Scan for ISKN Slates...\n");
    
    // Scan for devices
    iskn_SlateManager->startScan(this);
    
    [viewController.activityIndicator startAnimating];
    
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
// newDeviceFound function

void MagicBeep::newDeviceFound(CBPeripheral *p_device)
{
    NSLog(@"Device found %@",p_device.name);
    [viewController.myData addObject:p_device.name];
    [viewController.devicesList reloadData];
}

// connectionStatusChanged function 

void MagicBeep::connectionStatusChanged(bool connected)
{
    if(connected){
        // Request Slate description
        iskn_SlateManager->request(REQ_DESCRIPTION);
        
        // Subscribe to events (Status, Software events, Hardware events and Pen 2D event)
        iskn_SlateManager->subscribe(
                                 AUTO_STATUS |
                                 AUTO_SOFTWARE_EVENTS |
                                 AUTO_HARDWARE_EVENTS |
                                 AUTO_PEN_2D
                                 ) ;
        
        viewController.activityIndicator.hidesWhenStopped=true;
        [viewController.activityIndicator stopAnimating];
        
        NSLog(@"[Connected]\n");
    }
    else
    {
        addTextToView(@"[Could not connect]\n");
        NSLog(@"[Could not connect]\n");
    }
}

// processEvent function

void MagicBeep::processEvent(Event &event, unsigned int timecode)
{
    switch (event.Type)
    {
        case EVT_STATUS :
        {
            EventStatus &ev=event.Status ;
            int bat=ev.getBattery() ;
            addTextToView([NSString stringWithFormat:@"Battery %d\n", bat]) ;
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
                    addTextToView([NSString stringWithFormat:@"Button 1 pressed\n"]) ;
                    break ;
                case HE_BUTTON2_PRESSED :
                    addTextToView([NSString stringWithFormat:@"Button 2 pressed\n"]) ;
                    break ;
                case HE_BUTTON1_LONGPRESS:
                    addTextToView([NSString stringWithFormat:@"Button 1 long pressed\n"]) ;
                    break;
                case HE_BUTTON2_LONGPRESS:
                    addTextToView([NSString stringWithFormat:@"Button 2 long pressed\n"]) ;
                    break;
                default :
                    break ;
            }
        }
            break ;
            
        case EVT_DESCRIPTION :
        {
            EventDescription &ev=event.Description ;
            NSString *nss_deviceName = [NSString stringWithUTF8String:ev.getDeviceName()];
            
            [viewController.connectionStatus setTitle:[@"Connected to Slate " stringByAppendingString: nss_deviceName]];

            addTextToView([NSString stringWithFormat:@"Connected to Slate : %@\n", nss_deviceName]) ;
        }
            break ;
            
            
        case EVT_SOFTWARE :
        {
            EventSoftware &ev=event.SoftwareEvent ;
            
            switch (ev.getSoftwareEventType())
            {
                case SE_OBJECT_IN :
                {
                    addTextToView([NSString stringWithFormat:@"Object in \n"]) ;
                    playSound(1);
                }
                    break ;
                case SE_OBJECT_OUT :
                {
                    addTextToView([NSString stringWithFormat:@"Object out \n"]) ;
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
    viewController.mainText.text=[viewController.mainText.text stringByAppendingString:str] ;
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
void MagicBeep::notify(ScannerEvent evt)
{
    switch(evt){
        case BLESCANNER_EVENT_NONE:
            //...
            break;
        case BLESCANNER_EVENT_ACTIVATION_REQUIRED:
            NSLog(@"Notification received");
            break;
        case BLESCANNER_EVENT_BLE_NOT_SUPPORTED:
            NSLog(@"BLE not supported");
            break;
        case BLESCANNER_EVENT_BLE_SCAN_STARTED:
            NSLog(@"Scan started");
            break;
            
    }
    
}
void MagicBeep::scanFinished()
{
    NSLog(@"Scan finished");
    
}

