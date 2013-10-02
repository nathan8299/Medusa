//
//  AppDelegate.m
//  Medusa
//
//  Created by Giancarlo Mariot on 10/04/2012.
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

#import "AppDelegate.h"

//------------------------------------------------------------------------------
// Windows
#import "VirtualMachineWindowController.h"  //VM Window
#import "AssetsWindowController.h"          //Assets Window
#import "PreferencesWindowController.h"     //Preferences Window
#import "IconValueTransformer.h"            //Transforms a coredata integer in an icon
//Helpers:

//Models:
#import "VirtualMachinesEntityModel.h"
#import "RomFilesEntityModel.h"
#import "EmulatorsEntityModel.h"
#import "PreferencesModel.h"
#import "VirtualMachineModel.h"

#import "EmulatorHandleController.h" //testing

//------------------------------------------------------------------------------
// Lumberjack logger
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//------------------------------------------------------------------------------

@implementation AppDelegate

@synthesize window = _window;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize managedObjectContext = __managedObjectContext;

//------------------------------------------------------------------------------
// Methods.

#pragma mark – Dealloc

/*!
 * @method      dealloc:
 * @discussion  Always in the top of the files!
 */
- (void)dealloc {
    [__persistentStoreCoordinator release];
    [__managedObjectModel release];
    [__managedObjectContext release];
    [windowsForVirtualMachines release];
    [super dealloc];
}

//------------------------------------------------------------------------------
// Application methods.

#pragma mark – Main Window actions

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Virtual machine sheets

/*!
 * @method      showNewMachineView:
 * @abstract    Displays the new VM sheet.
 */
- (IBAction)showNewMachineView:(id)sender {
    [ NSApp
            beginSheet: newMachineView
        modalForWindow: (NSWindow *)_window
         modalDelegate: self
        didEndSelector: nil
           contextInfo: nil
    ];
}

/*!
 * @method      showNewMachineView:
 * @abstract    Displays the new VM sheet.
 */
- (IBAction)showCloneMachineView:(id)sender {
    [ NSApp
            beginSheet: cloneMachineView
        modalForWindow: (NSWindow *)_window
         modalDelegate: self
        didEndSelector: nil
           contextInfo: nil
    ];
}

/*!
 * @method      showDeleteMachineView:
 * @abstract    Displays the delete VM sheet.
 */
- (IBAction)showDeleteMachineView:(id)sender {
    [ NSApp
            beginSheet: deleteMachineView
        modalForWindow: (NSWindow *)_window
         modalDelegate: self
        didEndSelector: nil
           contextInfo: nil
    ];
}

/*!
 * @method      showErrorSheetView:
 * @abstract    Displays the error sheet.
 */
- (IBAction)showErrorSheetView:(id)sender {
    [ NSApp
            beginSheet: errorSheetView
        modalForWindow: (NSWindow *)_window
         modalDelegate: self
        didEndSelector: nil
           contextInfo: nil
    ];
}


/*!
 * @method      endNewMachineView:
 * @abstract    Closes the new VM sheet.
 */
- (IBAction)endNewMachineView:(id)sender {
    [newMachineErrorLabel setHidden:YES];
    [newMachineNameField setStringValue:@""];
    [NSApp endSheet:newMachineView];
    [newMachineView orderOut:sender];
}

/*!
 * @method      endNewMachineView:
 * @abstract    Closes the new VM sheet.
 */
- (IBAction)endCloneMachineView:(id)sender {
    [cloneMachineErrorLabel setHidden:YES];
    [cloneMachineNameField setStringValue:@""];
    [NSApp endSheet:cloneMachineView];
    [cloneMachineView orderOut:sender];
}

/*!
 * @method      endNewMachineView:
 * @abstract    Closes the new VM sheet.
 */
- (IBAction)endDeleteMachineView:(id)sender {
    [NSApp endSheet:deleteMachineView];
    [deleteMachineView orderOut:sender];
}

/*!
 * @method      endNewMachineView:
 * @abstract    Closes the new VM sheet.
 */
- (IBAction)endErrorSheetView:(id)sender {
    [NSApp endSheet:errorSheetView];
    [errorSheetView orderOut:sender];
}

