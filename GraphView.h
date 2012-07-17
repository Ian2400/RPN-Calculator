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
//- (float) programForGraphView:(GraphView *)sender;
@end

@interface GraphView : UIView
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint axesOrigin;
@property (nonatomic) CGPoint startingOrigin;
-(void)pinch:(UIPinchGestureRecognizer *)gesture;
-(void)handleOriginPanGesture:(UIPanGestureRecognizer *)gesture;
@property (nonatomic, weak) IBOutlet id <graphViewDataSource> dataSource;
@end
