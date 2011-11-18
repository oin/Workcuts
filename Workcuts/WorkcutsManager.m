//
//  WorkcutsManager.m
//  Workcuts
//
//  Created by Jonathan Aceituno on 14/11/11.
//  Copyright 2011 Jonathan Aceituno. All rights reserved.
//

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
	
	if([recentProjects count] > 0)
		[self setCurrentProjectPath:[recentProjects objectAtIndex:0]];
	
	return self;
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
