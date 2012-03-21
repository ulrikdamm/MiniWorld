//
//  MWViewController.m
//  MiniWorld
//
//  Created by Ulrik Damm on 23/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import "MWViewController.h"
#import "SpriteKit.h"
#import <QuartzCore/QuartzCore.h>
#import "MWCharacter.h"
#import "MWMap.h"
#import "MWTextBox.h"
#import "global.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SKSprite.h"
#import <AVFoundation/AVFoundation.h>
#include "TargetConditionals.h"

typedef enum {
	StatePressed,
	StateReleased,
	StateNone,
} State;

typedef struct {
	int attack;
	int defence;
	int speed;
	int agility;
	int luck;
} Stats;

SystemSoundID selectSound;

@interface MWViewController () {
	State upPressed;
	State downPressed;
	State leftPressed;
	State rightPressed;
	State aPressed;
	State bPressed;
	
	int target;
	
	int enemyhp;
	int yourhp;
	
	int old_yourhp;
	
	Stats enemyStats;
	Stats yourStats;
	
	int battleStartAnim;
	
	BOOL inBattle;
	
	SystemSoundID attackSound;
	SystemSoundID winSound;
	SystemSoundID failSound;
	SystemSoundID itemSound;
	SystemSoundID potionSound;
	
	int potions;
	BOOL hasSword;
	BOOL titleaway;
}

@property (strong, nonatomic) SKShader *shader;
@property (strong, nonatomic) MWCharacter *character;
@property (strong, nonatomic) SKTexture *texture;
@property (strong, nonatomic) NSMutableDictionary *maps;

@property (strong, nonatomic) SKSprite *enemyhpbar;
@property (strong, nonatomic) SKSprite *yourhpbar;
@property (strong, nonatomic) NSMutableArray *enemyNameLetters;
@property (strong, nonatomic) NSMutableArray *yourNameLetters;

@property (strong, nonatomic) NSMutableArray *blackSprites;

@property (strong, nonatomic) SKSprite *enemy;
@property (strong, nonatomic) NSString *enemyNameString;

@property (strong, nonatomic) NSString *beforeBattleScreen;
@property (assign, nonatomic) BOOL inBattle;
@property (copy, nonatomic) void (^battleOverBlock)(BOOL won);
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) SKSprite *titlescreen;

- (void)setupShaders;
- (void)main:(CADisplayLink*)link;
- (void)loadFirstScene;
- (void)loadSecondScene;
- (void)loadThirdScene;
- (void)loadBattleScene;
- (void)showMessages:(NSArray*)messages comlpetion:(void(^)(int choice))completion;
- (void)attack;
- (void)getAttacked;
- (void)setEnemyName:(NSString*)name;
- (void)setYourName:(NSString*)name;
- (void)battleAction;
- (void)endBattle;
- (void)enterBattle;
- (void)usePotion;
- (void)taunt;

@end

@implementation MWViewController

@synthesize skView;
@synthesize aButton;
@synthesize bButton;
@synthesize upButton;
@synthesize downButton;
@synthesize leftButton;
@synthesize rightButton;
@synthesize shader;
@synthesize character;
@synthesize textBox;
@synthesize texture;
@synthesize maps;
@synthesize enemyhpbar;
@synthesize yourhpbar;
@synthesize enemyNameLetters;
@synthesize yourNameLetters;
@synthesize blackSprites;
@synthesize enemy;
@synthesize enemyNameString;
@synthesize beforeBattleScreen;
@synthesize inBattle;
@synthesize battleOverBlock;
@synthesize audioPlayer;
@synthesize titlescreen;

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	inBattle = NO;
	
	srand(time(0));
	
	[self.view addSubview:self.skView];
	
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"attack" ofType:@"caf"]], &attackSound);
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"fail" ofType:@"caf"]], &failSound);
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"win" ofType:@"caf"]], &winSound);
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"item" ofType:@"caf"]], &itemSound);
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"potion" ofType:@"caf"]], &potionSound);
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"select" ofType:@"caf"]], &selectSound);
	
	[self setupShaders];
	
	self.skView.shader = self.shader;
	[self.skView setSpriteGroup:@"firstScene"];
	
	self.texture = [[SKTexture alloc] initWithImage:[UIImage imageNamed:@"textureMap.png"]];
	
	yourStats.attack = 20;
	yourStats.defence = 10;
	yourStats.speed = 20;
	yourStats.agility = 20;
	yourStats.luck = 20;
	
	self.maps = [NSMutableDictionary dictionary];
	
	self.character = [[MWCharacter alloc] initWithShader:self.shader texture:texture];
	self.character.sprite.zpos = 1;
	
	[self loadFirstScene];
	
	leftPressed = StateNone;
	rightPressed = StateNone;
	downPressed = StateNone;
	upPressed = StateNone;
	aPressed = StateNone;
	bPressed = StateNone;
	
	SKSprite *title = [[SKSprite alloc] initWithTexture:texture shader:shader];
	title.size = CGSizeMake(160 * 2, 144 * 2);
	title.textureClip = CGRectMake(16 * 4, 7 * 16, 160, 144);
	title.anchor = CGPointMake(-160, -144);
	title.position = CGPointMake(0, 0);
	title.zpos = 10;
	self.titlescreen = title;
	[self.skView addSprite:title];
	
	self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"world" ofType:@"mp3"]] error:nil];
//	if (!TARGET_IPHONE_SIMULATOR) {
		[self.audioPlayer play];
