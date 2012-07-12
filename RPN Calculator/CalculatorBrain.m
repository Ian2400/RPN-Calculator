	//
//  CalculatorBrain.m
//  RPN Calculator
//
//  Created by Ian Pytlarz on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic,strong) NSMutableArray *programStack;
@property (nonatomic, strong) NSMutableSet *variablesUsedInProgram;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;
@synthesize variablesUsedInProgram = _variablesUsedInProgram;

//returns a nil set if there is none
-(NSMutableSet *)variablesUsedInProgram
{
    NSString *pi = @"pi";
    if(_variablesUsedInProgram == nil) _variablesUsedInProgram = [[NSMutableSet alloc] initWithObjects:pi, nil];
    return _variablesUsedInProgram;
}

//returns a nil stack if there is none
-(NSMutableArray *)programStack
{
    if(_programStack == nil) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

//add operand to the program
- (void)pushOperand:(id)operand
{
    [self.programStack addObject:operand];
}

//undo the last operation on the stack
-(void)clearLastProgramItem
{
    int count = [self.programStack count];
    id lastObject = [self.programStack objectAtIndex:(count-1)];
    if([lastObject isKindOfClass:[NSString class]])
    {
        if([CalculatorBrain isTwoOperandOperation:[self.programStack objectAtIndex:(count-1)]]==YES)
        {
            [self.programStack removeLastObject];
        }
    } else 
    {
        [self.programStack removeLastObject];
    }
}

//clear the program
- (void)clearStack
{
    [self.programStack removeAllObjects];  
}

//getter of program returns itself, but immutable
- (id)program
{
    return [self.programStack copy];
}

//returns a description of the current program
- (NSString *)programDescriptionForDisplay:(id)program
{
    NSString *description;
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    if ([[stack objectAtIndex:0] isKindOfClass:[NSString class]])
    {
        if ([CalculatorBrain isTwoOperandOperation:[stack objectAtIndex:0]]==YES)
        {
            [self clearStack];
            description = @"";
        }
    } else description = [CalculatorBrain descriptionOfProgram:stack usingVars:self.variablesUsedInProgram];        
    return description;
}

//I wanted to call this method from the controller, but coded it wrong and didn't take the time to fix it
+ (NSString *)descriptionOfProgram:(NSMutableArray *)stack usingVars:(NSMutableSet *)varSet
{
    NSString *descriptionForCalculatorDisplay = @"";
    NSMutableArray *programStackInLogicalOrder = [stack mutableCopy];
    NSMutableArray *listOfPrograms = [[NSMutableArray alloc] init];
    int i;
    id currentObjInStack;
    
    //create a stack with a logical order
    for (i=0;i<[stack count];i++)
    {
        currentObjInStack = [stack objectAtIndex:i];
        if ([currentObjInStack isKindOfClass:[NSString class]]) 
        {
            if ([self isTwoOperandOperation:currentObjInStack]==YES)
            {
                [programStackInLogicalOrder replaceObjectAtIndex:(i) withObject:[programStackInLogicalOrder objectAtIndex:(i-1)]];
                [programStackInLogicalOrder replaceObjectAtIndex:(i-1) withObject:currentObjInStack];
            } 
        }
    }
    
    currentObjInStack = nil;
    
    //NSLog(@"Current Logical Stack:");
    //for (id obj in programStackInLogicalOrder) NSLog(@"%@",obj);
    
    //create a logical program description from the now logical array
    for (i=0;i<[programStackInLogicalOrder count];i++)
    {
        currentObjInStack = [programStackInLogicalOrder objectAtIndex:i];
        
        if ([currentObjInStack isKindOfClass:[NSNumber class]])
        {
            if (descriptionForCalculatorDisplay == @"")
            {
                descriptionForCalculatorDisplay = [NSString stringWithFormat:@"%@%@",descriptionForCalculatorDisplay,[currentObjInStack stringValue]];
            } else if(i==([programStackInLogicalOrder count]-1))
            {
                descriptionForCalculatorDisplay = [NSString stringWithFormat:@"%@%@%@",descriptionForCalculatorDisplay,@" ",[currentObjInStack stringValue]];
            } else 
            {
                descriptionForCalculatorDisplay = [NSString stringWithFormat:@"%@%@%@%@",descriptionForCalculatorDisplay,@" ",[currentObjInStack stringValue],@")"];
            }
            if(i<[programStackInLogicalOrder count]-1){
            if([[programStackInLogicalOrder objectAtIndex:(i+1)] isKindOfClass:[NSNumber class]])
            {
                descriptionForCalculatorDisplay = [descriptionForCalculatorDisplay stringByAppendingString:@", "];
                [listOfPrograms addObject:descriptionForCalculatorDisplay];
                descriptionForCalculatorDisplay = @"";
            }
            }
        } else if ([currentObjInStack isKindOfClass:[NSString class]]) 
        {
            if ([self isOneOperandOperation:currentObjInStack]==YES)
            {
                if(i==0) descriptionForCalculatorDisplay = @"0";
                descriptionForCalculatorDisplay = [NSString stringWithFormat:@"%@%@%@%@",currentObjInStack,@"(",descriptionForCalculatorDisplay,@")"];
                if(i<[programStackInLogicalOrder count]-1){
                    if([[programStackInLogicalOrder objectAtIndex:(i+1)] isKindOfClass:[NSNumber class]])
                    {
                        descriptionForCalculatorDisplay = [descriptionForCalculatorDisplay stringByAppendingString:@", "];
                        [listOfPrograms addObject:descriptionForCalculatorDisplay];
                        descriptionForCalculatorDisplay = @"";
                    }
                }
            } else if([self isTwoOperandOperation:currentObjInStack]==YES)
            {
                if(i!=0)
                {
                    if (i==([programStackInLogicalOrder count]-2))
                    {
                        descriptionForCalculatorDisplay = [NSString stringWithFormat:@"%@%@%@",descriptionForCalculatorDisplay,@" ",currentObjInStack];
                    } else {
                        descriptionForCalculatorDisplay = [NSString stringWithFormat:@"%@%@%@%@",@"(",descriptionForCalculatorDisplay,@" ",currentObjInStack];
                    }
                }
            } else if([CalculatorBrain isVariableUsedInProgram:currentObjInStack inSet:varSet]==YES)
            {
                if (i==0)
                { 
                    descriptionForCalculatorDisplay = [descriptionForCalculatorDisplay stringByAppendingString:currentObjInStack];                    
                } else if (i==([programStackInLogicalOrder count]-1))
                {
                    //Do nothing because user just entered a variable at end of stack
                } else 
                {
                    descriptionForCalculatorDisplay = [NSString stringWithFormat:@"%@%@%@",descriptionForCalculatorDisplay,@" ",currentObjInStack];
                }
            }
        }
    }

    for (i=0;i<[listOfPrograms count];i++){
        descriptionForCalculatorDisplay = [[listOfPrograms objectAtIndex:i] stringByAppendingString:descriptionForCalculatorDisplay];
    }
    
    return descriptionForCalculatorDisplay;
}

//do a calculation
+(double) popOperandOffStack:(NSMutableArray *)stack usingVariables:(NSDictionary *)Dict
{
    double result = 0;

    id topOfStack = [stack lastObject];
    //NSLog(@"Popping Operand...");
    //for (id obj in stack) NSLog(@"%@",obj);
    if (topOfStack) [stack removeLastObject];
    //NSLog(@"Operand Popped!");
    //for (id obj in stack) NSLog(@"%@",obj);

    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;

        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack usingVariables:Dict] + [self popOperandOffStack:stack usingVariables:Dict];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffStack:stack usingVariables:Dict] * [self popOperandOffStack:stack usingVariables:Dict];
        } else if ([@"-" isEqualToString:operation]) {
            double subtractor = 0;
            subtractor = [self popOperandOffStack:stack usingVariables:Dict];
            result = [self popOperandOffStack:stack usingVariables:Dict] - subtractor;
        } else if ([@"/" isEqualToString:operation]) {
            double divisor = 0;
            divisor = [self popOperandOffStack:stack usingVariables:Dict];
            result = [self popOperandOffStack:stack usingVariables:Dict] / divisor;
        } else if ([@"pi" isEqualToString:operation]) {
            result = 3.14;
        } else if ([@"sin" isEqualToString:operation]) {
            result = sin([self popOperandOffStack:stack usingVariables:Dict]);
        } else if ([@"cos" isEqualToString:operation]) {
            result = cos([self popOperandOffStack:stack usingVariables:Dict]);
        } else if ([@"sqrt" isEqualToString:operation]) {
            result = sqrt([self popOperandOffStack:stack usingVariables:Dict]);
        } else {
            for (NSString* key in Dict) {
            if ([key isEqualToString:operation] == YES) {
                result = [[Dict objectForKey:key] doubleValue];
            }
            }
        }
    }
    return result;
}

