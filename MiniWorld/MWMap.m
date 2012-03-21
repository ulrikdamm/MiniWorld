//
//  MWMap.m
//  MiniWorld
//
//  Created by Ulrik Damm on 23/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import "MWMap.h"
#import "MWObject.h"

@implementation MWMap

@synthesize objects;
@synthesize size;

- (id)init {
	if ((self = [super init])) {
		self.objects = [NSMutableArray array];
	}
	
	return self;
}

- (void)update {
	for (MWObject *object in self.objects) {
		[object update];
	}
}

- (void)addObject:(MWObject*)object {
	[self.objects addObject:object];
}

- (BOOL)isBlocked:(CGPoint)position {
	for (MWObject *object in self.objects) {
		if (object.blocking && object.position.x == position.x && object.position.y == position.y) {
			return YES;
		}
	}
	
	return NO;
}

- (void)interactWith:(CGPoint)point {
	for (MWObject *object in self.objects) {
		if (object.position.x == point.x && object.position.y == point.y) {
			[object interact:nil];
		}
	}
}

- (void)standUpon:(CGPoint)point {
	for (MWObject *object in self.objects) {
		if (object.position.x == point.x && object.position.y == point.y) {
			[object action:nil];
		}
	}
}

@end
