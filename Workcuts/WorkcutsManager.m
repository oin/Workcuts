//
//  WorkcutsManager.m
//  Workcuts
//
/* This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details. */

#import "WorkcutsManager.h"

@implementation WorkcutsManager

-(id)init
{
	self = [super init];
	if(self == nil)
		return nil;
	
	recentProjects = [[NSMutableArray alloc] init];
	currentTasks = [[NSMutableArray alloc] init];
	
	[recentProjects addObjectsFromArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"RecentProjects"]];
	project = nil;
	
	return self;
}

-(void)initProject
{
	if([recentProjects count] > 0)
		[self setCurrentProjectPath:[recentProjects objectAtIndex:0]];
}

-(void)dealloc
{
	[project release];
	[recentProjects release];
	[currentTasks release];
	[super dealloc];
}

-(NSArray*)recentProjects
{
	return recentProjects;
}

-(void)clearRecentProjects
{
	[recentProjects removeAllObjects];
	[self updateRecentProjects];
}

-(void)updateRecentProjects
{
	[[NSUserDefaults standardUserDefaults] setObject:recentProjects forKey:@"RecentProjects"];
}

-(WorkcutsProject*)currentProject
{
	return project;
}

-(BOOL)hasCurrentProject
{
	return [self currentProject] != nil;
}

-(NSString*)currentProjectPath
{
	return [project path];
}

-(void)setCurrentProjectPath:(NSString*)theProject
{
	if(theProject == nil) {
		[project release];
		project = nil;
	} else if(theProject != [self currentProjectPath]) {
		WorkcutsProject* p = [[WorkcutsProject alloc] initWithPath:theProject];
		
		if(!p)
			return;
		
		// Try to close the current project in another one is open
		if([self hasCurrentProject]) {
			[project release];
			project = nil;
		}
		
		project = p;
		
		[recentProjects removeObject:theProject];
		[recentProjects insertObject:theProject atIndex:0];
		
		[self updateRecentProjects];
	}
}

-(void)closeCurrentProject
{
	[self setCurrentProjectPath:nil];
}

+(NSString*)dialogFileName
{
	return @"";
}

@end
