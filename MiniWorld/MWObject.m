//
//  MWObject.m
//  MiniWorld
//
//  Created by Ulrik Damm on 23/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import "MWObject.h"
#import "SKSprite.h"

@interface MWObject ()

@property (strong, nonatomic) SKShader *shader;
@property (strong, nonatomic) SKTexture *texture;

@end

@implementation MWObject

@synthesize sprite;
@synthesize shader;
@synthesize texture;
@synthesize position;
@synthesize blocking;
@synthesize map;
@synthesize interactionBlock;
@synthesize actionBlock;

- (id)initWithShader:(SKShader*)newshader texture:(SKTexture*)newtexture {
	if ((self = [super init])) {
		self.shader = newshader;
		self.texture = newtexture;
		
		self.sprite = [[SKSprite alloc] initWithTexture:self.texture shader:self.shader];
		self.sprite.size = CGSizeMake(32, 32);
		self.sprite.anchor = CGPointMake(-16, -16);
		self.sprite.alpha = YES;
	}
	
	return self;
}

- (void)update {
	self.sprite.position = self.position;
}

- (void)interact:(MWObject*)object {
	if (interactionBlock) {
		interactionBlock();
	}
}

- (void)action:(MWObject*)object {
	if (actionBlock) {
		actionBlock();
	}
}

@end
