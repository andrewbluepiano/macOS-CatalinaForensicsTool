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
    ArtifactFinder *stuff = [[NSClassFromString(@"ArtifactFinder") alloc] init];
    
//    [stuff setVars];
//    NSNumber *result = [stuff checkPasswd: @"caT"];
//    NSLog(@"Result: %@", result);
    
    return NSApplicationMain(argc, argv);
}


