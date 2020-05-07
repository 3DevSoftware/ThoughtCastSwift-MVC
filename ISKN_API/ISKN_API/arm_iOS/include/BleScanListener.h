//
//  BleScanListener.h
//  ISKN_API
//
//  Created by ALOUI Rabeb on 12/04/15.
//  Copyright (c) 2015 ISKN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#include "ScannerEvent.h"

class BleScanListener{
public:
    virtual void newDeviceFound(CBPeripheral *p_device)=0;
    virtual void notify(ScannerEvent evt)=0;
    virtual void scanFinished()=0;
};