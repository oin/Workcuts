//
//  WorkcutsPreferencesController.m
//  Workcuts
//
/* This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details. */

#import "WorkcutsPreferencesController.h"

#import "PTKeyCombo.h"
#import "PTKeyComboPanel.h"


@implementation WorkcutsPreferencesController

-(id)init
{
	self = [super initWithWindowNibName:@"Preferences"];
	
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

-(void)awakeFromNib
{
	id c = [[NSUserDefaults standardUserDefaults] objectForKey: @"ShortcutKeyCombo"];
	id currentCombo = [[[PTKeyCombo alloc] initWithPlistRepresentation: c] autorelease];
	[keyComboField setStringValue:[currentCombo description]];
	
	// Set the settings sets
	[settingsSets removeAllItems];
	NSString *pathOfScript = [[NSBundle mainBundle] pathForResource:@"ListTerminalSettingsSets" ofType:@"scpt"];
	NSDictionary *errors = [NSDictionary dictionary];
	NSAppleScript *script = [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:pathOfScript] error:&errors];
	
	NSAppleEventDescriptor *desc = [script executeAndReturnError:nil];
	
	int count = [desc numberOfItems];
	
	for(int i=0; i<count; ++i) {
		if([[desc descriptorAtIndex:i] stringValue] != nil) {
			[settingsSets addItemWithTitle:[[desc descriptorAtIndex:i] stringValue]];
		}
	}
	
	[settingsSets selectItemWithTitle:[[NSUserDefaults standardUserDefaults] stringForKey:@"TerminalSettingsSet"]];
	
	[script release];
}

-(IBAction)setGlobalShortcut:(id)sender
{
	id c = [[NSUserDefaults standardUserDefaults] objectForKey: @"ShortcutKeyCombo"];
	id currentCombo = [[[PTKeyCombo alloc] initWithPlistRepresentation: c] autorelease];
	PTKeyComboPanel* panel = [PTKeyComboPanel sharedPanel];
	[panel setKeyCombo: currentCombo];
	[panel setKeyBindingName: @"Workcuts"];
	[panel runSheeetForModalWindow: [self window] target: self];
}

-(void)hotKeySheetDidEndWithReturnCode:(NSNumber*)resultCode
{
	if([resultCode intValue] == NSOKButton) {
		id newCombo = [[PTKeyComboPanel sharedPanel] keyCombo];
		[[NSUserDefaults standardUserDefaults] setObject:[newCombo plistRepresentation] forKey:@"ShortcutKeyCombo"];
		[keyComboField setStringValue:[newCombo description]];
	}
}

@end
