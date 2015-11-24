//
//  TunnelController.h
//  Coccinellida
//  
//  Licensed under GPL v3 Terms
//
//  Created by Dmitry Geurkov on 6/8/10.
//  Copyright 2010-2011. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import "Tunnel.h"


@interface TunnelController : NSObject <GrowlApplicationBridgeDelegate> {
	
	IBOutlet NSWindow* prefWindow;
	IBOutlet NSWindow* tunnelWindow;
	IBOutlet NSWindow* passwordWindow;
	
	IBOutlet NSTabView* tabView;
	IBOutlet NSButton* soundEffectsButton;
	IBOutlet NSButton* growlNotificationsButton;
	
	IBOutlet NSTextField* nameTextField;
	IBOutlet NSButton* autostartCheckBox;
	IBOutlet NSTextField* hostTextField;
	IBOutlet NSTextField* portTextField;
	IBOutlet NSTextField* userTextField;
	IBOutlet NSSecureTextField* passwordTextField;
    IBOutlet NSTextField* identityTextField;
	IBOutlet NSTextField* socksHostTextField;
	IBOutlet NSTextField* socksPortTextField;
	IBOutlet NSTextField* connectionTimeoutTextField;
	IBOutlet NSTextField* aliveIntervalTextField;
	IBOutlet NSTextField* aliveCountMaxTextField;
	IBOutlet NSButton* tcpKeepAliveCheckBox;
	IBOutlet NSButton* compressionCheckBox;
	IBOutlet NSTextView* additionalArgsTextField;
	IBOutlet NSTextView* sshCommandTextField;
	
	IBOutlet NSTableView* portForwardingList;	
	IBOutlet NSButton* addPortForwardingButton;
	IBOutlet NSButton* removePortForwardingButton;
	
	IBOutlet NSSecureTextField* passwordChangeTextField;
	
	NSMutableArray* tunnels;
	Tunnel* passwordChangeTunnel;
	BOOL passwordChanged;
	Tunnel* selectedTunnel;
	uint selectedTunnelIndex;
	BOOL exitThread;
	NSMutableArray* portForwardings;
	
	NSSound* onSound;
	NSSound* offSound;
	
	IBOutlet NSMenu* statusMenu;
	IBOutlet NSTableView* tunnelsList;
	
	IBOutlet NSButton* addTunnelButton;
	IBOutlet NSButton* editTunnelButton;
	IBOutlet NSButton* deleteTunnelButton;
}

-(void) checkTunnels;

-(void) tunnelStatusChanged: (Tunnel*) tunnel status: (NSString*) status;

- (IBAction) chooseIdentityFile: (id) sender;

- (IBAction) changePassword: (id) sender;

- (IBAction) cancelPasswordChange: (id) sender;
	
- (IBAction) saveEditDialog: (id) sender;
- (IBAction) closeEditDialog: (id) sender;

- (IBAction) buttonAddTunnel: (id) sender;
- (IBAction) buttonEditTunnel: (id) sender;
- (IBAction) buttonDeleteTunnel: (id) sender;

- (IBAction) addPortForwardDialog: (id) sender;
- (IBAction) removePortForwardDialog: (id) sender;

-(void) addTunnel: (Tunnel*) tunnel;
-(void) editTunnel: (int) indexToEdit;
-(void) saveTunnelsData;
-(void) deleteTunnel: (int) indexToRemove;

-(void) rebuildMenuList;

-(IBAction) startStopTunnel: (id) sender;

- (IBAction) prepareSSHCommand: (id) sender;

@end
