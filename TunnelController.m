//
//  TunnelController.m
//  Coccinellida
//  
//  Licensed under GPL v3 Terms
//
//  Created by Dmitry Geurkov on 6/8/10.
//  Copyright 2010-2011. All rights reserved.
//

#import "TunnelController.h"
#import "Tunnel.h"
#import <Growl.h>

@implementation TunnelController

- (void) awakeFromNib {
	
	[GrowlApplicationBridge setGrowlDelegate:self];
	
	onSound = [[NSSound alloc] initWithContentsOfFile: [[NSBundle bundleForClass:[self class]] pathForResource: @"on" ofType: @"mp3"] byReference: YES];
	[onSound setVolume: 0.2];
	offSound = [[NSSound alloc] initWithContentsOfFile: [[NSBundle bundleForClass:[self class]] pathForResource: @"off" ofType: @"mp3"] byReference: YES];
	[offSound setVolume: 0.2];
	
	NSData* tunnelData = [[NSUserDefaults standardUserDefaults] dataForKey: @"tunnels"];
	if(tunnelData == nil)	
		tunnels = [NSMutableArray new];
	else
		tunnels = (NSMutableArray*) [NSKeyedUnarchiver unarchiveObjectWithData: tunnelData];
	
	[tunnelsList setDataSource:(id<NSTableViewDataSource>)self];
	[portForwardingList setDataSource:(id<NSTableViewDataSource>)self];
	
	[self rebuildMenuList];
	
	if( [tunnels count] > 0){
		[editTunnelButton setEnabled: YES];
		[deleteTunnelButton setEnabled: YES];
	}else{
		[editTunnelButton setEnabled: NO];
		[deleteTunnelButton setEnabled: NO];
	}
	
	exitThread = NO;
	[NSThread detachNewThreadSelector: @selector(checkTunnels) toTarget:self withObject:nil ];	
}

- (NSDictionary *) registrationDictionaryForGrowl {
	NSArray* notifications = [NSArray arrayWithObjects: @"Tunnel Started", @"Tunnel Stopped", @"Time Out", @"Connection Established", @"Connection Refused", @"Connection Error", @"Wrong Password" , nil];
	NSDictionary* dict = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: notifications, notifications, nil ]					
					forKeys: [NSArray arrayWithObjects: GROWL_NOTIFICATIONS_ALL, GROWL_NOTIFICATIONS_DEFAULT, nil] ];
	return dict;
}

-(void) checkTunnels {
	while(!exitThread){
		@synchronized(self){
			int i = 0;
			for(Tunnel* t in tunnels){
				if( [t delegate] == nil )
					[t setDelegate: self];
				[t readStatus];
				if( [t running] == YES && [t checkProcess] == NO ){
					[t stop];
					[NSThread sleepForTimeInterval:2];
					[t start];
				}
				[[[statusMenu itemArray] objectAtIndex: i+3] setState: [t running] ? NSOnState : NSOffState]; 
				i++;
			}
		}
		[NSThread sleepForTimeInterval:3];
	}
}

