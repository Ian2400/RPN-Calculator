//
//  GraphView.h
//  RPN Calculator
//
//  Created by Ian Pytlarz on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol graphViewDataSource
- (double) yValueToDraw:(double)xValue;
- (void) setProgramDescription;
@end

@interface GraphView : UIView
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint axesOrigin;
@property (nonatomic) CGPoint startingOrigin;
@property (nonatomic, weak) IBOutlet id <graphViewDataSource> dataSource;
@end
