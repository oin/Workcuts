//
//  WorkcutsPreferencesController.m
//  Workcuts
//
//  Created by Jonathan Aceituno on 17/11/11.
//  Copyright 2011 Jonathan Aceituno. All rights reserved.
//

#import "WorkcutsPreferencesController.h"

#import "PTKeyCombo.h"
#import "PTKeyComboPanel.h"


@implementation WorkcutsPreferencesController

-(id)init
{
	self = [super initWithWindowNibName:@"Preferences"];
	return self;
}

-(void)awakeFromNib
{
	id c = [[NSUserDefaults standardUserDefaults] objectForKey: @"ShortcutKeyCombo"];
	id currentCombo = [[[PTKeyCombo alloc] initWithPlistRepresentation: c] autorelease];
	[keyComboField setStringValue:[currentCombo description]];
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