-(void) tunnelStatusChanged: (Tunnel*) tunnel status: (NSString*) status {
	
	if( [status isEqualToString: @"START"] ){
		if ( [soundEffectsButton state] == NSOnState )
			[onSound play];
	
		if ( [growlNotificationsButton state] == NSOnState )
			[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"Tunnel %@", [tunnel name]] description: @"Tunnel started " notificationName: @"Tunnel Started" iconData: nil priority: 0 isSticky: NO clickContext: nil];
	}
	
	if( [status isEqualToString: @"STOP"] ){
		if ( [soundEffectsButton state] == NSOnState )
			[offSound play];
	
		if ( [growlNotificationsButton state] == NSOnState )
			[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"Tunnel %@", [tunnel name]] description: @"Tunnel stopped " notificationName: @"Tunnel Stopped" iconData: nil priority: 0 isSticky: NO clickContext: nil];
	}
	
	if( [status isEqualToString: @"TIME_OUT"] ){
		if ( [growlNotificationsButton state] == NSOnState )
			[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"Tunnel %@", [tunnel name]] description: @"Time out occured " notificationName: @"Time Out" iconData: nil priority: 0 isSticky: NO clickContext: nil];
	}
	
	if( [status isEqualToString: @"CONNECTED"] ){
		if ( [growlNotificationsButton state] == NSOnState )
			[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"Tunnel %@", [tunnel name]] description: @"Connection established" notificationName: @"Connection Established" iconData: nil priority: 0 isSticky: NO clickContext: nil];
	}
	
	if( [status isEqualToString: @"WRONG_PASSWORD"] ){
		if ( [growlNotificationsButton state] == NSOnState )
			[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"Tunnel %@", [tunnel name]] description: @"Login/Password incorrect" notificationName: @"Wrong Password" iconData: nil priority: 0 isSticky: NO clickContext: nil];
		
		passwordChangeTunnel = tunnel;
		[passwordChangeTextField setStringValue: @""];
		[passwordWindow setTitle: [NSString stringWithFormat: @"%@ incorrect password", [tunnel name]]];
		[passwordWindow center];
		[NSApp runModalForWindow: passwordWindow];
		[NSApp endSheet: passwordWindow];
		
		if(passwordChanged){
			[tunnel stop];
			[tunnel start];
		}else{		
			[tunnel stop];
			NSAlert* alert = [NSAlert new];
			[[alert window] center];
				
			[alert addButtonWithTitle:@"Close"];
			[alert setMessageText: [NSString stringWithFormat: @"Tunnel %@ Problem",[tunnel name]]];
			[alert setInformativeText:@"Login/Password incorrect"];
		
			[alert beginSheetModalForWindow: nil modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
		}
	}
	
	if( [status isEqualToString: @"CONNECTION_REFUSED"] ){
		if ( [growlNotificationsButton state] == NSOnState )
			[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"Tunnel %@", [tunnel name]] description: @"Connection refused" notificationName: @"Connection Refused" iconData: nil priority: 0 isSticky: NO clickContext: nil];
		
		[tunnel stop];
		NSAlert* alert = [NSAlert new];
		[[alert window] center];
		
		[alert addButtonWithTitle:@"Close"];
		[alert setMessageText: [NSString stringWithFormat: @"Tunnel %@ Problem",[tunnel name]]];
		[alert setInformativeText:@"Connection refused"];
		
		[alert beginSheetModalForWindow: nil modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
	}
	
	if( [status isEqualToString: @"CONNECTION_ERROR"] ){
		if ( [growlNotificationsButton state] == NSOnState )
			[GrowlApplicationBridge notifyWithTitle: [NSString stringWithFormat: @"Tunnel %@", [tunnel name]] description: @"Connection error" notificationName: @"Connection Error" iconData: nil priority: 0 isSticky: NO clickContext: nil];
	}
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	
}

- (void) applicationWillTerminate: (NSNotification*) notification {
	exitThread = YES;
	@synchronized(self){
		for(Tunnel* t in tunnels){
			if( [t running] )
				[t stop];
		}
	}
}

- (IBAction) chooseIdentityFile: (id) sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    
    [panel setShowsHiddenFiles: YES];
    
    [panel beginSheetForDirectory: @"~"
                             file:nil
                   modalForWindow: tunnelWindow
                    modalDelegate:self
                   didEndSelector:@selector(chooseIdentityFileDidEnd:
                                            returnCode:
                                            contextInfo:)
                      contextInfo:nil];
}

- (void)chooseIdentityFileDidEnd: (NSOpenPanel*)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSOKButton)
    {
        [identityTextField setStringValue: [panel filename]];
        [self prepareSSHCommand: nil];
	}
}

- (IBAction) changePassword: (id) sender {
	passwordChanged = YES;
	[NSApp endSheet: passwordWindow];
	[passwordWindow orderOut: self];
	[passwordChangeTunnel setPassword: [passwordChangeTextField stringValue]];
	passwordChangeTunnel = nil;
	[self saveTunnelsData];
}

- (IBAction) cancelPasswordChange: (id) sender {
	passwordChanged = NO;
	passwordChangeTunnel = nil;
	[NSApp endSheet: passwordWindow];
	[passwordWindow orderOut: self];
}

