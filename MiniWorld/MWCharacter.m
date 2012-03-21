//
//  MWCharacter.m
//  MiniWorld
//
//  Created by Ulrik Damm on 23/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import "MWCharacter.h"

@interface MWCharacter () {
	MWDirection currentDirection;
	int animationCount;
	int animationSubcount;
}

@property (assign, nonatomic) CGPoint lookingAt;

@end

@implementation MWCharacter

@synthesize map;
@synthesize lookingAt;

- (id)initWithShader:(SKShader*)newshader texture:(SKTexture*)newtexture {
	if ((self = [super initWithShader:newshader texture:newtexture])) {
		self.sprite.size = CGSizeMake(32, 32);
		self.sprite.textureClip = CGRectMake(16, 0, 16, 16);
		self.sprite.anchor = CGPointMake(-16, -16);
		self.sprite.alpha = YES;
		
		self.blocking = YES;
		
		currentDirection = MWDirectionNone;
		
		self.lookingAt = CGPointMake(self.position.x, self.position.y + 1);
	}
	
	return self;
}

- (void)update {
	if (currentDirection != MWDirectionNone) {
		int speed = 2;
		
		if (currentDirection == MWDirectionLeft) {
			self.position = CGPointMake(self.position.x - speed, self.position.y);
			self.sprite.textureClip = CGRectMake(16 * 3, (animationCount % 2? 16: 32), 16, 16);
		} else if (currentDirection == MWDirectionRight) {
			self.position = CGPointMake(self.position.x + speed, self.position.y);
			self.sprite.textureClip = CGRectMake(16 * 2, (animationCount % 2? 16: 32), 16, 16);
		} else if (currentDirection == MWDirectionUp) {
			self.position = CGPointMake(self.position.x, self.position.y - speed);
			self.sprite.textureClip = CGRectMake(16 * 4, (animationCount % 2? 16: 32), 16, 16);
		} else if (currentDirection == MWDirectionDown) {
			self.position = CGPointMake(self.position.x, self.position.y + speed);
			self.sprite.textureClip = CGRectMake(16 * 1, (animationCount % 2? 16: 32), 16, 16);
		}
		
		self.lookingAt = CGPointMake(self.position.x + (currentDirection == MWDirectionLeft? -32: currentDirection == MWDirectionRight? 32: 0),
									 self.position.y + (currentDirection == MWDirectionUp? -32: currentDirection == MWDirectionDown? 32: 0));
		
		if ((int)self.position.x % 32 == 0 && (int)self.position.y % 32 == 0) {
			currentDirection = MWDirectionNone;
			
			[self.map standUpon:self.position];
		}
	} else {
		self.sprite.textureClip = CGRectMake(self.sprite.textureClip.origin.x, 0, 16, 16);
	}
	
	if (currentDirection != MWDirectionNone) {
		self.lookingAt = CGPointMake(self.position.x + (currentDirection == MWDirectionLeft? -32: currentDirection == MWDirectionRight? 32: 0),
									 self.position.y + (currentDirection == MWDirectionUp? -32: currentDirection == MWDirectionDown? 32: 0));
	}
	
	animationSubcount++;
	if (animationSubcount >= 8) {
		animationSubcount = 0;
		animationCount++;
	}
	
	[super update];
}

- (void)moveInDirection:(MWDirection)direction {
	if (currentDirection == MWDirectionNone) {
		currentDirection = direction;
		
		CGPoint target = self.position;
		
		if (currentDirection == MWDirectionLeft) {
			self.sprite.textureClip = CGRectMake(16 * 3, 0, 16, 16);
			target.x -= 32;
		} else if (currentDirection == MWDirectionRight) {
			self.sprite.textureClip = CGRectMake(16 * 2, 0, 16, 16);
			target.x += 32;
		} else if (currentDirection == MWDirectionUp) {
			self.sprite.textureClip = CGRectMake(16 * 4, 0, 16, 16);
			target.y -= 32;
		} else if (currentDirection == MWDirectionDown) {
			self.sprite.textureClip = CGRectMake(16 * 1, 0, 16, 16);
			target.y += 32;
		}
		
		self.sprite.textureClip = CGRectMake(self.sprite.textureClip.origin.x, 0, 16, 16);
		
		self.lookingAt = CGPointMake(self.position.x + (currentDirection == MWDirectionLeft? -32: currentDirection == MWDirectionRight? 32: 0),
									 self.position.y + (currentDirection == MWDirectionUp? -32: currentDirection == MWDirectionDown? 32: 0));
		
		if ([self.map isBlocked:target]) {
			currentDirection = MWDirectionNone;
		}
	}
}

@end
