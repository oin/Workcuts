//
//  main.m
//  Workcuts
//
/* This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details. */

#import <Cocoa/Cocoa.h>
#import <RubyCocoa/RubyCocoa.h>

int main(int argc, const char **argv)
{
	return [RubyCocoa applicationMainWithProgram:"app_init.rb" argc:argc argv:argv];
    //return NSApplicationMain(argc,  (const char **) argv);
}