//	}
	
	CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(main:)];
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)main:(CADisplayLink *)link {
	MWMap *map = [self.maps objectForKey:[self.skView currentSpriteGroup]];
	
	if (!titleaway) {
		if (aPressed == StateReleased) {
			[self.skView removeSprite:self.titlescreen];
			titleaway = YES;
		}
	} else {
		if (self.textBox != nil) {
			if (aPressed == StateReleased) {
				if (![self.textBox nextMessage]) {
					[self.skView removeSprite:self.textBox.sprite];
					self.textBox = nil;
				}
			} else if (leftPressed == StatePressed) {
				[self.textBox changeChoice:MWDirectionLeft];
			} else if (rightPressed == StatePressed) {
				[self.textBox changeChoice:MWDirectionRight];
			} else if (upPressed == StatePressed) {
				[self.textBox changeChoice:MWDirectionUp];
			} else if (downPressed == StatePressed) {
				[self.textBox changeChoice:MWDirectionDown];
			}
		} else if (!inBattle) {
			if (leftPressed == StatePressed) {
				[self.character moveInDirection:MWDirectionLeft];
			} else if (rightPressed == StatePressed) {
				[self.character moveInDirection:MWDirectionRight];
			} else if (upPressed == StatePressed) {
				[self.character moveInDirection:MWDirectionUp];
			} else if (downPressed == StatePressed) {
				[self.character moveInDirection:MWDirectionDown];
			} else if (aPressed == StatePressed) {
				[map interactWith:self.character.lookingAt];
			}
		}
	}
	
	[map update];
	
	if (self.enemyhpbar) {
		int width = (int)((CGFloat)(32 * 5 - 16) / 100.0 * (enemyhp < 0? 0: enemyhp)) + 9;
		self.enemyhpbar.textureClip = CGRectMake(11 * 16, 4 * 16, width / 2, 16);
		self.enemyhpbar.size = CGSizeMake(width, 32);
		self.enemyhpbar.anchor = CGPointMake(-width / 2, -16);
	}
	
	if (self.yourhpbar) {
		int width = (int)((CGFloat)(32 * 5 - 16) / 100.0 * (yourhp < 0? 0: yourhp)) + 9;
		self.yourhpbar.textureClip = CGRectMake(11 * 16, 4 * 16, width / 2, 16);
		self.yourhpbar.size = CGSizeMake(width, 32);
		self.yourhpbar.anchor = CGPointMake(-width / 2, -16);
	}
	
	if (yourhp != old_yourhp) {
		[self setYourName:[NSString stringWithFormat:@" hp: %03i/100", (yourhp > 0? yourhp: 0)]];
		old_yourhp = yourhp;
	}
	
	
	if (self.blackSprites) {
		BOOL found = NO;
		
		for (MWObject *obj in self.blackSprites) {
			if (obj.sprite.visible == NO) {
				obj.sprite.visible = YES;
				found = YES;
				break;
			}
		}
		
		if (!found) {
			for (MWObject *obj in self.blackSprites) {
				[self.skView removeSprite:obj.sprite];
			}
			
			self.blackSprites = nil;
			battleStartAnim = 200;
			
			if ([self.skView hasSpriteGroup:@"battleScene"]) {
				[self.skView setSpriteGroup:@"battleScene"];
			} else {
				[self loadBattleScene];
			}
			
			[self setEnemyName:self.enemyNameString];
			[self setYourName:[NSString stringWithFormat:@" hp: %03i/100", yourhp]];
		}
	}
	
	if (battleStartAnim > 0) {
		battleStartAnim -= 2;
		
		if (battleStartAnim == 0) {
			[self battleAction];
		}
	}
	
	self.enemy.position = CGPointMake(208 + battleStartAnim, 16);
	
	if (self.textBox) {
		[self.textBox update];
	}
	
	[self.skView render];
	
	if (leftPressed == StateReleased) leftPressed = StateNone;
	if (rightPressed == StateReleased) rightPressed = StateNone;
	if (upPressed == StateReleased) upPressed = StateNone;
	if (downPressed == StateReleased) downPressed = StateNone;
	if (aPressed == StateReleased) aPressed = StateNone;
	if (bPressed == StateReleased) bPressed = StateNone;
}

