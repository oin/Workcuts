//
//  WorkcutsManager.h
//  Workcuts
//
/* This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details. */

#import <Cocoa/Cocoa.h>
#import "WorkcutsProject.h"


@interface WorkcutsManager : NSObject {
	WorkcutsProject* project;
	NSMutableArray* recentProjects;
	NSMutableArray* currentTasks;
}

-(id)init;
-(void)dealloc;
-(void)initProject;
-(NSArray*)recentProjects;
-(void)clearRecentProjects;
-(void)updateRecentProjects;
-(BOOL)hasCurrentProject;
-(NSString*)currentProjectPath;
-(void)setCurrentProjectPath:(NSString*)theProject;
-(WorkcutsProject*)currentProject;
//-(BOOL)open:(NSString*)folder;
-(void)closeCurrentProject;

@end