//run the program with passed dictionary
+(double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self.class popOperandOffStack:stack usingVariables:variableValues];
}
 
//checks if a string is an operation that requires two operands
+(BOOL)isTwoOperandOperation:(NSString *)operation{
    if ([operation isEqualToString:@"+"]) {
        return YES;
     } else if ([@"*" isEqualToString:operation]) {
        return YES;
     } else if ([@"-" isEqualToString:operation]) {
        return YES;
     } else if ([@"/" isEqualToString:operation]) {
         return YES;
     } else return NO;
}

//checks if a string is an operation that requires two operands
+(BOOL)isOneOperandOperation:(NSString *)operation{
    if ([operation isEqualToString:@"sqrt"]) {
        return YES;
    } else if ([@"sin" isEqualToString:operation]) {
        return YES;
    } else if ([@"cos" isEqualToString:operation]) {
        return YES;
    } else return NO;
}

+(BOOL)isVariableUsedInProgram:(NSString *)operation inSet:(NSMutableSet *)variablesUsedInProgram{
    if ([variablesUsedInProgram containsObject:operation]==YES) {
        return YES;
    } else return NO;
}

-(void)clearVariablesUsedInProgram{
    [self.variablesUsedInProgram removeAllObjects];
}
-(void)addVariableUsedInProgram:(id)first,...{
    id eachArg;
    va_list alist;
    va_start(alist, first);
    while ((eachArg = va_arg(alist, id)))
    [self.variablesUsedInProgram addObject:eachArg];        
    va_end(alist);
}

+ (NSString *) append:(id) first, ...
{
    NSString * result = @"";
    id eachArg;
    va_list alist;
    if(first)
    {
        result = [result stringByAppendingString:first];
        va_start(alist, first);
        while ((eachArg = va_arg(alist, id)))
            result = [result stringByAppendingString:eachArg];
        va_end(alist);
    }
    return result;
    
}
@end
