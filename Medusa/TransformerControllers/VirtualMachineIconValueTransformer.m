//
//  VirtualMachineIconValueTransformer.m
//  Medusa
//
//  Created by Giancarlo Mariot on 14/09/2013.
//  Copyright (c) 2013 Giancarlo Mariot. All rights reserved.
//
//------------------------------------------------------------------------------
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//------------------------------------------------------------------------------

#import "VirtualMachineIconValueTransformer.h"
#import "VirtualMachinesEntityModel.h"

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_OFF;
//------------------------------------------------------------------------------

@implementation VirtualMachineIconValueTransformer

+ (Class)transformedValueClass {
    return [NSImage class]; 
}

+ (BOOL)allowsReverseTransformation { 
    return NO; 
}

- (id)transformedValue:(id)value {
    
    short iconValue = [value integerValue];
    
    DDLogVerbose(@"VM Icon Value Transformer - value: %@ -- %ld", value, iconValue);
    
    switch (iconValue) {
        case BlackAndWhiteHappyVMLocked:
            return [NSImage imageNamed:@"BlackAndWhiteHappyMacLocked.png"];
        case ColouredHappyVMLocked:
            return [NSImage imageNamed:@"ColouredHappyMacLocked.png"];
        case BlackAndWhiteHappyVM:
            return [NSImage imageNamed:@"BlackAndWhiteHappyMac2x.png"];
        case ColouredHappyVM:
            return [NSImage imageNamed:@"ColouredHappyMac2x.png"];
        case BlackAndWhiteNoDisk:
            return [NSImage imageNamed:@"noDiskBW.png"];
        case ColouredNoDisk:
            return [NSImage imageNamed:@"noDiskColour.png"];
        case QuestionMarkVM:
            return [NSImage imageNamed:@"QuestionMarkMac.png"];
        case DeadVM:
            return [NSImage imageNamed:@"DeadMac.png"];
            
    }
    
    return [NSImage imageNamed:@"newVm.icns"];
}

@end
