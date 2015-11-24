//
//  PrefController.h
//  Coccinellida
//  
//  Licensed under GPL v3 Terms
//
//  Created by Dmitry Geurkov on 10/5/09.
//  Copyright 2009-2011. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>


@interface PrefController : NSObject {
	
	IBOutlet SUUpdater* updater;
	
	IBOutlet NSWindow* prefWindow;
	
	IBOutlet NSToolbar* toolbar;
	
	IBOutlet NSTabView* tabView;
	
	IBOutlet NSToolbarItem* generalToolbarItem;
	
	IBOutlet NSToolbarItem* tunnelsToolbarItem;
	
	IBOutlet NSButton* lanchOnStartupButton;
	IBOutlet NSButton* soundEffectsButton;
	IBOutlet NSButton* growlNotificationsButton;
	IBOutlet NSButton* checkForUpdatesButton;
	
	IBOutlet NSTableView* tunnelsList;

}

- (IBAction) showPrefWindow: (id) sender;

- (IBAction) enableSoundEffects: (id) sender;

- (IBAction) enableGrowlNotifications: (id) sender;

- (IBAction) checkForUpdates: (id) sender;

- (IBAction) launchOnStartup: (id) sender;

- (IBAction) selectGeneral: (id) sender;

- (IBAction) selectTunnels: (id) sender;


- (int) loginItemIndex: (NSURL*) url;

@end
