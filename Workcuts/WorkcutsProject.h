//
//  WorkcutsProject.h
//  Workcuts
//
//  Created by Jonathan Aceituno on 14/11/11.
//  Copyright 2011 Jonathan Aceituno. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WorkcutsShortcut.h"

@interface WorkcutsProject : NSObject {
	NSString* path;
	NSString* title_override;
	NSMutableArray* shortcuts;
}

+(NSString*)configFileName;
-(id)initWithPath:(NSString*)thePath;
-(NSString*)path;
-(NSString*)title;
-(NSString*)configFilePath;
-(BOOL)configFileExists;
-(NSArray*)shortcuts;
-(WorkcutsShortcut*)shortcutWithIdentifier:(NSString*)identifier;
-(void)configFileDidChange:(id)notification;
-(void)watchConfigFile;

@end
