//
//  WorkcutsAppDelegate.m
//  Workcuts
//
/* This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details. */

#import "WorkcutsAppDelegate.h"

#import "PTHotKey.h"
#import "PTHotKeyCenter.h"

@implementation WorkcutsAppDelegate

-(id)init
{
	self = [super init];
	if(self == nil)
		return nil;
	
	evalErrorSheet = nil;
	manager = [[WorkcutsManager alloc] init];
	
	return self;
}

-(void)dealloc
{
	[manager release];
	[statusMenu release];
	[activateMenuItem release];
	//[clearRecentsMenuItem release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[NSBundle loadNibNamed:@"CommandOutput" owner:self];
	
	// Load the standard user defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
	
	// Load and create the hot key
	PTKeyCombo* keyCombo = nil;
	id keyComboPlist;
	keyComboPlist = [[NSUserDefaults standardUserDefaults] objectForKey: @"ShortcutKeyCombo"];
	keyCombo = [[[PTKeyCombo alloc] initWithPlistRepresentation: keyComboPlist] autorelease];
	shortcutsMenuHotKey = [[PTHotKey alloc] initWithIdentifier:@"ShortcutKeyCombo" keyCombo:keyCombo];
	[shortcutsMenuHotKey setTarget:self];
	[shortcutsMenuHotKey setAction:@selector(popupMenu:)];
	[[PTHotKeyCenter sharedCenter] registerHotKey:shortcutsMenuHotKey];
	
	// Bind
	[self bind:@"showsStatusItem" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:@"values.ShowStatusItem" options:nil];
	[self bind:@"showsProjectTitleInStatusItem" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:@"values.ShowProjectTitleInStatusItem" options:nil];
	[self bind:@"showsProjectTitleInDock" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:@"values.ShowProjectTitleInDock" options:nil];
	[self bind:@"shortcutKeyCombo" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:@"values.ShortcutKeyCombo" options:nil];
	
	// Subscribe to notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldRefresh:) name:@"ReloadShortcuts" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showEvalError:) name:@"WorkcutsEvalError" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeEvalError:) name:@"WorkcutsEvalSuccess" object:nil];
	
	[manager initProject];
}

-(void)showEvalError:(NSNotification*)theNotification
{
	BOOL ok = NO;
	if(!evalErrorSheet) {
		[NSBundle loadNibNamed:@"ErrorSheet" owner:self];
		ok = YES;
	}
	
	NSDictionary *info = [theNotification userInfo];
	
	[errorView setString:[NSString stringWithFormat:@"%@\n%@", [info objectForKey:@"name"], [info objectForKey:@"error"]]];
	[errorView setFont:[NSFont userFixedPitchFontOfSize:10]];
	
	if(ok)
		[[NSApplication sharedApplication] beginSheet:evalErrorSheet modalForWindow:nil modalDelegate:self didEndSelector:@selector(didEndEvalErrorSheet:returnCode:contextInfo:) contextInfo:nil];
}

