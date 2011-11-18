//
//  WorkcutsAppDelegate.h
//  Workcuts
//
//  Created by Jonathan Aceituno on 14/11/11.
//  Copyright 2011 Jonathan Aceituno. All rights reserved.
//

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

@end
