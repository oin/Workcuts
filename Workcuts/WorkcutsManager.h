//
//  WorkcutsManager.h
//  Workcuts
//
//  Created by Jonathan Aceituno on 14/11/11.
//  Copyright 2011 Jonathan Aceituno. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WorkcutsProject.h"


@interface WorkcutsManager : NSObject {
	WorkcutsProject* project;
	NSMutableArray* recentProjects;
	NSMutableArray* currentTasks;
}

-(id)init;
-(void)dealloc;
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