- (void)loadFirstScene {
	[self.skView setSpriteGroup:@"firstScene"];
	
	int i, j;
	for (i = 0; i < 10; i++) {
		for (j = 0; j < 10; j++) {
			SKSprite *sprite = [[SKSprite alloc] initWithTexture:texture shader:self.shader];
			sprite.position = CGPointMake(i * 32, j * 32);
			sprite.textureClip = CGRectMake(0, 0, 16, 16);
			sprite.size = CGSizeMake(32, 32);
			sprite.anchor = CGPointMake(-16, -16);
			sprite.alpha = NO;
			
			[self.skView addSprite:sprite];
		}
	}
	
	[self.maps setObject:[[MWMap alloc] init] forKey:[self.skView currentSpriteGroup]];
	MWMap *map = [self.maps objectForKey:[self.skView currentSpriteGroup]];
	
	self.character.map = map;
	self.character.position = CGPointMake(3 * 32, 3 * 32);
	
	[map addObject:self.character];
	[self.skView addSprite:self.character.sprite];
	
	MWObject *(^addObject)(CGPoint, CGRect, BOOL) = ^MWObject *(CGPoint point, CGRect clip, BOOL blocking) {
		MWObject *stone = [[MWObject alloc] initWithShader:self.shader texture:texture];
		stone.position = CGPointMake(point.x * 32, point.y * 32);
		stone.sprite.textureClip = clip;
		stone.blocking = blocking;
		[self.skView addSprite:stone.sprite];
		[map addObject:stone];
		
		return stone;
	};
	
	for (i = 0; i < 10; i++) {
		addObject(CGPointMake(i, -1), CGRectMake(0, 16, 16, 16), YES);
		addObject(CGPointMake(i, 10), CGRectMake(0, 16, 16, 16), YES);
		addObject(CGPointMake(-1, i), CGRectMake(0, 16, 16, 16), YES);
		if (i != 8) addObject(CGPointMake(10, i), CGRectMake(0, 16, 16, 16), YES);
	}
	
	addObject(CGPointMake(3, 7), CGRectMake(0, 16, 16, 16), YES);
	
	addObject(CGPointMake(1, 4), CGRectMake(0, 32, 16, 16), YES);
	addObject(CGPointMake(5, 1), CGRectMake(0, 32, 16, 16), YES);
	addObject(CGPointMake(2, 1), CGRectMake(0, 32, 16, 16), YES);
	addObject(CGPointMake(6, 3), CGRectMake(0, 32, 16, 16), YES);
	addObject(CGPointMake(7, 1), CGRectMake(0, 32, 16, 16), YES);
	MWObject *tree = addObject(CGPointMake(8, 7), CGRectMake(0, 32, 16, 16), YES);
	
	tree.interactionBlock = ^{
		[self showMessages:[NSArray arrayWithObjects:@"you found the secret    tree", @"but nothing happens haha", nil] comlpetion:nil];
	};
	
	addObject(CGPointMake(5, 6), CGRectMake(0, 11 * 16, 16, 16), NO);
	addObject(CGPointMake(6, 6), CGRectMake(0, 6 * 16, 16, 16), NO);
	addObject(CGPointMake(6, 7), CGRectMake(0, 8 * 16, 16, 16), NO);
	addObject(CGPointMake(6, 8), CGRectMake(0, 4 * 16, 16, 16), NO);
	addObject(CGPointMake(7, 8), CGRectMake(0, 5 * 16, 16, 16), NO);
	addObject(CGPointMake(8, 8), CGRectMake(0, 5 * 16, 16, 16), NO);
	addObject(CGPointMake(9, 8), CGRectMake(0, 5 * 16, 16, 16), NO);
	
	addObject(CGPointMake(10, 8), CGRectMake(0, 0, 16, 16), NO).actionBlock = ^{
		if (![self.skView hasSpriteGroup:@"secondScene"]) {
			[self loadSecondScene];
		}
		
		[self.skView setSpriteGroup:@"secondScene"];
		self.character.map = [self.maps valueForKey:@"secondScene"];
		self.character.position = CGPointMake(0 * 32, 8 * 32);
	};
	
	MWObject *sign = addObject(CGPointMake(5, 5), CGRectMake(0, 10 * 16, 16, 16), YES);
	
	sign.interactionBlock = ^{
		[self showMessages:[NSArray arrayWithObjects:@"welcome to mini world", @"beware of danger lurkingin the shadows", nil] comlpetion:^(int choice) {
			if (self.textBox.messagesShown == 3) {
				NSString *message = [NSString stringWithFormat:@"you chose %@", choice == 0? @"one": choice == 1? @"two": choice == 2? @"three": @"four"];
				[self.textBox.messages addObject:message];
			}
		}];
	};
}

