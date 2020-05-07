//
//  ScannerEvent.h
//  ISKN_API
//
//  Created by ALOUI Rabeb on 12/04/15.
//  Copyright (c) 2015 ISKN. All rights reserved.
//

#import <Foundation/Foundation.h>


    typedef enum ScannerEvent {
        BLESCANNER_EVENT_NONE,
        BLESCANNER_EVENT_ACTIVATION_REQUIRED,
        BLESCANNER_EVENT_BLE_NOT_SUPPORTED,
        BLESCANNER_EVENT_BLE_SCAN_STARTED
    }ScannerEvent;
