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
    [alert setMessageText:@"Disclaimer & Info"];
    [alert setInformativeText:@"This app requires full disk access. Please enable it for the App in System Preferences.\n\nThis app is for easy information gathering only. It is intended to be run on a booted image of a logged in system, to which you have access to the password for the administrators password. \n\nAlso, as this entire application is a fight against Apple's normal application controls, as well as... Catalina being Catalina. Don't be shocked if somethings wonky. My MacBook Pro has crashed more timed developing this than in the 4 years I have owned it. It seems to be tied to file operations, especially those using uncompiled AppleScript. It was never as a result of running the app itself, so it shouldnt be an issue, but if you begin to add your own functions, dont be suprised if you experience similar things."];
    [alert addButtonWithTitle:@"Ok"];
    [alert runModal];
    ArtifactFinder *stuff = [[NSClassFromString(@"ArtifactFinder") alloc] init];
    
//    [stuff setVars];
//    NSNumber *result = [stuff checkPasswd: @"caT"];
//    NSLog(@"Result: %@", result);
    
    return NSApplicationMain(argc, argv);
}