- (void)loadSecondScene {
	[self.skView setSpriteGroup:@"secondScene"];
	
	int i, j;
	for (i = 0; i < 10; i++) {
		for (j = 0; j < 10; j++) {
			SKSprite *sprite = [[SKSprite alloc] initWithTexture:texture shader:self.shader];
			sprite.position = CGPointMake(i * 32, j * 32);
			sprite.textureClip = CGRectMake(0, 0, 16, 16);
			sprite.size = CGSizeMake(32, 32);
			sprite.anchor = CGPointMake(-16, -16);
			sprite.alpha = NO;
			
			[self.skView addSprite:sprite];
		}
	}
	
	[self.maps setObject:[[MWMap alloc] init] forKey:[self.skView currentSpriteGroup]];
	MWMap *map = [self.maps objectForKey:[self.skView currentSpriteGroup]];
	
	[map addObject:self.character];
	[self.skView addSprite:self.character.sprite];
	
	MWObject *(^addObject)(CGPoint, CGRect, BOOL) = ^MWObject *(CGPoint point, CGRect clip, BOOL blocking) {
		MWObject *stone = [[MWObject alloc] initWithShader:self.shader texture:texture];
		stone.position = CGPointMake(point.x * 32, point.y * 32);
		stone.sprite.textureClip = clip;
		stone.blocking = blocking;
		[self.skView addSprite:stone.sprite];
		[map addObject:stone];
		
		return stone;
	};
	
	for (i = 0; i < 10; i++) {
		addObject(CGPointMake(i, -1), CGRectMake(0, 16, 16, 16), YES);
		addObject(CGPointMake(i, 10), CGRectMake(0, 16, 16, 16), YES);
		if (i != 8) addObject(CGPointMake(-1, i), CGRectMake(0, 16, 16, 16), YES);
		if (i != 8) addObject(CGPointMake(10, i), CGRectMake(0, 16, 16, 16), YES);
	}
	
	addObject(CGPointMake(-1, 8), CGRectMake(0, 0, 16, 16), NO).actionBlock = ^{
		if (![self.skView hasSpriteGroup:@"firstScene"]) {
			[self loadFirstScene];
		}
		
		[self.skView setSpriteGroup:@"firstScene"];
		self.character.position = CGPointMake(9 * 32, 8 * 32);
		self.character.map = [self.maps valueForKey:@"firstScene"];
	};
	
	addObject(CGPointMake(10, 8), CGRectMake(0, 0, 16, 16), NO).actionBlock = ^{
		if (![self.skView hasSpriteGroup:@"thirdScene"]) {
			[self loadThirdScene];
		}
		
		[self.skView setSpriteGroup:@"thirdScene"];
		self.character.position = CGPointMake(0 * 32, 8 * 32);
		self.character.map = [self.maps valueForKey:@"thirdScene"];
	};
	
	addObject(CGPointMake(0, 8), CGRectMake(0, 5 * 16, 16, 16), NO);
	addObject(CGPointMake(1, 8), CGRectMake(0, 5 * 16, 16, 16), NO);
	addObject(CGPointMake(2, 8), CGRectMake(0, 5 * 16, 16, 16), NO);
	addObject(CGPointMake(3, 8), CGRectMake(0, 5 * 16, 16, 16), NO);
	addObject(CGPointMake(4, 8), CGRectMake(0, 12 * 16, 16, 16), NO);
	addObject(CGPointMake(6, 8), CGRectMake(0, 11 * 16, 16, 16), NO);
	addObject(CGPointMake(7, 8), CGRectMake(0, 5 * 16, 16, 16), NO);
	addObject(CGPointMake(8, 8), CGRectMake(0, 5 * 16, 16, 16), NO);
	addObject(CGPointMake(9, 8), CGRectMake(0, 5 * 16, 16, 16), NO);
	
	addObject(CGPointMake(8, 7), CGRectMake(0, 10 * 16, 16, 16), YES).interactionBlock = ^{
		[self showMessages:[NSArray arrayWithObjects:@"small village           straight ahead", nil] comlpetion:nil];
	};
	
	addObject(CGPointMake(4, 3), CGRectMake(5 * 16, 0, 16, 16), YES).interactionBlock = ^{
		if (hasSword) {
			[self showMessages:[NSArray arrayWithObject:@"you cannot get to the   town a knight is        guarding the bridge"] comlpetion:nil];
		} else {
			[self showMessages:[NSArray arrayWithObjects:
								@"greeting traveller",
								@"it is good to see other people in this area     again",
								@"since the kings death   this kingdom has become a dangerous place",
								@"do you have a weapon?   {yes        {no", nil] comlpetion:^(int choice) {
				if (self.textBox.messagesShown == 4) {
					if (choice == 1) {
						[self.textBox.messages addObject:@"it is dangerous to go   alone                   take this"];
						
						SystemSoundID sound = itemSound;
						
						self.textBox.completionBlock = ^(int choice){
							AudioServicesPlaySystemSound(sound);
							
							[self.textBox.messages addObject:@"received a sword"];
							self.textBox.completionBlock = nil;
						};
						
						hasSword = YES;
					} else {
						[self.textBox.messages addObject:@"good for you            danger lurks everywhere"];
					}
				}
			}];
		}
	};
	
	addObject(CGPointMake(3, 1), CGRectMake(16 * 1, 7 * 16, 16, 16), YES);
	addObject(CGPointMake(4, 1), CGRectMake(16 * 2, 7 * 16, 16, 16), YES);
	addObject(CGPointMake(5, 1), CGRectMake(16 * 3, 7 * 16, 16, 16), YES);
	addObject(CGPointMake(3, 2), CGRectMake(16 * 1, 8 * 16, 16, 16), YES);
	addObject(CGPointMake(4, 2), CGRectMake(16 * 2, 8 * 16, 16, 16), YES);
	addObject(CGPointMake(5, 2), CGRectMake(16 * 3, 8 * 16, 16, 16), YES);
	
	addObject(CGPointMake(6, 2), CGRectMake(16 * 1, 9 * 16, 16, 16), YES);
	addObject(CGPointMake(7, 2), CGRectMake(16 * 2, 9 * 16, 16, 16), YES);
	addObject(CGPointMake(8, 2), CGRectMake(16 * 2, 9 * 16, 16, 16), YES);
	addObject(CGPointMake(9, 2), CGRectMake(16 * 3, 9 * 16, 16, 16), YES);
	
	void (^farmAction)(void) = ^{
		[self showMessages:[NSArray arrayWithObjects:@"this farm is in bad     shape", @"people here must be poor", nil] comlpetion:nil];
	};
	
	addObject(CGPointMake(6, 1), CGRectMake(16 * 1, 10 * 16, 16, 16), YES).interactionBlock = farmAction;
	addObject(CGPointMake(7, 1), CGRectMake(16 * 2, 10 * 16, 16, 16), YES).interactionBlock = farmAction;
	addObject(CGPointMake(8, 1), CGRectMake(16 * 2, 10 * 16, 16, 16), YES).interactionBlock = farmAction;
	addObject(CGPointMake(9, 1), CGRectMake(16 * 3, 10 * 16, 16, 16), YES).interactionBlock = farmAction;
	
	addObject(CGPointMake(1, 1), CGRectMake(0, 32, 16, 16), YES);
	addObject(CGPointMake(5, 6), CGRectMake(0, 32, 16, 16), YES);
	addObject(CGPointMake(2, 5), CGRectMake(0, 32, 16, 16), YES);
	addObject(CGPointMake(8, 4), CGRectMake(0, 32, 16, 16), YES);
	addObject(CGPointMake(7, 9), CGRectMake(0, 32, 16, 16), YES);
	addObject(CGPointMake(2, 2), CGRectMake(0, 16, 16, 16), YES);
	
	MWObject *potion = addObject(CGPointMake(9, 0), CGRectMake(16, 11 * 16, 16, 16), YES);
	
	__block id potion2 = potion;
	
	potion.interactionBlock = ^{
		potions++;
		
		[self showMessages:[NSArray arrayWithObjects:@"you found a healing     potion", nil] comlpetion:^(int choice) {
			[self.skView removeSprite:potion.sprite];
			[[[self.maps valueForKey:[self.skView currentSpriteGroup]] objects] removeObject:potion2];
		}];
		
		AudioServicesPlaySystemSound(itemSound);
	};
}

