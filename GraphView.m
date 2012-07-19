//
//  GraphView.m
//  RPN Calculator
//
//  Created by Ian Pytlarz on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"


@implementation GraphView

@synthesize scale = _scale;
@synthesize dataSource = _dataSource;
@synthesize axesOrigin = _axesOrigin;
@synthesize startingOrigin = _startingOrigin;
@synthesize isDrawing = _isDrawing;

//Defines the default scale as slightly less than 1
#define DEFAULT_SCALE 10;

-(BOOL)isDrawing
{
    if(!_isDrawing) {
        return NO;
    } else {
        return YES;
    }
}

-(CGFloat) scale
{
    if(!_scale) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        CGFloat defaultScale = DEFAULT_SCALE; 
        [prefs setFloat:defaultScale forKey:@"scale"];   
        return DEFAULT_SCALE;
    } else {
        return _scale;
    }
}

//returns midpoint if there isn't an origin set by a gesture yet

-(CGPoint) axesOrigin
{
    CGPoint noOriginYet;
    noOriginYet.x = 0;
    noOriginYet.y = 0;
    if(CGPointEqualToPoint(noOriginYet, _axesOrigin)==YES) {
        CGPoint centerPoint;
        centerPoint.x = self.bounds.origin.x + self.bounds.size.width/2;
        centerPoint.y = self.bounds.origin.y + self.bounds.size.height/2;
        _axesOrigin = centerPoint;
        _startingOrigin = centerPoint;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setFloat:self.axesOrigin.x forKey:@"axesOriginX"];
        [prefs setFloat:self.axesOrigin.y forKey:@"axesOriginY"];
        [prefs setFloat:self.startingOrigin.x forKey:@"startingOriginX"];
        [prefs setFloat:self.startingOrigin.y forKey:@"startingOriginY"];
        return _axesOrigin;
    } else {
        return _axesOrigin;
    }
}

-(void)setScale:(CGFloat)scale
{  
    if(scale !=_scale) {
        if(scale > 100) {
        scale = 100;
        } else if(_scale < .1) {
            scale = .1;
        }
        _scale = scale; 
        [self setNeedsDisplay];
    }
}

-(void)setOrigin:(CGPoint)newOrigin
{  
    if(CGPointEqualToPoint(newOrigin, _axesOrigin)==YES) {
    } else {
        _axesOrigin = newOrigin;
        [self setNeedsDisplay];
    }
}

//changes the scale based on pinching
-(void)pinch:(UIPinchGestureRecognizer *)gesture
{
    self.isDrawing = YES;
    if(gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateEnded)
    { 
        [self setScale:(self.scale + ((gesture.scale - 1) * 3))];
    }
    if(gesture.state == UIGestureRecognizerStateEnded) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setFloat:self.scale forKey:@"scale"];   
        self.isDrawing = NO;
        gesture.scale = 1;
        [self setNeedsDisplay];
    }
}

//changes the graph origin based on a pan
-(void)handleOriginPanGesture:(UIPanGestureRecognizer *)gesture
{
    CGPoint newOrigin;
    self.isDrawing = YES;
    if(gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateEnded)
    {
        newOrigin.x = self.startingOrigin.x + [gesture translationInView:self].x;
        newOrigin.y = self.startingOrigin.y + [gesture translationInView:self].y;
        [self setOrigin:newOrigin];
    }
    if(gesture.state == UIGestureRecognizerStateEnded) {
        self.startingOrigin = self.axesOrigin;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setFloat:self.axesOrigin.x forKey:@"axesOriginX"];
        [prefs setFloat:self.axesOrigin.y forKey:@"axesOriginY"];
        [prefs setFloat:self.startingOrigin.x forKey:@"startingOriginX"];
        [prefs setFloat:self.startingOrigin.y forKey:@"startingOriginY"];
        self.isDrawing = NO;
        [self setNeedsDisplay];
    }
}

//changes the graph origin based on a triple tap
-(void)handleTripleTap:(UITapGestureRecognizer *)gesture
{
    self.isDrawing = YES;
    [self setOrigin:[gesture locationInView:self]];
    self.startingOrigin = self.axesOrigin;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setFloat:self.axesOrigin.x forKey:@"axesOriginX"];
    [prefs setFloat:self.axesOrigin.y forKey:@"axesOriginY"];
    [prefs setFloat:self.startingOrigin.x forKey:@"startingOriginX"];
    [prefs setFloat:self.startingOrigin.y forKey:@"startingOriginY"];
    self.isDrawing = NO;
    [self setNeedsDisplay];
}

-(void) setup
{
    self.contentMode = UIViewContentModeRedraw;    //when bounds change, redraw
}

-(void) awakeFromNib
{
    [self setup]; //get initialized when we leave a storyboard
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    CGFloat thisScale;
    CGPoint thisOrigin;
    //if you are in the middle of drawing, use the instance vars, otherwise use the defaults
    if(self.isDrawing == YES)
    {
        thisScale = self.scale;
        thisOrigin = self.axesOrigin;
    } else {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        thisScale = [prefs floatForKey:@"scale"];
        thisOrigin.x = [prefs floatForKey:@"axesOriginX"];
        thisOrigin.y = [prefs floatForKey:@"axesOriginY"];
        self.scale = thisScale;
        self.axesOrigin = thisOrigin;
        self.startingOrigin = thisOrigin;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Draw the axes
    
    CGRect bounds = self.bounds;
    
    CGFloat pointsPerUnit = thisScale / self.contentScaleFactor;
    
    //[AxesDrawer drawAxesInRect:bounds originAtPoint:self.axesOrigin scale:pointsPerUnit];
    [AxesDrawer drawAxesInRect:bounds originAtPoint:thisOrigin scale:pointsPerUnit];
    
    //draw line
    
    double graphXValue = 0.0;
    double graphYValue = 0.0;
    float viewYValue = 0.0;
    
    for (float viewXValue = 0.0; viewXValue <= self.bounds.size.width; viewXValue = viewXValue + 1.0 / self.contentScaleFactor) {
        //set up the path start
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, viewXValue, viewYValue);
        
        //get the next point on the graph
        
        graphXValue = (viewXValue - thisOrigin.x)/pointsPerUnit;
        graphYValue = [self.dataSource yValueToDraw:graphXValue];
        viewYValue = (thisOrigin.y - (graphYValue*pointsPerUnit));
                
        //set up the path draw
        CGContextAddLineToPoint(context, viewXValue, viewYValue);
        CGContextStrokePath(context);
    }
    [self.dataSource setProgramDescription];
}


@end
