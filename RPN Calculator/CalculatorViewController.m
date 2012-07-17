//
//  CalculatorViewController.m
//  RPN Calculator
//
//  Created by Ian Pytlarz on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "math.h"	

@interface CalculatorViewController ()

@property (nonatomic,strong) CalculatorBrain *brain;
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) NSMutableDictionary *currentVariableValues;
@property (nonatomic, strong) NSMutableSet *possibleVariableNames;
@end

@implementation CalculatorViewController
@synthesize display = _display;
@synthesize calcHistory = _calcHistory;
@synthesize currentVariableValues = _currentVariableValues;
@synthesize variableDescription = _variableDescription;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize possibleVariableNames = _possibleVariableNames;
@synthesize brain = _brain;
	
-(CalculatorBrain *) brain
{
    if(!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}
-(NSMutableSet *) possibleVariableNames
{
    if(!_possibleVariableNames) _possibleVariableNames = [[NSMutableSet alloc] initWithObjects:@"x",@"y",@"a",@"b",@"pi", nil];
    return _possibleVariableNames;
}

/*-(NSMutableDictionary *) currentVariableValues
{
    if(!_currentVariableValues) _currentVariableValues = [[NSMutableDictionary alloc] initWithObjectsAndKeys:0,@"foo", nil];
    return _currentVariableValues;
}*/

- (IBAction)pointPressed:(UIButton *)sender 
{
    NSRange range = [self.display.text rangeOfString:@"."];
    if(self.userIsInTheMiddleOfEnteringANumber == NO){
        self.display.text = @"0.";
        self.userIsInTheMiddleOfEnteringANumber = YES;
    } else {
        if(range.location==NSNotFound)
        {
            self.display.text = [self.display.text stringByAppendingString:@"."];  
        }

    }
}
- (IBAction)backPressed:(id)sender {
    if ([self.display.text length]==1)
    {
        self.userIsInTheMiddleOfEnteringANumber = NO;
    }
    if(self.userIsInTheMiddleOfEnteringANumber==YES)
    {
        self.display.text = [self.display.text substringToIndex:([self.display.text length]-1)];
    } else 
    {
        [self.brain clearLastProgramItem];
        NSMutableArray *thisProgram = [[self.brain program] mutableCopy];
        self.calcHistory.text = [CalculatorBrain descriptionOfProgram:thisProgram usingVars:self.possibleVariableNames];
        double result = [CalculatorBrain runProgram:[self.brain program] usingVariableValues:[self.currentVariableValues copy]];
        NSString *displayThis = [NSString stringWithFormat:@"%g",result];
        self.display.text = displayThis;
    }
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    NSString *digit = sender.currentTitle;
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)enterPressed 
{
    NSNumber *operand = [NSNumber numberWithDouble:[self.display.text doubleValue]];
    [self.brain pushOperand:operand];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    //stop entering a number and push it to the stack if in the middle of entering one
    if(self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    
    //push what was pressed
    [self.brain pushOperand:sender.currentTitle];

    NSString *descriptionOfProgram = @"";
    if ([[[self.brain program] objectAtIndex:0] isKindOfClass:[NSString class]])
    {
        //if the first thing on the stack is a two operand operation, clear the stack
        if ([CalculatorBrain isTwoOperandOperation:[[self.brain program] objectAtIndex:0]]==YES)
        {
            [self.brain clearStack];
        }
    }
    if([self.possibleVariableNames containsObject:sender.currentTitle]==YES) {
        NSNumber *result = [[NSNumber alloc]initWithInt:0];
        if([self.currentVariableValues objectForKey:sender.currentTitle]) {
             result = [self.currentVariableValues objectForKey:sender.currentTitle];
        } else if([sender.currentTitle isEqualToString:@"pi"]==YES) {
            result = [[NSNumber alloc]initWithDouble:3.14];
        }
        NSString *resultString = [result stringValue];
        self.display.text = resultString;
    } else {
        NSMutableArray *thisProgram = [[self.brain program] mutableCopy];
        descriptionOfProgram = [CalculatorBrain descriptionOfProgram:thisProgram usingVars:self.possibleVariableNames];
        self.calcHistory.text = descriptionOfProgram;
        double result = [CalculatorBrain runProgram:[self.brain program] usingVariableValues:self.currentVariableValues];
        NSString *resultString = [NSString stringWithFormat:@"%g", result];
        self.display.text = resultString;
    }
}

- (IBAction)setVarsPressed:(UIButton *)defTitle {
    //clear the dictionary and the variable set in the brain instance
    [self.currentVariableValues removeAllObjects];
    //[self.currentVariables removeAllObjects];
    
    //define the set of variables in the brain instance and set up the dictionary
    if([defTitle.currentTitle isEqualToString: @"x1 y2 a3"]==YES) {
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:1],@"x",
                                         [NSNumber numberWithInt:2],@"y",
                                         [NSNumber numberWithInt:3],@"a",
                                         nil];
        self.currentVariableValues = tempDict;
    } else if([defTitle.currentTitle isEqualToString: @"all 4"]==YES) {
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:4],@"x",
                                         [NSNumber numberWithInt:4],@"y",
                                         [NSNumber numberWithInt:4],@"a",
                                         [NSNumber numberWithInt:4],@"b",                                         nil];
        self.currentVariableValues = tempDict;
    } else if([defTitle.currentTitle isEqualToString: @"y5"]==YES) {
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:5],@"y",
                                         nil];
        self.currentVariableValues = tempDict;
    }
 
    //display a description of the new variable assignments on the view
     NSString *description = @"";
     NSNumber *varVal = 0;
     
     for (NSString* key in self.currentVariableValues) {
         varVal = [self.currentVariableValues objectForKey:key];
         description = [description stringByAppendingString:key];
         description = [description stringByAppendingString:@" = "];
         description = [description stringByAppendingString:[varVal stringValue]];
         description = [description stringByAppendingString:@" "];
     }
     
     self.variableDescription.text = description;
}

- (IBAction)clearPressed
{
    [self.brain clearStack];
    self.display.text = @"0";
    self.calcHistory.text = @"";
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (void)viewDidUnload {
    [self setVariableDescription:nil];
    [super viewDidUnload];
}
@end