- (void)loadThirdScene {
	[self.skView setSpriteGroup:@"thirdScene"];
	
	int i, j;
	for (i = 0; i < 10; i++) {
		for (j = 0; j < 10; j++) {
			SKSprite *sprite = [[SKSprite alloc] initWithTexture:texture shader:self.shader];
			sprite.position = CGPointMake(i * 32, j * 32);
			sprite.textureClip = CGRectMake(0, 0, 16, 16);
			sprite.size = CGSizeMake(32, 32);
			sprite.anchor = CGPointMake(-16, -16);
			sprite.alpha = NO;
			
			[self.skView addSprite:sprite];
		}
	}
	
	[self.maps setObject:[[MWMap alloc] init] forKey:[self.skView currentSpriteGroup]];
	MWMap *map = [self.maps objectForKey:[self.skView currentSpriteGroup]];
	
	[map addObject:self.character];
	[self.skView addSprite:self.character.sprite];
	
	MWObject *(^addObject)(CGPoint, CGRect, BOOL) = ^MWObject *(CGPoint point, CGRect clip, BOOL blocking) {
		MWObject *stone = [[MWObject alloc] initWithShader:self.shader texture:texture];
		stone.position = CGPointMake(point.x * 32, point.y * 32);
		stone.sprite.textureClip = clip;
		stone.blocking = blocking;
		[self.skView addSprite:stone.sprite];
		[map addObject:stone];
		
		return stone;
	};
	
	for (i = 0; i < 10; i++) {
		addObject(CGPointMake(i, -1), CGRectMake(0, 16, 16, 16), YES);
		addObject(CGPointMake(i, 10), CGRectMake(0, 16, 16, 16), YES);
		if (i != 8) addObject(CGPointMake(-1, i), CGRectMake(0, 16, 16, 16), YES);
		addObject(CGPointMake(10, i), CGRectMake(0, 16, 16, 16), YES);
	}
	
	addObject(CGPointMake(-1, 8), CGRectMake(0, 0, 16, 16), NO).actionBlock = ^{
		if (![self.skView hasSpriteGroup:@"secondScene"]) {
			[self loadSecondScene];
		}
		
		[self.skView setSpriteGroup:@"secondScene"];
		self.character.position = CGPointMake(9 * 32, 8 * 32);
		self.character.map = [self.maps valueForKey:@"secondScene"];
	};
	
	addObject(CGPointMake(6, 0), CGRectMake(16, 16 * 12, 16, 16), YES);
	addObject(CGPointMake(6, 1), CGRectMake(16, 16 * 12, 16, 16), YES);
	addObject(CGPointMake(6, 2), CGRectMake(16, 16 * 12, 16, 16), YES);
	addObject(CGPointMake(6, 3), CGRectMake(16, 16 * 12, 16, 16), YES);
	addObject(CGPointMake(6, 4), CGRectMake(16, 16 * 13, 16, 16), NO);
	addObject(CGPointMake(6, 5), CGRectMake(16, 16 * 12, 16, 16), YES);
	addObject(CGPointMake(6, 6), CGRectMake(16, 16 * 12, 16, 16), YES);
	addObject(CGPointMake(6, 7), CGRectMake(16, 16 * 12, 16, 16), YES);
	addObject(CGPointMake(6, 8), CGRectMake(16, 16 * 12, 16, 16), YES);
	addObject(CGPointMake(6, 9), CGRectMake(16, 16 * 12, 16, 16), YES);
	
	addObject(CGPointMake(0, 8), CGRectMake(0, 5 * 16, 16, 16), NO);
	addObject(CGPointMake(1, 8), CGRectMake(0, 5 * 16, 16, 16), NO);
	addObject(CGPointMake(2, 8), CGRectMake(0, 12 * 16, 16, 16), NO);
	
	addObject(CGPointMake(7, 4), CGRectMake(0, 11 * 16, 16, 16), NO);
	addObject(CGPointMake(8, 4), CGRectMake(0, 5 * 16, 16, 16), NO);
	addObject(CGPointMake(9, 4), CGRectMake(0, 5 * 16, 16, 16), NO);
	
	addObject(CGPointMake(0, 0), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(1, 0), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(2, 0), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(3, 0), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(4, 0), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(7, 0), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(9, 0), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(0, 1), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(3, 1), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(5, 1), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(1, 2), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(2, 2), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(3, 2), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(0, 3), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(2, 3), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(1, 5), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(3, 6), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(5, 7), CGRectMake(0, 2 * 16, 16, 16), YES);
	addObject(CGPointMake(4, 8), CGRectMake(0, 2 * 16, 16, 16), YES);
	
	addObject(CGPointMake(9, 4), CGRectMake(0, 10 * 16, 16, 16), YES).interactionBlock = ^{
		[self showMessages:[NSArray arrayWithObjects:@"your adventure ends here", @"thank you for playing :d", nil] comlpetion:nil];
	};
	
	MWObject *knight = addObject(CGPointMake(5, 4), CGRectMake(5 * 16, 16, 16, 16), YES);
	
	__block id k4 = knight;
	
	knight.interactionBlock = ^{
		__block id k3 = k4;
		
		[self showMessages:[NSArray arrayWithObjects:@"none shall pass", @"{fight      {flee", nil] comlpetion:^(int choice) {
			if (choice == 0) {
				if (!hasSword) {
					[self.textBox.messages addObject:@"you need a sword to     fight"];
					self.textBox.completionBlock = nil;
					return ;
				}
				
				enemyhp = 100;
				yourhp = 100;
				old_yourhp = -1;
				inBattle = YES;
				
				self.enemyNameString = @"black knight";
				
				enemyStats.attack = 25;
				enemyStats.speed = 15;
				enemyStats.defence = 15;
				enemyStats.agility = 15;
				enemyStats.luck = 10;
				
				__block MWViewController *this = self;
				
				__block id k2 = k3;
				
				self.battleOverBlock = ^(BOOL won) {
					if (!won) {
						[this showMessages:[NSArray arrayWithObject:@"do not bother me again"] comlpetion:nil];
					} else {
						__block id k = k2;
						
						[this showMessages:[NSArray arrayWithObject:@"only a flesh wound"] comlpetion:^(int choice) {
							[this.skView removeSprite:knight.sprite];
							[[[this.maps valueForKey:[this.skView currentSpriteGroup]] objects] removeObject:k];
						}];
					}
				};
				
				[self enterBattle];
			}
		}];
	};
}

