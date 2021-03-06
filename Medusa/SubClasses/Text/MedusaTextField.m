//
//  MedusaTextField.m
//  Medusa
//
//  Created by Giancarlo Mariot on 25/02/2015.
//  Copyright (c) 2015 Giancarlo Mariot. All rights reserved.
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

#import "MedusaTextField.h"

@implementation MedusaTextView

// Try this:
// https://developer.apple.com/library/mac/qa/qa1454/_index.html

//- (BOOL)textShouldEndEditing:(NSText *)textObject {
//    NSEvent * event = [[NSApplication sharedApplication] currentEvent];
//    if ([event type] == NSKeyDown && [event keyCode] == 36) {
//        [textObject insertNewlineIgnoringFieldEditor:nil];
//        return NO;
//    } else {
//        return [super textShouldEndEditing:textObject];
//    }
//}

- (void)textDidChange:(NSNotification *)notification {
    NSLog(@"qwqwq");
}


- (void)controlTextDidChange:(NSNotification*)aNotification {
    NSLog(@"aaa");
}

@end
