//
//  CalculatorBrain.h
//  RPN Calculator
//
//  Created by Ian Pytlarz on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject
@property (readonly) id program;

- (void)pushOperand:(id)operand;
- (void)clearStack;

+ (NSString *)descriptionOfProgram:(NSMutableArray *)stack usingVars:(NSMutableSet *)varSet;
+(double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+(BOOL)isTwoOperandOperation:(NSString *)operation;
+(BOOL)isOneOperandOperation:(NSString *)operation;
+(BOOL)isVariableUsedInProgram:(NSString *)operation inSet:(NSMutableSet *)variablesUsedInProgram;
-(void)clearLastProgramItem;
-(void)clearVariablesUsedInProgram;
-(void)addVariableUsedInProgram:(id)first,...;
+ (NSString *) append:(id) first, ...;
@end
