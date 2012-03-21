//
//  MWViewController.h
//  MiniWorld
//
//  Created by Ulrik Damm on 23/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpriteKit.h"
#import "MWTextBox.h"

@interface MWViewController : UIViewController

@property (assign, nonatomic) IBOutlet SKView *skView;
@property (assign, nonatomic) IBOutlet UIButton *aButton;
@property (assign, nonatomic) IBOutlet UIButton *bButton;
@property (assign, nonatomic) IBOutlet UIButton *upButton;
@property (assign, nonatomic) IBOutlet UIButton *downButton;
@property (assign, nonatomic) IBOutlet UIButton *leftButton;
@property (assign, nonatomic) IBOutlet UIButton *rightButton;

@property (strong, nonatomic) MWTextBox *textBox;

- (IBAction)pressed:(id)sender;
- (IBAction)released:(id)sender;

@end