/*!
 * @method      saveNewVirtualMachine:
 * @abstract    Saves the new virtual machine created by the user to the
 *              coredata.
 * @discussion  This method is sort of messed. There is a need to check
 *              the existence of the vm model before proceeding and this
 *              leads to a whole new world of lines that I suppose are
 *              not needed. Remember to refactor in the near future.
 */
- (IBAction)saveNewVirtualMachine:(id)sender {
    
    // Parses name:
    NSString * newMachineName = [[NSString alloc] initWithString:[newMachineNameField stringValue]];

    if ([newMachineName length] == 0) {
        DDLogVerbose(@"VM name is empty.");
        [newMachineErrorLabel setStringValue:@"Name cannot be empty."];
        [newMachineErrorLabel setHidden:NO];
        [newMachineName release];
        return;
    }

    //Gets the Managed Object Context:
    NSManagedObjectContext * managedObjectContext      = [self managedObjectContext];
    VirtualMachineModel    * virtualMachineModelObject = [[VirtualMachineModel alloc] initWithManagedObjectContext:managedObjectContext];
    
    if ([virtualMachineModelObject existsMachineNamed:newMachineName]) {
        DDLogVerbose(@"VM name is being used.");
        [newMachineErrorLabel setStringValue:@"Name is already in use."];
        [newMachineErrorLabel setHidden:NO];
        [virtualMachineModelObject release];
        [newMachineName release];
        return;
    }
    
    [virtualMachineModelObject insertMachineNamed:newMachineName];
    [self selectLastCreatedVirtualMachine:sender];
    [self endNewMachineView:sender];
    [virtualMachineModelObject release];
    [newMachineName release];

}

// Clones VM:

/*!
 * @method      saveNewVirtualMachine:
 * @abstract    Saves the new virtual machine created by the user to the
 *              coredata.
 * @discussion  This method is sort of messed. There is a need to check
 *              the existence of the vm model before proceeding and this
 *              leads to a whole new world of lines that I suppose are
 *              not needed. Remember to refactor in the near future.
 */
- (IBAction)saveCloneVirtualMachine:(id)sender {
    
    // Parses name:
    NSString * newMachineName = [[NSString alloc] initWithString:[cloneMachineNameField stringValue]];
    
    if ([newMachineName length] == 0) {
        DDLogVerbose(@"VM name is empty.");
        [cloneMachineErrorLabel setStringValue:@"Name cannot be empty."];
        [cloneMachineErrorLabel setHidden:NO];
        [newMachineName release];
        return;
    }
    
    //Gets the Managed Object Context:
    NSManagedObjectContext * managedObjectContext      = [self managedObjectContext];
    VirtualMachineModel    * virtualMachineModelObject = [[VirtualMachineModel alloc] initWithManagedObjectContext:managedObjectContext];
    
    if ([virtualMachineModelObject existsMachineNamed:newMachineName]) {
        DDLogVerbose(@"VM name is being used.");
        [cloneMachineErrorLabel setStringValue:@"Name is already in use."];
        [cloneMachineErrorLabel setHidden:NO];
        [newMachineName release];
        [virtualMachineModelObject release];
        return;
    }
    
    //Machine to clone:
    VirtualMachinesEntityModel * machineToClone = [[virtualMachinesArrayController selectedObjects] objectAtIndex:0];
    
    [virtualMachineModelObject cloneMachine:machineToClone withName:newMachineName];
    [self selectLastCreatedVirtualMachine:sender];
    [self endCloneMachineView:sender];
    [virtualMachineModelObject release];
    [newMachineName release];
    
}

- (void)selectLastCreatedVirtualMachine:(id)sender {

    BOOL openDetailsAfterCreation = [
        [NSUserDefaults standardUserDefaults]
            boolForKey:@"openDetailsAfterCreation"
    ];

    //--------------------------------------------------------------------------
    //Focus in the new item.
    
    [virtualMachinesArrayController
        setSelectedObjects:
        [NSArray arrayWithObject:
            [[virtualMachinesArrayController arrangedObjects] lastObject]
        ]
    ];

    //--------------------------------------------------------------------------
    //Release all
    
    if (openDetailsAfterCreation == YES) {
        [self openVirtualMachineWindow:sender];
    }

}

