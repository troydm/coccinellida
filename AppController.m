//
//  AppController.m
//  Coccinellida
//  
//  Licensed under GPL v3 Terms
//
//  Created by Dmitry Geurkov on 9/25/09.
//  Copyright 2009-2011. All rights reserved.
//

#import "AppController.h"
#import "Tunnel.h"


@implementation AppController

- (id) init {
	if(self = [super	init]){
		//NSRect screenSize = [[NSScreen mainScreen] visibleFrame];
	}
    
	return (self);
}

- (void) awakeFromNib {
        
    [aboutLabel setStringValue: [NSString stringWithFormat: @"%@ v%@", [aboutLabel stringValue], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]]];
	
	statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
	
	[statusBarItem setMenu: statusMenu];
	
	[statusBarItem setToolTip: @"CocTunnel"];
	
	[statusBarItem setEnabled: YES];
	
	[statusBarItem setImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"taskicon" ofType:@"png"]]];
	
	[statusMenu setAutoenablesItems: NO];
	
	[NSApp setMainMenu:dummyMenu];
}

- (IBAction) showAboutWindow: (id) sender {
	if(![aboutWindow isVisible]){
		NSRect screenSize = [[NSScreen mainScreen] visibleFrame];
		NSRect w = [aboutWindow frame];
		w.origin.x = screenSize.size.width - w.size.width - 20;
		w.origin.y = screenSize.size.height  - w.size.height - 20;
		[aboutWindow setFrameOrigin: w.origin];
		[aboutWindow orderFront: sender];
	}
}

@end
