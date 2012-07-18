//
//  GraphViewController.h
//  RPN Calculator
//
//  Created by Ian Pytlarz on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphViewController : UIViewController
@property (nonatomic, strong) NSArray *thisProgram;
-(void)setProgram:(NSArray *)program;
@end
