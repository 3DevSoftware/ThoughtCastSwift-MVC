//
//  ViewController.m
//  MagicBeep
//
//  Created by ALOUI Rabeb on 16/02/15.
//  Copyright (c) 2015 ISKN. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize maintext;

extern void launchMagicBeep(ViewController* viewController) ;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    launchMagicBeep(self) ;

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