-(void)closeEvalError:(NSNotification*)theNotification
{
	if(evalErrorSheet) {
		[self closeErrorSheet:nil];
	}
	
	NSDictionary *info = [theNotification userInfo];

	if([info objectForKey:@"stdout"] != nil && [[[info objectForKey:@"stdout"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {;
		[cmdOutputView setString: [info objectForKey:@"stdout"]];
		[cmdOutputView setFont:[NSFont userFixedPitchFontOfSize:10]];
		[cmdOutputWindow makeKeyAndOrderFront:nil];
	}
}

-(IBAction)closeErrorSheet:(id)sender
{
	[[NSApplication sharedApplication] endSheet:evalErrorSheet];
}

-(void)didEndEvalErrorSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [evalErrorSheet orderOut:self];
	evalErrorSheet = nil;
}

-(void)shouldRefresh:(NSNotification*)theNotification
{
	[self refresh];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[[PTHotKeyCenter sharedCenter] unregisterHotKey: shortcutsMenuHotKey];
	
	[shortcutsMenuHotKey release];
}

-(NSDictionary*)shortcutKeyCombo
{
	return [[shortcutsMenuHotKey keyCombo] plistRepresentation];
}

-(void)setShortcutKeyCombo:(id)value
{
	id combo = [[[PTKeyCombo alloc] initWithPlistRepresentation: value] autorelease];
	[shortcutsMenuHotKey setKeyCombo:combo];
	[[PTHotKeyCenter sharedCenter] registerHotKey:shortcutsMenuHotKey];
}

-(IBAction)popupMenu:(id)sender
{
	if([manager hasCurrentProject]) {
		NSEvent *e = [NSEvent mouseEventWithType:NSLeftMouseDown location:NSMakePoint(0, 0) modifierFlags:0 timestamp:0 windowNumber:0 context:nil eventNumber:0 clickCount:1 pressure:0];
		[NSMenu popUpContextMenu:shortcutsMenu withEvent:e forView:nil];
	}
}

-(void)awakeFromNib
{
	// Observe
	[manager addObserver:self forKeyPath:@"currentProjectPath" options:nil context:nil];
	// Retain commonly removed and added things
	[activateMenuItem retain];
	
	[self rebuildRecentProjectsMenu];
	
	[self refresh];
	[self updateDockIcon];
}

-(void)refresh
{
	[self rebuildShortcutsMenu];
	[self updateStatusItem];
	[self rebuildStatusMenu];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqual:@"currentProjectPath"] && object == manager) {
		// The current project has changed !
		[self refresh];
		[self rebuildRecentProjectsMenu];
		[self updateDockIcon];
	}
}

-(BOOL)showsStatusItem
{
	return nil != statusItem;
}

-(void)setShowsStatusItem:(BOOL)value
{
	if(value != [self showsStatusItem]) {
		if(value) {
			statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
			[statusItem setMenu: statusMenu];
			[statusItem setHighlightMode:YES];
			[statusItem setImage:[NSImage imageNamed:@"StatusItem"]];
			[statusItem setAlternateImage:[NSImage imageNamed:@"StatusItemAlternate"]];
			[self updateStatusItem];
		} else {
			[[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
			[statusItem release];
			statusItem = nil;
		}
	}
}

-(BOOL)showsProjectTitleInStatusItem
{
	return showsProjectTitleInStatusItem;
}

-(void)setShowsProjectTitleInStatusItem:(BOOL)value
{
	if(value != [self showsProjectTitleInStatusItem]) {
		showsProjectTitleInStatusItem = value;
		[self updateStatusItem];
	}
}

-(BOOL)showsProjectTitleInDock
{
	return showsProjectTitleInDock;
}

-(void)setShowsProjectTitleInDock:(BOOL)value
{
	if(value != [self showsProjectTitleInDock]) {
		showsProjectTitleInDock = value;
		[self updateDockIcon];
	}
}

-(void)updateStatusItem
{
	if([self showsStatusItem]) {
		if([manager hasCurrentProject] && [self showsProjectTitleInStatusItem]) {
			NSMutableAttributedString* statusItemTitle = [[[NSAttributedString alloc] initWithString:[[manager currentProject] title] attributes:[NSDictionary dictionaryWithObject:[NSFont menuBarFontOfSize:10] forKey:NSFontAttributeName]] autorelease];
			[statusItem setAttributedTitle:statusItemTitle];
		} else {
			[statusItem setTitle:nil];
		}
	}
}

-(NSString*)dockString:(NSString*)string byTruncatingToWidth:(int)width withFont:(NSFont**)theFont
{
	NSString *family = @"American Typewriter";
	NSFontTraitMask traits = NSBoldFontMask;
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
	NSFont *font = [fontManager fontWithFamily:family traits:traits weight:0 size:13];
	NSString *ellipsis =  [NSString stringWithUTF8String:"…"];
	NSMutableString *truncatedString = [[string mutableCopy] autorelease];
	
	if ([string sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]].width > width)
	{
		width -= [ellipsis sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]].width;
		
		NSRange range = NSMakeRange([truncatedString length] - 1, 1);
		
		while([truncatedString sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]].width > width) {
			[truncatedString deleteCharactersInRange:range];
			range.location--;
		}
		
		[truncatedString replaceCharactersInRange:range withString:ellipsis];
	}
	
	*theFont = font;
	
	return truncatedString;
}

