//
//  main.m
//  CatalinaExporter
//
//  Created by Andrew Afonso on 11/11/19.
//  Copyright © 2019 Andrew Afonso. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>
#import "ArtifactFinder.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
    }
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Disclaimer"];
    [alert setInformativeText:@"This app is for easy information gathering only. Forensically speaking, it should only be run on a image of a live system. \n\nAlso, as this entire application is a fight against Apple's normal application controls, don't be shocked if somethings wonky. My MacBook Pro has crashed more timed developing this than in the 4 years I have owned it. Never as a result of running the app itself, so it shouldnt be an issue, but if you begin to add your own functions, dont be suprised if you experience similar things."];
    [alert addButtonWithTitle:@"Ok"];
    [alert runModal];
    ArtifactFinder *stuff = [[NSClassFromString(@"ArtifactFinder") alloc] init];
    
//    [stuff setVars];
//    NSNumber *result = [stuff checkPasswd: @"caT"];
//    NSLog(@"Result: %@", result);
    
    return NSApplicationMain(argc, argv);
}


