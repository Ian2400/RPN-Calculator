//
//  GraphViewController.h
//  RPN Calculator
//
//  Created by Ian Pytlarz on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface GraphViewController : UIViewController <SplitViewBarButtonItemPresenter>
@property (nonatomic, strong) NSArray *thisProgram;
@property (weak, nonatomic) IBOutlet UILabel *programDescription;
-(void)setProgram:(NSArray *)program;
@end
