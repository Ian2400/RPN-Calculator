//
//  CalculatorViewController.h
//  RPN Calculator
//
//  Created by Ian Pytlarz on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController <UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *calcHistory;
@property (weak, nonatomic) IBOutlet UILabel *variableDescription;

@end
