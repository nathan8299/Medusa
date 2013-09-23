//
//  DrivesModel.h
//  Medusa
//
//  Created by Giancarlo Mariot on 18/05/2012.
//  Copyright (c) 2012 Giancarlo Mariot. All rights reserved.
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

enum driveFormat {
    formatLisaFS  = 1,
    formatMFS     = 2,
    formatHFS     = 3,
    formatHFSPlus = 4,
    formatISO9660 = 5,
    formatFAT     = 6,
    formatOther   = 7
};

@class RelationshipVirtualMachinesDrivesModel;

@interface DrivesModel : NSManagedObject

@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSSet    * virtualMachines;
@property (nonatomic, retain) NSNumber * format;
@property (nonatomic, retain) NSNumber * capacity;
@end

@interface DrivesModel (CoreDataGeneratedAccessors)

- (void)addVirtualMachinesObject:(RelationshipVirtualMachinesDrivesModel *)value;
- (void)removeVirtualMachinesObject:(RelationshipVirtualMachinesDrivesModel *)value;
- (void)addVirtualMachines:(NSSet *)values;
- (void)removeVirtualMachines:(NSSet *)values;

//Test
//+ (NSEntityDescription**) insertNewObjectInManagedObjectContext:(NSManagedObjectContext *)value;

@end