-(void)updateDockIcon
{
	NSImage *dockIcon = [[[NSImage alloc] initWithSize:NSMakeSize(128,128)] autorelease];
	
	[dockIcon lockFocus];
	// Draw the app icon
	if([manager hasCurrentProject] && [self showsProjectTitleInDock])
		[[NSImage imageNamed:@"WorkcutsOpenIcon"] dissolveToPoint:NSZeroPoint fraction:1.0];
	else
		[[NSImage imageNamed:@"NSApplicationIcon"] dissolveToPoint:NSZeroPoint fraction:1.0];
	// Draw the project name
	if([manager hasCurrentProject] && [self showsProjectTitleInDock]) {
		NSMutableParagraphStyle *pstyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
		[pstyle setAlignment:NSCenterTextAlignment];
		
		NSFont *font;
		NSString *str = [self dockString:[[manager currentProject] title] byTruncatingToWidth:110 withFont:&font];
		
		[str drawInRect:NSMakeRect(11, 23, 110, 40) withAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[[NSColor whiteColor] colorWithAlphaComponent:0.4], NSForegroundColorAttributeName, font, NSFontAttributeName, pstyle, NSParagraphStyleAttributeName, nil]];
		[str drawInRect:NSMakeRect(10, 24, 110, 40) withAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[[NSColor blackColor] colorWithAlphaComponent:0.8], NSForegroundColorAttributeName, font, NSFontAttributeName, pstyle, NSParagraphStyleAttributeName, nil]];
	}
	[dockIcon unlockFocus];
	
	[[NSApplication sharedApplication] setApplicationIconImage:dockIcon];
}

-(NSMenu*)applicationDockMenu:(NSApplication *)sender
{
	NSMenu* m = [[[NSMenu alloc] init] autorelease];
	for(int i=0; i<[shortcutsMenu numberOfItems]; ++i) {
		NSMenuItem *itm = [shortcutsMenu itemAtIndex:i];
		if(![itm isSeparatorItem]) {
			NSMenuItem *myItm = [m addItemWithTitle:[itm title] action:[itm action] keyEquivalent:[itm keyEquivalent]];
			[myItm setTarget:[itm target]];
			[myItm setState:[itm state]];
			[myItm setRepresentedObject:[itm representedObject]];
			[myItm setAlternate:[itm isAlternate]];
			[myItm setKeyEquivalentModifierMask:[itm keyEquivalentModifierMask]];
		} else {
			[m addItem:[NSMenuItem separatorItem]];
		}
	}
	
	return m;
}

-(void)rebuildShortcutsMenu
{
	// Delete everything
	for(int i=[shortcutsMenu numberOfItems]-1; i>=0; --i) {
		[shortcutsMenu removeItemAtIndex:i];
	}
	
	WorkcutsProject *p = [manager currentProject];
	
	int n = [[p shortcuts] count];
	if(n > 0) {
		for(int i=0; i<n; ++i) {
			id itm = [[p shortcuts] objectAtIndex:i];
			NSMenuItem *myItm = [shortcutsMenu addItemWithTitle:[itm title] action:@selector(openShortcut:) keyEquivalent:[itm keyEquivalent]];
			[myItm setKeyEquivalentModifierMask:[[itm keyEquivalentModifier] unsignedIntValue]];
			if([[itm checked] boolValue])
				[myItm setState: NSOnState];
			if([[itm alternate] boolValue])
				[myItm setAlternate: YES];
			[myItm setTarget:self];
			[myItm setRepresentedObject:itm];
		}
		[shortcutsMenu addItem:[NSMenuItem separatorItem]];
	}
	
	NSMenuItem *edit = [shortcutsMenu addItemWithTitle:[NSString stringWithFormat:@"Edit %@...", [WorkcutsProject configFileName]] action:@selector(editWorkcuts:) keyEquivalent:@"E"];
	[edit setKeyEquivalentModifierMask:NSCommandKeyMask];
	[edit setTarget:self];
}

