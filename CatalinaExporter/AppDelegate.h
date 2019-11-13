//
//  AppDelegate.h
//  CatalinaExporter
//
//  Created by Andrew Afonso on 11/11/19.
//  Copyright © 2019 Andrew Afonso. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;


@end

