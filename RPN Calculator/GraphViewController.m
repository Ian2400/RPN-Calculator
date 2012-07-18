//
//  GraphViewController.m
//  RPN Calculator
//
//  Created by Ian Pytlarz on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"

@interface GraphViewController () <graphViewDataSource>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@end

@implementation GraphViewController

@synthesize graphView = _graphView;
@synthesize thisProgram = _thisProgram;

-(double)yValueToDraw:(double)xValue
{
    double result = 5.0;
    
    if(xValue) {
        NSDictionary *xValueDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:xValue],@"x", nil]; 
        result = [CalculatorBrain runProgram:self.thisProgram usingVariableValues:xValueDict];
    }
    
    return result;
}

-(void)setProgram:(NSArray *)program
{
    _thisProgram = program;
    //[self.graphView setNeedsDisplay];
}

//set up a pinch recognizer
-(void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(handleOriginPanGesture:)]];
    
    // Create triple tap gesture recognizer
    UITapGestureRecognizer *oneFingerThreeTaps = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(handleTripleTap:)];
    
    // Set required taps and number of touches
    [oneFingerThreeTaps setNumberOfTapsRequired:3];
    [oneFingerThreeTaps setNumberOfTouchesRequired:1];
    
    // Add the gesture to the view
    [self.graphView addGestureRecognizer:oneFingerThreeTaps];
    
    self.graphView.dataSource = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

@end