- (IBAction)deleteVirtualMachine:(id)sender {

    NSManagedObjectContext * managedObjectContext = [self managedObjectContext];
    
    NSArray * selectedVirtualMachines = [[
        [NSArray alloc] initWithArray:[virtualMachinesArrayController selectedObjects]
    ] autorelease ];

    //The user can select only one in the current interface, but anyway...
    VirtualMachinesEntityModel * virtualMachine = [selectedVirtualMachines objectAtIndex:0];
    
    NSString * preferencesFilePath = [
        [NSMutableString alloc] initWithFormat:
            @"%@/%@Preferences",
            [self applicationSupportDirectory],
            [virtualMachine uniqueName]
    ];

    NSFileManager * fileManager= [NSFileManager defaultManager];
    NSError * error;

    if([fileManager fileExistsAtPath:preferencesFilePath isDirectory:nil])    
        if (![fileManager removeItemAtPath:preferencesFilePath error:&error])
            DDLogError(@"Whoops, couldn't delete: %@", preferencesFilePath);
    
    [preferencesFilePath release];
    [managedObjectContext deleteObject:virtualMachine];
    
    if ([windowsForVirtualMachines objectForKey:[virtualMachine uniqueName]] != nil) {
        [[[windowsForVirtualMachines objectForKey:[virtualMachine uniqueName]] window] close];
        [windowsForVirtualMachines removeObjectForKey:[virtualMachine uniqueName]];
    }
    
    [self endDeleteMachineView:sender];
    [self saveCoreData];

}

/*!
 * @method      run:
 * @abstract    Saves preferences and lauches emulator.
 * @discussion  There is a replica in the virtual machine controller that must be
 *              taken care of.
 * This will crash if the application support dir doesn't exist. Fix it!
 */