- (IBAction) saveEditDialog: (id) sender {
	if ( [[nameTextField stringValue] length] > 0){
		[selectedTunnel setName: [nameTextField stringValue]];
		[selectedTunnel setHost: [hostTextField stringValue]];
		[selectedTunnel setPort: [[portTextField stringValue] intValue]];
		[selectedTunnel setUser: [userTextField stringValue]];
		[selectedTunnel setPassword: [passwordTextField stringValue]];
        [selectedTunnel setIdentity: [identityTextField stringValue]];
		[selectedTunnel setSocksHost: [socksHostTextField stringValue]];
		[selectedTunnel setSocksPort: [[socksPortTextField stringValue] intValue]];
		[selectedTunnel setConnectionTimeout: [[connectionTimeoutTextField stringValue] intValue]];
		[selectedTunnel setAliveInterval: [[aliveIntervalTextField stringValue] intValue]];
		[selectedTunnel setAliveCountMax: [[aliveCountMaxTextField stringValue] intValue]];
		[selectedTunnel setTcpKeepAlive: [tcpKeepAliveCheckBox state] == NSOnState ? YES : NO];
		[selectedTunnel setCompression: [compressionCheckBox state] == NSOnState ? YES : NO];
		[selectedTunnel setAdditionalArgs: [additionalArgsTextField string]];
		[selectedTunnel setPortForwardings: [NSMutableArray arrayWithArray: portForwardings]];
		
		if(selectedTunnelIndex == -1){
			[self addTunnel: selectedTunnel];
		}else{
			[self editTunnel: selectedTunnelIndex];
		}
		
		[self closeEditDialog: sender];
	}
}

- (IBAction) closeEditDialog: (id) sender {
	[tunnelWindow orderOut: self];
	[portForwardings dealloc];
	portForwardings = nil;
	[NSApp stopModal];
	selectedTunnel = nil;
	selectedTunnelIndex = -1;
}

- (IBAction) buttonAddTunnel: (id) sender {
	selectedTunnel = [Tunnel new];
	selectedTunnelIndex = -1;
	portForwardings = [NSMutableArray array];
	[nameTextField setStringValue: @""];
	[hostTextField setStringValue: @""];
	[portTextField setStringValue: @"22"];
	[userTextField setStringValue: @""];
	[passwordTextField setStringValue: @""];
    [identityTextField setStringValue: @""];
	[socksHostTextField setStringValue: @""];
	[socksPortTextField setStringValue: @""];
	[connectionTimeoutTextField setStringValue: @"15"];
	[aliveIntervalTextField setStringValue: @"30"];
	[aliveCountMaxTextField setStringValue: @"3"];
	[tcpKeepAliveCheckBox setState: NSOffState];	
	[compressionCheckBox setState: NSOffState];	
	[additionalArgsTextField setString: @""];
	[sshCommandTextField setString: @""];
	[tabView selectTabViewItemAtIndex: 0];
	[NSApp beginSheet: tunnelWindow
	   modalForWindow: prefWindow
		modalDelegate: nil
	   didEndSelector: nil
		  contextInfo: nil];
	[NSApp runModalForWindow: tunnelWindow];
	[NSApp endSheet: tunnelWindow];
	[tunnelWindow orderOut: self];
}

- (IBAction) buttonEditTunnel: (id) sender {
	if( [tunnelsList selectedRow] != -1){
		@synchronized(self){
			selectedTunnel = [tunnels objectAtIndex: [tunnelsList selectedRow]];
		}
		selectedTunnelIndex = [tunnelsList selectedRow];
		portForwardings = [selectedTunnel portForwardings];
		[nameTextField setStringValue: [selectedTunnel name]];
		[hostTextField setStringValue: [selectedTunnel host]];
		[portTextField setStringValue: [[NSNumber numberWithInt: [selectedTunnel port]] stringValue]];
		[userTextField setStringValue: [selectedTunnel user]];
		[passwordTextField setStringValue: [selectedTunnel password]];
        [identityTextField setStringValue: [selectedTunnel identity]];
		[socksHostTextField setStringValue: [selectedTunnel socksHost]];
		[socksPortTextField setStringValue: [[NSNumber numberWithInt: [selectedTunnel socksPort]] stringValue]];
		[connectionTimeoutTextField setStringValue: [[NSNumber numberWithInt: [selectedTunnel connectionTimeout]] stringValue]];
		[aliveIntervalTextField setStringValue: [[NSNumber numberWithInt: [selectedTunnel aliveInterval]] stringValue]];
		[aliveCountMaxTextField setStringValue: [[NSNumber numberWithInt: [selectedTunnel aliveCountMax]] stringValue]];
		[tcpKeepAliveCheckBox setState: [selectedTunnel tcpKeepAlive] == YES ? NSOnState : NSOffState];	
		[compressionCheckBox setState: [selectedTunnel compression] == YES ? NSOnState : NSOffState];	
		[additionalArgsTextField setString: [selectedTunnel additionalArgs]];
		[sshCommandTextField setString: [[selectedTunnel prepareSSHCommandArgs] objectAtIndex: 0]];
		
		[tabView selectTabViewItemAtIndex: 0];
		[NSApp beginSheet: tunnelWindow
		   modalForWindow: prefWindow
			modalDelegate: nil
		   didEndSelector: nil
			  contextInfo: nil];
		[NSApp runModalForWindow: tunnelWindow];
		[NSApp endSheet: tunnelWindow];
		[tunnelWindow orderOut: self];
	}
}

