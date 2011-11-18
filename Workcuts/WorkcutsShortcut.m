//
//  WorkcutsShortcut.m
//  Workcuts
//
//  Created by Jonathan Aceituno on 18/11/11.
//  Copyright 2011 Jonathan Aceituno. All rights reserved.
//

#import "WorkcutsShortcut.h"


@implementation WorkcutsShortcut

-(id)initWithIdentifier:(NSString*)theIdentifier
{
	self = [super init];
	if(self == nil || [theIdentifier length] == 0)
		return nil;
	
	identifier = nil;
	title = identifier;
	key = nil;
	keyModifiers = 0;
	action = nil;
	
	return self;
}
				
-(NSString*)identifier
{
	return identifier;
}

-(NSString*)title
{
	return title;
}

-(void)execute
{
	
}

@end