- (IBAction)run:(id)sender {
    
    [self saveCoreData];
    
    VirtualMachinesEntityModel * virtualMachine = [[virtualMachinesArrayController selectedObjects]  objectAtIndex:0];

    if (![[virtualMachine emulator] unixPath]){
        [errorSheetLabel setStringValue:@"There is no emulator associated with this virtual machine!\nPlease check your emulator on the assets manager and then use the general tab in your machine's settings.\nIf you need help, refer to the help menu."];
        [self showErrorSheetView:sender];
        return;
    }
    
    NSString * preferencesFilePath = [
        [NSMutableString alloc] initWithFormat:
            @"%@/%@Preferences",
            [self applicationSupportDirectory],
            [virtualMachine uniqueName]
    ];
   
    PreferencesModel * preferences = [[PreferencesModel alloc] autorelease];
    [preferences savePreferencesFile:preferencesFilePath ForVirtualMachine:virtualMachine];   
    DDLogVerbose(@"Prefs file ....: %@", preferencesFilePath);

///-----------------------------------------------------------------------------
/// Emulator launching:
//        [NSThread detachNewThreadSelector:@selector(executeBasiliskII:) toTarget:[EmulatorHandleController class] withObject:preferencesFilePath];
///-----------------------------------------------------------------------------
/// Or...
///-----------------------------------------------------------------------------
    // Use GCD to execute emulator in an async thread:
    dispatch_async(queue, ^{
        
        NSString * emulatorPath = [[virtualMachine emulator] unixPath];
        
        NSLog(@"Emulator path:\n%@", emulatorPath);
        
//        NSString * emulatorPath = [[NSString alloc] initWithString:[[ NSBundle mainBundle ] pathForAuxiliaryExecutable: @"Emulators/Basilisk II" ]];
        
        // Starts emulator:
        
        NSTask * emulatorTask = [[[NSTask alloc] init] autorelease];
        [emulatorTask setLaunchPath:emulatorPath];

        [emulatorTask setArguments:
            [NSArray arrayWithObjects:
                 @"--config"
               , preferencesFilePath
               ,nil
            ]
        ];
        
        [preferencesFilePath release];
        [emulatorTask launch];
        [emulatorTask waitUntilExit];

        DDLogVerbose(@"Emulator finished.");
        
    });
///-----------------------------------------------------------------------------
    
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Open Window Actions

#pragma mark – Windows triggers

- (IBAction)showMainWindow:(id)sender {
    [_window makeKeyAndOrderFront:self];
}

/*!
 * @method      openVirtualMachineWindow:
 * @abstract    Opens the iTunes-like window to control the vm's properties.
 */
- (IBAction)openVirtualMachineWindow:(id)sender {
    
    NSArray * selectedVirtualMachines = [
        [NSArray alloc] initWithArray:[virtualMachinesArrayController selectedObjects]
    ];
    //The user can select only one in the current interface, but anyway...
    
    VirtualMachinesEntityModel * selectedVirtualMachine;
        
    selectedVirtualMachine = [selectedVirtualMachines objectAtIndex:0];
    
    VirtualMachineWindowController * newWindowController = [windowsForVirtualMachines objectForKey:[selectedVirtualMachine uniqueName]];
    
    if (newWindowController == nil) {
        DDLogWarn(@"Missing window for key %@", [selectedVirtualMachine uniqueName]);
        newWindowController = [
            [VirtualMachineWindowController alloc]
                initWithVirtualMachine: selectedVirtualMachine
                inManagedObjectContext: [self managedObjectContext]
        ]; //closing won't release it.
        [windowsForVirtualMachines setObject:newWindowController forKey:[selectedVirtualMachine uniqueName]];
    }

    [newWindowController showWindow:sender];
    [selectedVirtualMachines release];
    
}

/*!
 * @method      showAssetsWindow:
 * @abstract    Displays the Assets Window.
 */
- (IBAction)showAssetsWindow:(id)sender {
    
    //Gets the Managed Object Context:
    NSManagedObjectContext * managedObjectContext = [self managedObjectContext];
    
    if (!assetsWindowController) {
        assetsWindowController = [
            [AssetsWindowController alloc]
                initWithManagedObjectContext: managedObjectContext
        ];
    }
    [assetsWindowController showWindow:self];
    
}

// Preferences:

/*!
 * @method      showPreferencesWindow:
 * @abstract    Displays the Preferences.
 */
- (IBAction)showPreferencesWindow:(id)sender {
    DDLogVerbose(@"Show preferences window: %@", sender);
    
    if (!preferencesWindowController) {
        preferencesWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
    }
    [preferencesWindowController showWindow:self];  
    
}

//- (void)releaseWindowFor:(NSString *)virtualMachineUniqueName {
////    VirtualMachineWindowController * newWindowController = [windowsForVirtualMachines objectForKey:virtualMachineUniqueName];
////    [newWindowController release];
////    [windowsForVirtualMachines removeObjectForKey:virtualMachineUniqueName];
//}


//------------------------------------------------------------------------------
// Utility methods

#pragma mark – Utility

/*!
 * @method      applicationSupportDirectory:
 * @abstract    Returns the application support directory path.
 */
- (NSString *)applicationSupportDirectory {
    NSArray  * paths    = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString * basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Medusa"];
}

/*!
 * @method      saveCoreData:
 * @abstract    Saves the core-data state.
 */
- (void)saveCoreData {
    DDLogVerbose(@"Saving...");
    NSError * error;
    if (![[self managedObjectContext] save:&error]) {
        DDLogError(@"Whoops, couldn't save: %@", [error localizedDescription]);
        DDLogVerbose(@"Check 'App Delegate' class, saveCloneVirtualMachine");
    }
}

//------------------------------------------------------------------------------
// Overwrotten methods.

#pragma mark – Rewrotten

/*!
 * @method      applicationShouldHandleReopen:hasVisibleWindows:
 * @abstract    Defines if the main window should re-open after a click in the
 *              Dock's icon once all windows are closed.
 */
- (BOOL)applicationShouldHandleReopen:(NSApplication *)app hasVisibleWindows:(BOOL)flag {
    if (!flag) {
        [_window makeKeyAndOrderFront:self];
        return NO;
    } else {
        return YES;
    }
}

// Init methods

#pragma mark – Init

/*!
 * @method      init
 * @abstract    Init method.
 */
- (id)init {
    self = [super init];
    if (self) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        windowsForVirtualMachines = [[NSMutableDictionary alloc] init];
    }
    return self;
}

//------------------------------------------------------------------------------
// Standard methods.

