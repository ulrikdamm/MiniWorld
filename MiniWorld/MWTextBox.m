//
//  MWTextBox.m
//  MiniWorld
//
//  Created by Ulrik Damm on 23/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import "MWTextBox.h"
#import "MWViewController.h"

@interface MWTextBox () {
	int visibleCharCount;
	int choices;
	int choice;
}

@property (strong, nonatomic) NSMutableArray *chars;
@property (strong, nonatomic) NSString *text;
@property (assign, nonatomic) int messagesShown;

- (void)updateText;

@end

@implementation MWTextBox

@synthesize sprite;
@synthesize chars;
@synthesize text;
@synthesize messages;
@synthesize completionBlock;
@synthesize messagesShown;

- (id)initWithMessages:(NSMutableArray*)newmessages texture:(SKTexture*)texture shader:(SKShader*)shader {
	if ((self = [super init])) {
		self.sprite = [[SKSprite alloc] initWithTexture:texture shader:shader];
		self.sprite.size = CGSizeMake(320, 96);
		self.sprite.position = CGPointMake(0, 320);
		self.sprite.anchor = CGPointMake(-160, 48);
		self.sprite.textureClip = CGRectMake(16, 48, 160, 48);
		self.sprite.alpha = YES;
		self.sprite.zpos = 2;
		
		self.chars = [NSMutableArray array];
		self.messages = [newmessages mutableCopy];
		self.text = [self.messages objectAtIndex:0];
		[self.messages removeObjectAtIndex:0];
		messagesShown = 1;
		
		int i, j;
		for (j = 0; j < 3; j++) {
			for (i = 0; i < 24; i++) {
				SKSprite *c = [[SKSprite alloc] initWithTexture:texture shader:shader];
				c.size = CGSizeMake(12, 12);
				c.position = CGPointMake(16 + i * 12, 245 + j * 20);
				c.anchor = CGPointMake(-6, -6);
				c.textureClip = CGRectMake(16 + i * 6, 16 * 6, 6, 6);
				c.alpha = YES;
				c.visible = NO;
				[self.sprite.subsprites addObject:c];
				[self.chars addObject:c];
			}
		}
		
		[self updateText];
	}
	
	return self;
}

- (void)updateText {
	choices = 0;
	choice = 0;
	
	int i;
	for (i = 0; i < [chars count]; i++) {
		SKSprite *c = [chars objectAtIndex:i];
		
		char ch;
		if (i >= [self.text length]) {
			ch = 27;
			c.visible = NO;
		} else if ([self.text characterAtIndex:i] >= 'a' && [self.text characterAtIndex:i] <= 'z' + 1) {
			ch = [self.text characterAtIndex:i] - 'a';
			
			if (ch == '{' - 'a') {
				choices++;
			}
		} else if ([self.text characterAtIndex:i] >= '0' && [self.text characterAtIndex:i] <= '9') {
			ch = [self.text characterAtIndex:i] - '0' + 30;
		} else if ([self.text characterAtIndex:i] == ':') {
			ch = 28;
		} else if ([self.text characterAtIndex:i] == '/') {
			ch = 29;
		} else {
			ch = 27;
			c.visible = NO;
		}
		
		c.textureClip = CGRectMake(16 + ch * 6, 16 * 6, 6, 6);
	}
}

- (void)update {
	if (visibleCharCount < [self.chars count] - 1) {
		SKSprite *c = [chars objectAtIndex:visibleCharCount];
		if ((c.textureClip.origin.x - 16) / 6 != 27) {
			[c setVisible:YES];
		}
		visibleCharCount++;
	}
	
	int i;
	int found = -1;
	for (i = 0; i < [chars count]; i++) {
		SKSprite *c = [chars objectAtIndex:i];
		if ((c.textureClip.origin.x - 16) / 6 == '{' - 'a') {
			found++;
			
			if (found != choice) {
				c.visible = NO;
			} else {
				c.visible = i < visibleCharCount;
			}
		}
	}
}

- (void)changeChoice:(MWDirection)direction {
	if (direction == MWDirectionUp) {
		if (choice == 3) {
			choice = 1;
		} else if (choice == 2) {
			choice = 0;
		}
	} else if (direction == MWDirectionDown) {
		if (choice == 1 && choices >= 4) {
			choice = 3;
		} else if (choice == 0 && choices >= 3) {
			choice = 2;
		}
	} else if (direction == MWDirectionLeft) {
		if (choice == 1) {
			choice = 0;
		} else if (choice == 3) {
			choice = 2;
		}
	} else if (direction == MWDirectionRight) {
		if (choice == 0 && choices >= 2) {
			choice = 1;
		} else if (choice == 2 && choices >= 4) {
			choice = 3;
		}
	}
	
	[self update];
}

- (BOOL)nextMessage {
	AudioServicesPlaySystemSound(selectSound);

	if ([self.messages count] == 0) {
		if (self.completionBlock) {
			self.completionBlock(choice);
			
			if ([messages count] > 0) {
				goto noReturn;
			}
		}
		
		return NO;
	}
	
noReturn:
	
	messagesShown++;
	self.text = [self.messages objectAtIndex:0];
	[self.messages removeObjectAtIndex:0];
	visibleCharCount = 0;
	
	int i;
	for (i = 0; i < [chars count]; i++) {
		[[chars objectAtIndex:i] setVisible:NO];
	}
	
	[self updateText];
	
	return YES;
}

@end