- (void)loadBattleScene {
	[self.skView setSpriteGroup:@"battleScene"];
	
	SKSprite *(^addObject)(CGPoint, CGRect, CGSize) = ^SKSprite *(CGPoint point, CGRect clip, CGSize size) {
		SKSprite *sprite = [[SKSprite alloc] initWithTexture:texture shader:shader];
		sprite.position = point;
		sprite.textureClip = clip;
		sprite.size = size;
		sprite.anchor = CGPointMake(-size.width / 2, -size.height / 2);
		[self.skView addSprite:sprite];
		
		return sprite;
	};
	
	addObject(CGPointMake(10, 32), CGRectMake(11 * 16, 3 * 16, 5 * 16, 16), CGSizeMake(5 * 32, 32));
	self.enemyhpbar = addObject(CGPointMake(10, 32), CGRectMake(11 * 16, 4 * 16, (5 * 16 / 2), 16), CGSizeMake((5 * 32) / 2, 32));
	
	addObject(CGPointMake(150, 185), CGRectMake(11 * 16, 3 * 16, 5 * 16, 16), CGSizeMake(5 * 32, 32));
	self.yourhpbar = addObject(CGPointMake(150, 185), CGRectMake(11 * 16, 4 * 16, (5 * 16 / 2), 16), CGSizeMake((5 * 32) / 2, 32));
	
	self.enemyNameLetters = [NSMutableArray array];
	self.yourNameLetters = [NSMutableArray array];
	
	int i;
	for (i = 0; i < 13; i++) {
		SKSprite *c = [[SKSprite alloc] initWithTexture:texture shader:shader];
		c.size = CGSizeMake(12, 12);
		c.position = CGPointMake(10 + i * 12, 10);
		c.anchor = CGPointMake(-6, -6);
		c.textureClip = CGRectMake(16 + i * 6, 16 * 6, 6, 6);
		c.alpha = YES;
		c.visible = YES;
		[self.skView addSprite:c];
		
		[self.enemyNameLetters addObject:c];
	}
	
	for (i = 0; i < 13; i++) {
		SKSprite *c = [[SKSprite alloc] initWithTexture:texture shader:shader];
		c.size = CGSizeMake(12, 12);
		c.position = CGPointMake(150 + i * 12, 163);
		c.anchor = CGPointMake(-6, -6);
		c.textureClip = CGRectMake(16 + i * 6, 16 * 6, 6, 6);
		c.alpha = YES;
		c.visible = YES;
		[self.skView addSprite:c];
		
		[self.yourNameLetters addObject:c];
	}
	
	addObject(CGPointMake(0, 164), CGRectMake(12 * 16, 0, 4 * 16, 2 * 16), CGSizeMake(4 * 32, 2 * 32));
	self.enemy = addObject(CGPointMake(208, 16), CGRectMake(16 * 6, 0, 32, 32), CGSizeMake(64, 64));
	
	SKSprite *textb;
	textb = [[SKSprite alloc] initWithTexture:texture shader:shader];
	textb.size = CGSizeMake(320, 96);
	textb.position = CGPointMake(0, 320);
	textb.anchor = CGPointMake(-160, 48);
	textb.textureClip = CGRectMake(16, 48, 160, 48);
	textb.alpha = YES;
	[self.skView addSprite:textb];
}