- (IBAction) buttonDeleteTunnel: (id) sender {
	@synchronized(self){
		if( [tunnels count] > 0)
			[self deleteTunnel: [tunnelsList selectedRow]];
		
		if( [tunnels count] > 0){
			[editTunnelButton setEnabled: YES];
			[deleteTunnelButton setEnabled: YES];
		}else{
			[editTunnelButton setEnabled: NO];
			[deleteTunnelButton setEnabled: NO];
		}
	}
}

-(void) addTunnel: (Tunnel*) tunnel {
	@synchronized(self){
		[tunnels addObject: tunnel];
		[self rebuildMenuList];
		[tunnelsList reloadData];
		
		if( [tunnels count] > 0){
			[editTunnelButton setEnabled: YES];
			[deleteTunnelButton setEnabled: YES];
		}else{
			[editTunnelButton setEnabled: NO];
			[deleteTunnelButton setEnabled: NO];
		}
		
		NSData* tunnelData = [NSKeyedArchiver archivedDataWithRootObject: tunnels];	
		[[NSUserDefaults standardUserDefaults] setObject: tunnelData forKey: @"tunnels"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

-(void) editTunnel: (int) indexToEdit {
	@synchronized(self){
		[self saveTunnelsData];
	}
}

-(void) saveTunnelsData {
	[self rebuildMenuList];
	[tunnelsList reloadData];
	
	NSData* tunnelData = [NSKeyedArchiver archivedDataWithRootObject: tunnels];	
	[[NSUserDefaults standardUserDefaults] setObject: tunnelData forKey: @"tunnels"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) deleteTunnel: (int) indexToRemove {
	@synchronized(self){
		Tunnel* t = (Tunnel*)[tunnels objectAtIndex: indexToRemove];
		if( [t running] )
			[t stop];
		
		[tunnels removeObjectAtIndex: indexToRemove];
		
		[t tunnelRemoved];
		
		[self rebuildMenuList];
		[tunnelsList reloadData];
		
		if( [tunnels count] > 0){
			[editTunnelButton setEnabled: YES];
			[deleteTunnelButton setEnabled: YES];
		}else{
			[editTunnelButton setEnabled: NO];
			[deleteTunnelButton setEnabled: NO];
		}
		
		NSData* tunnelData = [NSKeyedArchiver archivedDataWithRootObject: tunnels];	
		[[NSUserDefaults standardUserDefaults] setObject: tunnelData forKey: @"tunnels"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

-(void) rebuildMenuList {
	int i = 0;
	int c = [[statusMenu itemArray] count];
	for(i=0;i<(c-5);i++){
		[statusMenu removeItemAtIndex: 3];
	}
	if( [tunnels count] > 0){
	i = 0;
	for(Tunnel* t in tunnels){
		NSMenuItem* m = [NSMenuItem new];
		[m setTitle: [t name]];
		[m setAction: @selector(startStopTunnel:)];
		[m setTarget: self];
		[m setEnabled: YES];
		[m setState: [t running] == YES ? NSOnState : NSOffState];
		[statusMenu insertItem: m atIndex: 3+i];
		i++;
	}
	}else{
		NSMenuItem* m = [NSMenuItem new];
		[m setTitle: @"No Tunnels"];
		[m setEnabled: NO];
		[statusMenu insertItem: m atIndex: 3];
	}
}

-(IBAction) startStopTunnel: (id) sender {
	NSMenuItem* m = (NSMenuItem*)sender;
	passwordChanged = NO;
	int i = 0;
	int menuIndex = -1;
	for(NSMenuItem* mi in [statusMenu itemArray]){
		if(mi == m){
			menuIndex = i-3;
			break;
		}
		i++;
	}
	if(menuIndex != -1){
		Tunnel* t = nil;
		@synchronized(self){
			t = [tunnels objectAtIndex: menuIndex];
		}
		if( t != nil){
			if( [t running] )
				[t stop];
			else
				[t start];
			[m setState: [t running] == YES ? NSOnState : NSOffState];
		}
	}
}

- (IBAction) addPortForwardDialog: (id) sender {
	[portForwardings insertObject: @"L:Type Port:localhost:Type Host:Type Port" atIndex: [portForwardings count]];
	[portForwardingList reloadData];
	[self prepareSSHCommand: nil];
}

- (IBAction) removePortForwardDialog: (id) sender {
	if( [portForwardingList selectedRow] >= 0){
		[portForwardings removeObjectAtIndex: [portForwardingList selectedRow]];
		[portForwardingList reloadData];
		[self prepareSSHCommand: nil];
	}
}

- (id) tableView: (NSTableView *) tableView objectValueForTableColumn: (NSTableColumn*) tableColumn row: (int) rowIndex {  
	if( tableView == tunnelsList){	
		return [[tunnels objectAtIndex: rowIndex] name];
	}else{
		NSString* portForwarding = [portForwardings objectAtIndex: rowIndex];
		NSArray* arr = [portForwarding componentsSeparatedByString: @":"];
		
		uint index = [[portForwardingList tableColumns] indexOfObject: tableColumn];
		if( index == 0)
			return [[arr objectAtIndex: 0] isEqualTo: @"L"] ? @"Local" : @"Remote";
		else
			return [arr objectAtIndex: index];
	}
}

- (void)tableView:(NSTableView *) tableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn*) tableColumn row: (int)rowIndex {
    if( tableView != tunnelsList){
		NSString* portForwarding = [portForwardings objectAtIndex: rowIndex];
		NSMutableArray* arr = [NSMutableArray arrayWithArray: [portForwarding componentsSeparatedByString: @":"]];
		uint index = [[portForwardingList tableColumns] indexOfObject: tableColumn];
		
		if(index == 0)
			anObject = [anObject isEqualTo: @"Local"] ? @"L" : @"R";
		else if(index == 1 || index == 4)
			anObject = [NSString stringWithFormat:@"%i", [anObject intValue]];
		
		[arr replaceObjectAtIndex: index withObject: anObject];
		
		portForwarding = [arr componentsJoinedByString: @":"];
		[portForwardings replaceObjectAtIndex: rowIndex withObject: portForwarding];
		[portForwardingList reloadData];
		[self prepareSSHCommand: nil];
    }
}

- (int) numberOfRowsInTableView: (NSTableView*) tableView {
	if( tableView == tunnelsList){	
		return [tunnels count];
	}else{
		return [portForwardings count];
	}	
}

- (IBAction) prepareSSHCommand: (id) sender {
	Tunnel* tmp = [Tunnel new];
	[tmp setName: [nameTextField stringValue]];
	[tmp setHost: [hostTextField stringValue]];
	[tmp setPort: [[portTextField stringValue] intValue]];
	[tmp setUser: [userTextField stringValue]];
	[tmp setPassword: [passwordTextField stringValue]];
	[tmp setIdentity: [identityTextField stringValue]];
	[tmp setSocksHost: [socksHostTextField stringValue]];
	[tmp setSocksPort: [[socksPortTextField stringValue] intValue]];
	[tmp setConnectionTimeout: [[connectionTimeoutTextField stringValue] intValue]];
	[tmp setAliveInterval: [[aliveIntervalTextField stringValue] intValue]];
	[tmp setAliveCountMax: [[aliveCountMaxTextField stringValue] intValue]];
	[tmp setTcpKeepAlive: [tcpKeepAliveCheckBox state] == NSOnState ? YES : NO];
	[tmp setCompression: [compressionCheckBox state] == NSOnState ? YES : NO];
	[tmp setAdditionalArgs: [additionalArgsTextField string]];
	[tmp setPortForwardings: [NSMutableArray arrayWithArray: portForwardings]];
	
	[sshCommandTextField setString: [[tmp prepareSSHCommandArgs] objectAtIndex: 0]];
}

- (void) controlTextDidChange: (NSNotification*) notification {
	[self prepareSSHCommand: nil];
}
	
- (void) textDidChange: (NSNotification*) notification {
	[self prepareSSHCommand: nil];
}

@end