#pragma mark – Standard methods

//The comments are not part of Apple's policies, it seems.. *sigh*

/*!
 * @link Check XCode quick help.
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    //Log all preferences:
    //DDLogVerbose(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    //Preferences management:
    BOOL haveSharePath = [[NSUserDefaults standardUserDefaults] boolForKey:@"haveSharePath"];
    
    //Share path:
    if (!haveSharePath) {
        [[NSUserDefaults standardUserDefaults] setValue: NSHomeDirectory()
        forKey:@"StandardSharePath"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"haveSharePath"];
    }
    
    // Checks for application support directory:
    BOOL isDir;
    NSString      * applicationSupportDirectoryPath = [self applicationSupportDirectory];
    NSFileManager * fileManager                     = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:applicationSupportDirectoryPath isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:applicationSupportDirectoryPath withIntermediateDirectories:YES attributes:nil error:NULL])
            DDLogError(@"Error: Create application support dir failed.");
    
    // Checks for emulators:
    
    BOOL haveEmulators = [[NSUserDefaults standardUserDefaults] boolForKey:@"emulatorsUsed"];
    
    if (!haveEmulators) {
        [self showAssetsWindow:self];
        [assetsWindowController displayEmulatorsView:self];
    }

}

/*!
 * @method      applicationFilesDirectory:
 * @abstract    Returns the directory the application uses to store the Core Data
 *              store file.
 * @discussion  This code uses a directory named "Medusa" in the user's Library
 *              directory.
 */
- (NSURL *)applicationFilesDirectory {

    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSURL * libraryURL = [
        [fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject
    ];
    
    return [libraryURL URLByAppendingPathComponent:@"Medusa"];
}

/*!
 * @method      managedObjectModel:
 * @abstract    Creates if necessary and returns the managed object model for
 *              the application.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (__managedObjectModel) return __managedObjectModel;
	
    NSURL *modelURL = [
        [NSBundle mainBundle] URLForResource:@"Medusa" withExtension:@"momd"
    ];
    
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    
    return __managedObjectModel;

}

/**
 * @abstract    Returns the persistent store coordinator for the application.
 *              This implementation creates and return a coordinator, having
 *              added the store for the application to it. (The directory for
 *              the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    
    if (!mom) {
        DDLogError(
              @"%@:%@ No model to generate a store from",
              [self class],
              NSStringFromSelector(_cmd)
        );
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [
        applicationFilesDirectory
        resourceValuesForKeys:[
            NSArray arrayWithObject:NSURLIsDirectoryKey
        ]
        error:&error
    ];
        
    if (!properties) {
        
        BOOL ok = NO;
        
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
        
    } else {
        
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
        
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Medusa.storedata"];
    
    NSPersistentStoreCoordinator *coordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom] autorelease];
    
    NSSet *versionIdentifiers = [[self managedObjectModel] versionIdentifiers];
    DDLogInfo(@"Current Version of .xcdatamodeld file: %@", versionIdentifiers);
    
    /*
     This part handles the persistent store upgrade:
     */
    NSDictionary *options = [
                             NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES],
                             NSMigratePersistentStoresAutomaticallyOption,
                            [NSNumber numberWithBool:YES],
                             NSInferMappingModelAutomaticallyOption,
                             nil
                             ];
    
    /*
     The following code was without 'options'. The value was set to 'nil'.
     */
    if (![coordinator
          addPersistentStoreWithType:NSSQLiteStoreType
                       configuration:nil
                                 URL:url
                             options:options
                               error:&error]) {

        //[[NSApplication sharedApplication] presentError:error];
        
        return nil;
    }
    __persistentStoreCoordinator = [coordinator retain];

    return __persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}

/**
    Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/**
    Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction)saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        DDLogError(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    // Save changes in the application's managed object context before the application terminates.

    if (!__managedObjectContext) {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing]) {
        DDLogError(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError * error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString * question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString * info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString * quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString * cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert  * alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}




+ (void)initialize {
    IconValueTransformer *transformer = [[IconValueTransformer alloc] init];
    [NSValueTransformer setValueTransformer:transformer forName:@"IconValueTransformer"];
    [transformer release];
}

@end
