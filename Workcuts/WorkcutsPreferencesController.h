//
//  WorkcutsPreferencesController.h
//  Workcuts
//
//  Created by Jonathan Aceituno on 17/11/11.
//  Copyright 2011 Jonathan Aceituno. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WorkcutsPreferencesController : NSWindowController {
	IBOutlet NSTextField *keyComboField;
}

-(IBAction)setGlobalShortcut:(id)sender;

@end
