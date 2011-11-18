// -----------------------------------------------------------------------------
// Copyright 2011 Patrick Näf (herzbube@herzbube.ch)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// -----------------------------------------------------------------------------


// Project includes
#import "RenameGameCommand.h"
#import "../../ApplicationDelegate.h"
#import "../../archive/ArchiveGame.h"
#import "../../archive/ArchiveViewModel.h"


// -----------------------------------------------------------------------------
/// @brief Class extension with private methods for RenameGameCommand.
// -----------------------------------------------------------------------------
@interface RenameGameCommand()
/// @name Initialization and deallocation
//@{
- (void) dealloc;
//@}
@end


@implementation RenameGameCommand

@synthesize game;
@synthesize theNewFileName;


// -----------------------------------------------------------------------------
/// @brief Initializes a RenameGameCommand object.
///
/// @note This is the designated initializer of RenameGameCommand.
// -----------------------------------------------------------------------------
- (id) initWithGame:(ArchiveGame*)aGame newFileName:(NSString*)aNewFileName
{
  // Call designated initializer of superclass (CommandBase)
  self = [super init];
  if (! self)
    return nil;

  self.game = aGame;
  self.theNewFileName = aNewFileName;

  return self;
}

// -----------------------------------------------------------------------------
/// @brief Deallocates memory allocated by this RenameGameCommand object.
// -----------------------------------------------------------------------------
- (void) dealloc
{
  self.game = nil;
  self.theNewFileName = nil;
  [super dealloc];
}

// -----------------------------------------------------------------------------
/// @brief Executes this command. See the class documentation for details.
// -----------------------------------------------------------------------------
- (bool) doIt
{
  if ([self.game.fileName isEqualToString:self.theNewFileName])
    return true;

  ArchiveViewModel* model = [ApplicationDelegate sharedDelegate].archiveViewModel;
  NSString* oldPath = [model.archiveFolder stringByAppendingPathComponent:game.fileName];
  NSString* newPath = [model.archiveFolder stringByAppendingPathComponent:self.theNewFileName];

  NSFileManager* fileManager = [NSFileManager defaultManager];
  BOOL success = [fileManager moveItemAtPath:oldPath toPath:newPath error:nil];
  if (success)
  {
    // Must update the ArchiveGame before posting the notification. Reason: The
    // notification triggers an update cycle which tries to match ArchiveGame
    // objects to filesystem entries via their file names.
    self.game.fileName = self.theNewFileName;
    [[NSNotificationCenter defaultCenter] postNotificationName:archiveContentChanged object:nil];
  }
  return success;
}

@end