-(void)rebuildStatusMenu
{
	// Delete everything
	for(int i=[statusMenu numberOfItems]-1; i>=0; --i) {
		[statusMenu removeItemAtIndex:i];
	}
	
	// Re-create the shortcuts menu 
	for(int i=0; i<[shortcutsMenu numberOfItems]; ++i) {
		NSMenuItem *itm = [shortcutsMenu itemAtIndex:i];
		if(![itm isSeparatorItem]) {
			NSMenuItem *myItm = [statusMenu addItemWithTitle:[itm title] action:[itm action] keyEquivalent:[itm keyEquivalent]];
			[myItm setKeyEquivalentModifierMask:[itm keyEquivalentModifierMask]];
			[myItm setTarget:[itm target]];
			[myItm setState:[itm state]];
			[myItm setAlternate:[itm isAlternate]];
			[myItm setRepresentedObject:[itm representedObject]];
		} else {
			[statusMenu addItem:[NSMenuItem separatorItem]];
		}
	}
	
	// Re-add a separator and the Activate menu item
	[statusMenu addItem:[NSMenuItem separatorItem]];
	[statusMenu addItem:activateMenuItem];
	
	NSMenuItem *quitW = [statusMenu addItemWithTitle:@"Quit Workcuts" action:@selector(terminate:) keyEquivalent:@"q"];
	[quitW setTarget:[NSApplication sharedApplication]];
	[quitW setKeyEquivalentModifierMask:NSCommandKeyMask];
}

-(void)rebuildRecentProjectsMenu
{
	// Delete everything
	for(int i=[recentProjectsMenu numberOfItems]-1; i>=0; --i) {
		[recentProjectsMenu removeItemAtIndex:i];
	}
	
	// Re-create the recents menu
	for(int i=0; i<[[manager recentProjects] count]; ++i) {
		NSString *itm = [[manager recentProjects] objectAtIndex:i];
		NSMenuItem *myItm = [recentProjectsMenu addItemWithTitle:itm action:@selector(openRecent:) keyEquivalent:@""];
		[myItm setTarget:self];
		[myItm setRepresentedObject:itm];
	}
	
	// Re-add a separator and the Activate menu item
	if([[manager recentProjects] count] > 0)
		[recentProjectsMenu addItem:[NSMenuItem separatorItem]];
	
	clearRecentsMenuItem = [recentProjectsMenu addItemWithTitle:@"Clear Menu" action:@selector(clearRecents:) keyEquivalent:@""];
	[clearRecentsMenuItem setTarget:self];
}

-(IBAction)activate:(id)sender
{
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

-(IBAction)editWorkcuts:(id)sender
{
	NSError *err = nil;
	if(![[manager currentProject] configFileExists]) {
		NSString *newFileContents = @"# Edit your shortcuts below.\n\nshortcut :example1 do\n\tnamed \"Example item\"\n\tpress \"Cmd R\"\n\twill do\n\t\tputs \"Hello\"\n\tend\nend\n\nshortcut :example1alt do\n\tnamed \"Another example item\"\n\tpress \"Cmd Option R\"\n\talternative\nend\n\nshortcut :example2 do\n\tnamed \"Check me item\"\n\n\twill do\n\t\tself.checked = !self.checked\n\tend\nend\n";
		[newFileContents writeToFile:[[manager currentProject] configFilePath] atomically:YES encoding:NSUTF8StringEncoding error:&err];
		[[manager currentProject] watchConfigFile];
	}
	
	if(err != nil) {
		[NSAlert alertWithError:err];
	} else {
		[[NSWorkspace sharedWorkspace] openFile:[[manager currentProject] configFilePath]];
	}
}

-(IBAction)open:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setFloatingPanel:YES];
	[panel setCanChooseDirectories:YES];
	[panel setCanChooseFiles:NO];
	[panel setAllowsMultipleSelection:NO];
	if([panel runModal] == NSOKButton) {
		[manager setCurrentProjectPath:[panel filename]];
	}
}

-(IBAction)close:(id)sender
{
	[manager closeCurrentProject];
}

-(IBAction)clearRecents:(id)sender
{
	[manager clearRecentProjects];
	[self rebuildRecentProjectsMenu];
}

-(IBAction)openRecent:(id)sender
{
	[manager setCurrentProjectPath:[sender representedObject]];
}

-(IBAction)openShortcut:(id)sender
{
	id s = [sender representedObject];
	[s execute];
	[self refresh];
}

-(IBAction)help:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"WorkcutsHelp" ofType:@"html"]]];
}

-(BOOL)validateMenuItem:(NSMenuItem *)item
{
	if([item action] == @selector(editWorkcuts:))
		return [manager hasCurrentProject];
	if([item action] == @selector(close:))
		return [manager hasCurrentProject];
	if([item action] == @selector(clearRecents:))
		return [[manager recentProjects] count] > 0;
	if([item action] == @selector(activate:))
		return ![[NSApplication sharedApplication] isActive];
	return YES;
}

@end