- (void)viewDidUnload {
	[self setSkView:nil];
	[self setAButton:nil];
	[self setBButton:nil];
	[self setUpButton:nil];
	[self setDownButton:nil];
	[self setLeftButton:nil];
	[self setRightButton:nil];
	[super viewDidUnload];
}

- (void)setupShaders {
	self.shader = [[SKShader alloc] init];
	
	NSError *error = nil;
	
	NSString *vertexShader = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vertexShader" ofType:@"glsl"] encoding:NSUTF8StringEncoding error:&error];
	[self.shader addSource:vertexShader ofType:GL_VERTEX_SHADER error:&error];
	
	if (error) [NSException raise:@"OpenGLException" format:@"Shader compilation failed: %@", error.localizedDescription];
	
	NSString *fragmentShader = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fragmentShader" ofType:@"glsl"] encoding:NSUTF8StringEncoding error:&error];
	[self.shader addSource:fragmentShader ofType:GL_FRAGMENT_SHADER error:&error];
	
	if (error) [NSException raise:@"OpenGLException" format:@"Shader compilation failed: %@", error.localizedDescription];
	
	[self.shader linkProgram:&error];
	
	if (error) [NSException raise:@"OpenGLException" format:@"Shader compilation failed: %@", error.localizedDescription];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)pressed:(id)sender {
	if (sender == self.leftButton) {
		leftPressed = StatePressed;
	} else if (sender == self.rightButton) {
		rightPressed = StatePressed;
	} else if (sender == self.upButton) {
		upPressed = StatePressed;
	} else if (sender == self.downButton) {
		downPressed = StatePressed;
	} else if (sender == self.aButton) {
		aPressed = StatePressed;
	} else if (sender == self.bButton) {
		bPressed = StatePressed;
	}
}

- (IBAction)released:(id)sender {
	if (sender == self.leftButton) {
		leftPressed = StateReleased;
	} else if (sender == self.rightButton) {
		rightPressed = StateReleased;
	} else if (sender == self.upButton) {
		upPressed = StateReleased;
	} else if (sender == self.downButton) {
		downPressed = StateReleased;
	} else if (sender == self.aButton) {
		aPressed = aPressed == StatePressed? StateReleased: StateNone;
	} else if (sender == self.bButton) {
		bPressed = StateReleased;
	}
}

- (void)showMessages:(NSArray*)messages comlpetion:(void(^)(int))completion {
	aPressed = StateNone;
	
	self.textBox = [[MWTextBox alloc] initWithMessages:[messages mutableCopy] texture:self.texture shader:self.shader];
	[self.skView addSprite:self.textBox.sprite];
	self.textBox.completionBlock = completion;
}

- (void)getAttacked {
	int r1 = rand() % 100;
	int l2 = rand() % enemyStats.luck;
	
	NSString *text;
	
	if (r1 > (yourStats.agility - l2) - (enemyStats.speed + l2)) {
		int damage = (enemyStats.attack - yourStats.defence) + l2;
		yourhp -= damage;
		text = [NSString stringWithFormat:@"enemy dealt %i damage", damage];
		
		AudioServicesPlaySystemSound(attackSound);
	} else {
		text = [NSString stringWithFormat:@"you evaded the attack"];
	}
	
	[self.textBox.messages addObject:text];
	__block id this = self;
	BOOL doAttack = yourStats.speed <= enemyStats.speed;
	int hp = yourhp;
	
	self.textBox.completionBlock = ^(int choice) {
		if (hp <= 0) {
			[this endBattle];
		} else {
			if (doAttack) {
				[this attack];
			} else {
				[this battleAction];
			}
		}
	};
}

- (void)attack {
	int r2 = rand() % 100;
	int l1 = rand() % yourStats.luck;
	
	NSString *text;
	
	if (r2 > (enemyStats.agility - l1) - (yourStats.speed + l1)) {
		int damage = (yourStats.attack - enemyStats.defence) + l1;
		enemyhp -= damage;
		text = [NSString stringWithFormat:@"you dealt %i damage", damage];
		
		AudioServicesPlaySystemSound(attackSound);
	} else {
		text = [NSString stringWithFormat:@"the enemy evaded your   attack"];
	}
	
	[self.textBox.messages addObject:text];
	__block id this = self;
	BOOL doAttack = yourStats.speed > enemyStats.speed;
	int hp = enemyhp;
	
	self.textBox.completionBlock = ^(int choice) {
		if (hp <= 0) {
			[this endBattle];
		} else {
			if (doAttack) {
				[this getAttacked];
			} else {
				[this battleAction];
			}
		}
	};
}

- (void)setEnemyName:(NSString*)name {
	int i;
	for (i = 0; i < [self.enemyNameLetters count]; i++) {
		SKSprite *c = [self.enemyNameLetters objectAtIndex:i];
		
		char ch;
		if (i >= [name length]) {
			ch = 27;
		} else if ([name characterAtIndex:i] >= 'a' && [name characterAtIndex:i] <= 'z') {
			ch = [name characterAtIndex:i] - 'a';
		} else if ([name characterAtIndex:i] >= '0' && [name characterAtIndex:i] <= '9') {
			ch = [name characterAtIndex:i] - '0' + 30;
		} else if ([name characterAtIndex:i] == ':') {
			ch = 28;
		} else if ([name characterAtIndex:i] == '/') {
			ch = 29;
		} else {
			ch = 27;
		}
		
		c.textureClip = CGRectMake(16 + ch * 6, 16 * 6, 6, 6);
	}
}

