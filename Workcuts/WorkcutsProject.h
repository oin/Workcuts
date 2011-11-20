//
//  WorkcutsProject.h
//  Workcuts
//
/* This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details. */

#import <Cocoa/Cocoa.h>

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
-(void)configFileDidChange:(id)notification;
-(void)watchConfigFile;

@end
