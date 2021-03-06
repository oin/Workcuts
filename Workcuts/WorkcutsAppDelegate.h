//
//  WorkcutsAppDelegate.h
//  Workcuts
//
/* This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details. */

#import <Cocoa/Cocoa.h>
#import <RubyCocoa/RubyCocoa.h>
#import "WorkcutsManager.h"

@class PTHotKey;

@interface WorkcutsAppDelegate : NSObject {
	WorkcutsManager *manager;
	
	NSStatusItem *statusItem;
	
	BOOL showsProjectTitleInStatusItem;
	BOOL showsProjectTitleInDock;
	
	IBOutlet NSMenu *recentProjectsMenu;
	IBOutlet NSMenu *shortcutsMenu;
	IBOutlet NSMenu *statusMenu;
	IBOutlet NSMenuItem *activateMenuItem;
	IBOutlet NSMenuItem *clearRecentsMenuItem;
	
	IBOutlet NSWindow *evalErrorSheet;
	IBOutlet NSTextView *errorView;
	
	IBOutlet NSWindow *cmdOutputWindow;
	IBOutlet NSTextView *cmdOutputView;
	
	PTHotKey* shortcutsMenuHotKey;
}

-(NSDictionary*)shortcutKeyCombo;
-(void)setShortcutKeyCombo:(id)value;
-(void)refresh;
-(void)setShowsStatusItem:(BOOL)value;
-(BOOL)showsStatusItem;
-(void)setShowsProjectTitleInStatusItem:(BOOL)value;
-(BOOL)showsProjectTitleInStatusItem;
-(void)setShowsProjectTitleInDock:(BOOL)value;
-(BOOL)showsProjectTitleInDock;
-(void)updateStatusItem;
-(void)updateDockIcon;
-(void)rebuildShortcutsMenu;
-(void)rebuildStatusMenu;
-(void)rebuildRecentProjectsMenu;

-(IBAction)activate:(id)sender;
-(IBAction)editWorkcuts:(id)sender;
-(IBAction)open:(id)sender;
-(IBAction)close:(id)sender;
-(IBAction)clearRecents:(id)sender;
-(IBAction)openRecent:(id)sender;
-(IBAction)openShortcut:(id)sender;
-(IBAction)popupMenu:(id)sender;
-(IBAction)closeErrorSheet:(id)sender;
-(IBAction)help:(id)sender;

@end
