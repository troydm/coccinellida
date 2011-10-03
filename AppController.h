//
//  AppController.h
//  Coccinellida
//  
//  Licensed under GPL v3 Terms
//
//  Created by Dmitry Geurkov on 9/25/09.
//  Copyright 2009-2011. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject {
	
	IBOutlet NSApplication* app;
	
	IBOutlet NSMenu* statusMenu;
	
	IBOutlet NSMenu* dummyMenu;
	
	IBOutlet NSPanel* aboutWindow;
    
    IBOutlet NSTextField* aboutLabel;    
		
	NSStatusItem* statusBarItem;
}

- (IBAction) showAboutWindow: (id) sender;

@end