- (void)setYourName:(NSString*)name {
	int i;
	for (i = 0; i < [self.yourNameLetters count]; i++) {
		SKSprite *c = [self.yourNameLetters objectAtIndex:i];
		
		char ch;
		if (i >= [name length]) {
			ch = 27;
		} else if ([name characterAtIndex:i] >= 'a' && [name characterAtIndex:i] <= 'z') {
			ch = [name characterAtIndex:i] - 'a';
		} else if ([name characterAtIndex:i] >= '0' && [name characterAtIndex:i] <= '9') {
			ch = [name characterAtIndex:i] - '0' + 30;
		} else if ([name characterAtIndex:i] == ':') {
			ch = 28;
		} else if ([name characterAtIndex:i] == '/') {
			ch = 29;
		} else {
			ch = 27;
		}
		
		c.textureClip = CGRectMake(16 + ch * 6, 16 * 6, 6, 6);
	}
}

- (void)battleAction {
	NSString *actions = @"choose an action:       {attack     {use potion {taunt";
	
	void (^completion)(int) = ^(int choice) {
		if (yourStats.speed > enemyStats.speed) {
			if (choice == 0) {
				[self attack];
			} else if (choice == 1) {
				[self usePotion];
			} else if (choice == 2) {
				[self taunt];
			}
		} else {
			[self getAttacked];
		}
	};
	
	if (self.textBox) {
		[self.textBox.messages addObject:actions];
		self.textBox.completionBlock = completion;
	} else {
		[self showMessages:[NSArray arrayWithObjects:actions, nil] comlpetion:completion];
	}
}

- (void)endBattle {
	[self.audioPlayer stop];
	
	if (self.textBox) {
		if (yourhp <= 0) {
			[self.textBox.messages addObject:@"you were defeated!"];
			
			AudioServicesPlaySystemSound(failSound);
		} else {
			[self.textBox.messages addObject:@"you defeated the enemy!"];
			
			AudioServicesPlaySystemSound(winSound);
		}
		
		__block id this = self;
		BOOL won = yourhp > 0;
		void (^block)(BOOL) = battleOverBlock;
		
		self.textBox.completionBlock = ^(int choice) {
			[this setInBattle:NO];
			[[this skView] setSpriteGroup:[this beforeBattleScreen]];
			
			self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"world" ofType:@"mp3"]] error:nil];
//			if (!TARGET_IPHONE_SIMULATOR)
				[self.audioPlayer play];
			
			if (block) {
				double delayInSeconds = 0.01;
				dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
				dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
					block(won);
				});
			}
		};
	}
}

-(void)enterBattle {
	self.beforeBattleScreen = [self.skView currentSpriteGroup];
	
	self.blackSprites = [NSMutableArray array];
	
	void (^addBlackThing)(CGPoint) = ^(CGPoint point) {
		MWObject *stone = [[MWObject alloc] initWithShader:self.shader texture:texture];
		stone.sprite.position = CGPointMake(point.x * 32, point.y * 32);
		stone.sprite.size = CGSizeMake(32, 32);
		stone.sprite.textureClip = CGRectMake(0, 15 * 16, 16, 16);
		stone.blocking = NO;
		stone.sprite.zpos = 5;
		stone.sprite.visible = NO;
		stone.sprite.anchor = CGPointMake(-16, -16);
		[self.skView addSprite:stone.sprite];
		[self.blackSprites addObject:stone];
	};
	
	int a, b;
	for (a = 0; a < 5; a++) {
		for (b = a; b < 10 - a; b++) {
			addBlackThing(CGPointMake(a, b));
		}
		
		for (b = a; b < 10 - a; b++) {
			addBlackThing(CGPointMake(b, (9-a)));
		}
		
		for (b = a; b < 10 - a; b++) {
			addBlackThing(CGPointMake((9-a), 9-b));
		}
		
		for (b = a; b < 10 - a; b++) {
			addBlackThing(CGPointMake(9-b, a));
		}
	}
	
	self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"battle" ofType:@"mp3"]] error:nil];
//	if (!TARGET_IPHONE_SIMULATOR)
		[self.audioPlayer play];
}

- (void)usePotion {
	if (potions == 0) {
		[self.textBox.messages addObject:@"you have no potions"];
		__block id this = self;
		
		self.textBox.completionBlock = ^(int choice) {
			[this battleAction];
		};
		
		return;
	}
	
	potions--;
	
	AudioServicesPlaySystemSound(potionSound);
	
	yourhp = (yourhp + 75 > 100? 100: yourhp + 75);
	
	[self.textBox.messages addObject:@"used a potion"];
	__block id this = self;
	BOOL doAttack = yourStats.speed > enemyStats.speed;
	
	self.textBox.completionBlock = ^(int choice) {
		if (doAttack) {
			[this getAttacked];
		} else {
			[this battleAction];
		}
	};
}

- (void)taunt {
	AudioServicesPlaySystemSound(potionSound);
	
	enemyStats.defence = (enemyStats.defence - 5 < 0? 0: enemyStats.defence - 5);
	
	[self.textBox.messages addObject:@"you used taunt          enemy defense fell"];
	__block id this = self;
	BOOL doAttack = yourStats.speed > enemyStats.speed;
	
	self.textBox.completionBlock = ^(int choice) {
		if (doAttack) {
			[this getAttacked];
		} else {
			[this battleAction];
		}
	};
}

@end
