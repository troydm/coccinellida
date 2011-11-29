//
//  PrefController.m
//  Coccinellida
//  
//  Licensed under GPL v3 Terms
//
//  Created by Dmitry Geurkov on 10/5/09.
//  Copyright 2009-2011. All rights reserved.
//

#import "PrefController.h"
#import "LoginItemsAE.h"


@implementation PrefController

- (void) awakeFromNib {
	
	[toolbar setSelectedItemIdentifier: [generalToolbarItem itemIdentifier]];
	[tabView selectTabViewItem:[tabView tabViewItemAtIndex: 0]];
	[self selectGeneral: nil];
	
	if( [[NSUserDefaults standardUserDefaults] objectForKey: @"sound"] == nil){
		[[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"sound"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	if( [[NSUserDefaults standardUserDefaults] objectForKey: @"growl"] == nil){
		[[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"growl"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	if( [[NSUserDefaults standardUserDefaults] objectForKey: @"update"] == nil){
		[[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"update"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	[soundEffectsButton setState: [[NSUserDefaults standardUserDefaults] boolForKey: @"sound"] ? NSOnState : NSOffState];
	[growlNotificationsButton setState: [[NSUserDefaults standardUserDefaults] boolForKey: @"growl"] ? NSOnState : NSOffState];
	[checkForUpdatesButton setState: [[NSUserDefaults standardUserDefaults] boolForKey: @"update"] ? NSOnState : NSOffState];
	
	// Check for updates
	[updater setAutomaticallyChecksForUpdates: [checkForUpdatesButton state] == NSOnState ? YES : NO];
	[updater resetUpdateCycle];
	
	// Check startup on login
	NSURL* url = [NSURL fileURLWithPath: [[NSBundle mainBundle] bundlePath]];
	int ind = [self loginItemIndex: url];
	if(ind == -1){
		[lanchOnStartupButton setState: NSOffState];
	}else{
		[lanchOnStartupButton setState: NSOnState];
	}
}

- (IBAction) enableSoundEffects: (id) sender {
	[[NSUserDefaults standardUserDefaults] setBool: [soundEffectsButton state] == NSOnState forKey: @"sound"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction) enableGrowlNotifications: (id) sender {
	[[NSUserDefaults standardUserDefaults] setBool: [growlNotificationsButton state] == NSOnState forKey: @"growl"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction) checkForUpdates: (id) sender {
	[[NSUserDefaults standardUserDefaults] setBool: [checkForUpdatesButton state] == NSOnState forKey: @"update"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[updater setAutomaticallyChecksForUpdates: [checkForUpdatesButton state] == NSOnState ? YES : NO];
	[updater resetUpdateCycle];
}

- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar {	
    return [NSArray arrayWithObjects: [generalToolbarItem itemIdentifier], [tunnelsToolbarItem itemIdentifier], nil];
}

- (IBAction) showPrefWindow: (id) sender {
	[toolbar setSelectedItemIdentifier: [generalToolbarItem itemIdentifier]];
	if(![prefWindow isVisible]){
		[prefWindow center];
	}
	[prefWindow orderFrontRegardless];
	[self selectGeneral: sender];
}

- (IBAction) selectGeneral: (id) sender {
	[tabView selectTabViewItem:[tabView tabViewItemAtIndex: 0]];
	NSRect r = [prefWindow frame];
	r.origin.x = [prefWindow frame].origin.x - (350 - [prefWindow frame].size.width);
    r.origin.y = [prefWindow frame].origin.y - (230 - [prefWindow frame].size.height);
    r.size.width = 350;
	r.size.height = 230;
	[prefWindow setFrame: r display: YES animate: YES];
}

- (IBAction) selectTunnels: (id) sender {
	[tabView selectTabViewItem:[tabView tabViewItemAtIndex: 1]];
	NSRect r = [prefWindow frame];
	r.origin.x = [prefWindow frame].origin.x - (480 - [prefWindow frame].size.width);
    r.origin.y = [prefWindow frame].origin.y - (380 - [prefWindow frame].size.height);
    r.size.width = 480;
	r.size.height = 380;
    [prefWindow setFrame: r display: YES animate: YES];
}

- (IBAction) launchOnStartup: (id) sender {
	NSURL* url = [NSURL fileURLWithPath: [[NSBundle mainBundle] bundlePath]];
	
	if([lanchOnStartupButton state] == NSOnState){
		int ind = [self loginItemIndex: url];
		if(ind == -1){
			LIAEAddURLAtEnd((CFURLRef)url, YES);
		}		
	}else{
		int ind = [self loginItemIndex: url];
		if(ind != -1){
			LIAERemove(ind);
		}
	}
}

- (int) loginItemIndex: (NSURL*) url {
	NSArray* items = nil;
	LIAECopyLoginItems((CFArrayRef*) &items);
	
	int i = 0;
	for(NSDictionary* d in items){
		if([[d valueForKey: (NSString*)kLIAEURL] isEqual: url]){
			return i; 
		}
		i++;
	}
	
	return -1;
}


@end
