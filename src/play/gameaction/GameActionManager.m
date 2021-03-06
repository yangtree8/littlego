// -----------------------------------------------------------------------------
// Copyright 2015 Patrick Näf (herzbube@herzbube.ch)
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
#import "GameActionManager.h"
#import "../controller/DiscardFutureMovesAlertController.h"
#import "../model/BoardViewModel.h"
#import "../model/ScoringModel.h"
#import "../../go/GoBoardPosition.h"
#import "../../go/GoGame.h"
#import "../../go/GoScore.h"
#import "../../command/gtp/InterruptComputerCommand.h"
#import "../../command/boardposition/ChangeAndDiscardCommand.h"
#import "../../command/boardposition/DiscardAndPlayCommand.h"
#import "../../command/game/PauseGameCommand.h"
#import "../../main/ApplicationDelegate.h"
#import "../../main/WindowRootViewController.h"
#import "../../shared/ApplicationStateManager.h"
#import "../../shared/LongRunningActionCounter.h"
#import "../../shared/LayoutManager.h"


// -----------------------------------------------------------------------------
/// @brief Class extension with private properties for GameActionManager.
// -----------------------------------------------------------------------------
@interface GameActionManager()
@property(nonatomic, retain) NSArray* visibleGameActions;
@property(nonatomic, retain) NSMutableDictionary* enabledStates;
@property(nonatomic, assign) bool visibleStatesNeedUpdate;
@property(nonatomic, assign) bool enabledStatesNeedUpdate;
@property(nonatomic, assign) GameInfoViewController* gameInfoViewController;
@property(nonatomic, retain) GameActionsActionSheetController* gameActionsActionSheetController;
@property(nonatomic, retain) DiscardFutureMovesAlertController* discardFutureMovesAlertController;
@end


@implementation GameActionManager

#pragma mark - Shared handling

// -----------------------------------------------------------------------------
/// @brief Shared instance of GameActionManager.
// -----------------------------------------------------------------------------
static GameActionManager* sharedGameActionManager = nil;

// -----------------------------------------------------------------------------
/// @brief Returns the shared GameActionManager object.
// -----------------------------------------------------------------------------
+ (GameActionManager*) sharedGameActionManager
{
  @synchronized(self)
  {
    if (! sharedGameActionManager)
      sharedGameActionManager = [[GameActionManager alloc] init];
    return sharedGameActionManager;
  }
}

// -----------------------------------------------------------------------------
/// @brief Releases the shared GameActionManager object.
// -----------------------------------------------------------------------------
+ (void) releaseSharedGameActionManager
{
  @synchronized(self)
  {
    if (sharedGameActionManager)
    {
      [sharedGameActionManager release];
      sharedGameActionManager = nil;
    }
  }
}

#pragma mark - Initialization and deallocation

// -----------------------------------------------------------------------------
/// @brief Initializes a GameActionManager object.
///
/// @note This is the designated initializer of GameActionManager.
// -----------------------------------------------------------------------------
- (id) init
{
  // Call designated initializer of superclass (NSObject)
  self = [super init];
  if (! self)
    return nil;
  self.uiDelegate = nil;
  self.commandDelegate = nil;
  self.gameInfoViewControllerPresenter = nil;
  self.visibleGameActions = [NSArray array];
  self.enabledStates = [NSMutableDictionary dictionary];
  for (int gameAction = GameActionFirst; gameAction <= GameActionLast; ++gameAction)
    [self.enabledStates setObject:[NSNumber numberWithBool:NO] forKey:[NSNumber numberWithInt:gameAction]];
  self.visibleStatesNeedUpdate = false;
  self.enabledStatesNeedUpdate = false;
  self.gameInfoViewController = nil;
  self.gameActionsActionSheetController = nil;
  self.discardFutureMovesAlertController = [[[DiscardFutureMovesAlertController alloc] init] autorelease];
  self.commandDelegate = self.discardFutureMovesAlertController;
  [self setupNotificationResponders];
  return self;
}

// -----------------------------------------------------------------------------
/// @brief Deallocates memory allocated by this GameActionManager object.
// -----------------------------------------------------------------------------
- (void) dealloc
{
  [self removeNotificationResponders];
  self.visibleGameActions = nil;
  self.enabledStates = nil;
  self.gameInfoViewController = nil;
  self.gameActionsActionSheetController = nil;
  self.uiDelegate = nil;
  self.commandDelegate = nil;
  self.gameInfoViewControllerPresenter = nil;
  self.discardFutureMovesAlertController = nil;
  [super dealloc];
}

#pragma mark - Setup/remove notification responders

// -----------------------------------------------------------------------------
/// @brief Private helper for the initializer.
// -----------------------------------------------------------------------------
- (void) setupNotificationResponders
{
  NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
  [center addObserver:self selector:@selector(goGameWillCreate:) name:goGameWillCreate object:nil];
  [center addObserver:self selector:@selector(goGameDidCreate:) name:goGameDidCreate object:nil];
  [center addObserver:self selector:@selector(goGameStateChanged:) name:goGameStateChanged object:nil];
  [center addObserver:self selector:@selector(computerPlayerThinkingChanged:) name:computerPlayerThinkingStarts object:nil];
  [center addObserver:self selector:@selector(computerPlayerThinkingChanged:) name:computerPlayerThinkingStops object:nil];
  [center addObserver:self selector:@selector(goScoreScoringEnabled:) name:goScoreScoringEnabled object:nil];
  [center addObserver:self selector:@selector(goScoreScoringDisabled:) name:goScoreScoringDisabled object:nil];
  [center addObserver:self selector:@selector(goScoreCalculationStarts:) name:goScoreCalculationStarts object:nil];
  [center addObserver:self selector:@selector(goScoreCalculationEnds:) name:goScoreCalculationEnds object:nil];
  [center addObserver:self selector:@selector(boardViewWillDisplayCrossHair:) name:boardViewWillDisplayCrossHair object:nil];
  [center addObserver:self selector:@selector(boardViewWillHideCrossHair:) name:boardViewWillHideCrossHair object:nil];
  [center addObserver:self selector:@selector(longRunningActionEnds:) name:longRunningActionEnds object:nil];
  [center addObserver:self selector:@selector(statusBarOrientationWillChange:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];

  // KVO observing
  GoBoardPosition* boardPosition = [GoGame sharedGame].boardPosition;
  [boardPosition addObserver:self forKeyPath:@"currentBoardPosition" options:0 context:NULL];
  [boardPosition addObserver:self forKeyPath:@"numberOfBoardPositions" options:0 context:NULL];
}

// -----------------------------------------------------------------------------
/// @brief Private helper for dealloc.
// -----------------------------------------------------------------------------
- (void) removeNotificationResponders
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  GoBoardPosition* boardPosition = [GoGame sharedGame].boardPosition;
  [boardPosition removeObserver:self forKeyPath:@"currentBoardPosition"];
  [boardPosition removeObserver:self forKeyPath:@"numberOfBoardPositions"];
}

#pragma mark - Game action handlers

// -----------------------------------------------------------------------------
/// @brief Places a stone on behalf of the player whose turn it currently is,
/// at the intersection identified by @a point.
// -----------------------------------------------------------------------------
- (void) playAtIntersection:(GoPoint*)point
{
  if ([self shouldIgnoreUserInteraction])
  {
    DDLogWarn(@"%@: Ignoring GameActionPass", self);
    return;
  }
  DiscardAndPlayCommand* command = [[[DiscardAndPlayCommand alloc] initWithPoint:point] autorelease];
  [self.commandDelegate gameActionManager:self playOrAlertWithCommand:command];
}

// -----------------------------------------------------------------------------
/// @brief Handles execution of game action #GameActionPass.
// -----------------------------------------------------------------------------
- (void) pass:(id)sender
{
  if ([self shouldIgnoreUserInteraction])
  {
    DDLogWarn(@"%@: Ignoring GameActionPass", self);
    return;
  }
  DiscardAndPlayCommand* command = [[[DiscardAndPlayCommand alloc] initPass] autorelease];
  [self.commandDelegate gameActionManager:self playOrAlertWithCommand:command];
}

// -----------------------------------------------------------------------------
/// @brief Handles execution of game action #GameActionDiscardBoardPosition.
// -----------------------------------------------------------------------------
- (void) discardBoardPosition:(id)sender
{
  if ([self shouldIgnoreUserInteraction])
  {
    DDLogWarn(@"%@: Ignoring GameActionDiscardBoardPosition", self);
    return;
  }
  ChangeAndDiscardCommand* command = [[[ChangeAndDiscardCommand alloc] init] autorelease];
  [self.commandDelegate gameActionManager:self discardOrAlertWithCommand:command];
}

// -----------------------------------------------------------------------------
/// @brief Handles execution of game action #GameActionComputerPlay.
// -----------------------------------------------------------------------------
- (void) computerPlay:(id)sender
{
  if ([self shouldIgnoreUserInteraction])
  {
    DDLogWarn(@"%@: Ignoring GameActionComputerPlay", self);
    return;
  }
  DiscardAndPlayCommand* command = [[[DiscardAndPlayCommand alloc] initComputerPlay] autorelease];
  [self.commandDelegate gameActionManager:self playOrAlertWithCommand:command];
}

// -----------------------------------------------------------------------------
/// @brief Handles execution of game action #GameActionPause.
// -----------------------------------------------------------------------------
- (void) pause:(id)sender
{
  [[[[PauseGameCommand alloc] init] autorelease] submit];
}

// -----------------------------------------------------------------------------
/// @brief Handles execution of game action #GameActionContinue.
// -----------------------------------------------------------------------------
- (void) continue:(id)sender
{
  DiscardAndPlayCommand* command = [[[DiscardAndPlayCommand alloc] initContinue] autorelease];
  [self.commandDelegate gameActionManager:self playOrAlertWithCommand:command];
}

// -----------------------------------------------------------------------------
/// @brief Handles execution of game action #GameActionInterrupt.
// -----------------------------------------------------------------------------
- (void) interrupt:(id)sender
{
  [[[[InterruptComputerCommand alloc] init] autorelease] submit];
}

// -----------------------------------------------------------------------------
/// @brief Handles execution of game action #GameActionScoringStart.
// -----------------------------------------------------------------------------
- (void) scoringStart:(id)sender
{
  GoScore* score = [GoGame sharedGame].score;
  score.scoringEnabled = true;
  [score calculateWaitUntilDone:false];
}

// -----------------------------------------------------------------------------
/// @brief Handles execution of game action #GameActionScoringDone.
// -----------------------------------------------------------------------------
- (void) scoringDone:(id)sender
{
  [GoGame sharedGame].score.scoringEnabled = false;  // triggers notification to which this manager reacts
}

// -----------------------------------------------------------------------------
/// @brief Handles execution of game action #GameActionGameInfo.
// -----------------------------------------------------------------------------
- (void) gameInfo:(id)sender
{
  GoScore* score = [GoGame sharedGame].score;
  if (! score.scoringEnabled)
    [score calculateWaitUntilDone:true];

  self.gameInfoViewController = [[[GameInfoViewController alloc] init] autorelease];
  [self.gameInfoViewControllerPresenter presentGameInfoViewController:self.gameInfoViewController];
  // Even though we can tell the presenter to dismiss the controller, we are not
  // in sole control of dismissal, i.e. there are other events that can cause
  // GameInfoViewController to be dismissed. One known example: The user taps
  // the "Play" tab bar icon (in layouts where a tab bar is used). When
  // GameInfoViewController is dismissed it is also deallocated, so we can get
  // a notification about that from the controller itself.
  self.gameInfoViewController.gameInfoViewControllerCreator = self;
}

// -----------------------------------------------------------------------------
/// @brief Handles execution of game action #GameActionMoreGameActions.
// -----------------------------------------------------------------------------
- (void) moreGameActions:(id)sender
{
  if ([self shouldIgnoreUserInteraction])
  {
    DDLogWarn(@"%@: Ignoring GameActionMoreGameActions", self);
    return;
  }

  UIView* viewForPresentingMoreGameActions = [self.uiDelegate viewForPresentingMoreGameActionsByGameActionManager:self];
  if (viewForPresentingMoreGameActions)
  {
    UIViewController* modalMaster = [ApplicationDelegate sharedDelegate].windowRootViewController;
    self.gameActionsActionSheetController = [[[GameActionsActionSheetController alloc] initWithModalMaster:modalMaster delegate:self] autorelease];
    [self.gameActionsActionSheetController showActionSheetFromRect:viewForPresentingMoreGameActions.bounds
                                                            inView:viewForPresentingMoreGameActions];
  }
}

#pragma mark - GameActionsActionSheetDelegate overrides

// -----------------------------------------------------------------------------
/// @brief GameActionsActionSheetDelegate protocol method.
// -----------------------------------------------------------------------------
- (void) gameActionsActionSheetControllerDidFinish:(GameActionsActionSheetController*)controller
{
  self.gameActionsActionSheetController = nil;
}

#pragma mark - GameInfoViewControllerCreator overrides

// -----------------------------------------------------------------------------
/// @brief GameInfoViewControllerCreator protocol method.
// -----------------------------------------------------------------------------
- (void) gameInfoViewControllerWillDeallocate:(GameInfoViewController*)gameInfoViewController
{
  self.gameInfoViewController = nil;
}

#pragma mark - Notification responders

// -----------------------------------------------------------------------------
/// @brief Responds to the #goGameWillCreate notification.
// -----------------------------------------------------------------------------
- (void) goGameWillCreate:(NSNotification*)notification
{
  // Dismiss the "Game Info" view when a new game is about to be started. This
  // typically occurs when a saved game is loaded from the archive.
  if (self.gameInfoViewController)
    [self.gameInfoViewControllerPresenter dismissGameInfoViewController:self.gameInfoViewController];

  GoGame* oldGame = [notification object];
  GoBoardPosition* boardPosition = oldGame.boardPosition;
  [boardPosition removeObserver:self forKeyPath:@"currentBoardPosition"];
  [boardPosition removeObserver:self forKeyPath:@"numberOfBoardPositions"];
}

// -----------------------------------------------------------------------------
/// @brief Responds to the #goGameDidCreate notification.
// -----------------------------------------------------------------------------
- (void) goGameDidCreate:(NSNotification*)notification
{
  GoGame* newGame = [notification object];
  GoBoardPosition* boardPosition = newGame.boardPosition;
  [boardPosition addObserver:self forKeyPath:@"currentBoardPosition" options:0 context:NULL];
  [boardPosition addObserver:self forKeyPath:@"numberOfBoardPositions" options:0 context:NULL];
  self.visibleStatesNeedUpdate = true;
  self.enabledStatesNeedUpdate = true;
  [self delayedUpdate];
}

// -----------------------------------------------------------------------------
/// @brief Responds to the #goGameStateChanged notification.
// -----------------------------------------------------------------------------
- (void) goGameStateChanged:(NSNotification*)notification
{
  self.visibleStatesNeedUpdate = true;
  self.enabledStatesNeedUpdate = true;
  [self delayedUpdate];
  GoGame* game = [GoGame sharedGame];
  if (GoGameStateGameHasEnded == game.state)
  {
    if ([ApplicationDelegate sharedDelegate].scoringModel.scoreWhenGameEnds)
    {
      // Only trigger scoring if it makes sense to do so. It specifically does
      // not make sense if a player resigned - that player has lost the game
      // by his own explicit action, so we don't need to calculate a score.
      if (GoGameHasEndedReasonTwoPasses == game.reasonForGameHasEnded)
      {
        game.score.scoringEnabled = true;
        [game.score calculateWaitUntilDone:false];
      }
    }
  }
}

// -----------------------------------------------------------------------------
/// @brief Responds to the #computerPlayerThinkingStarts and
/// #computerPlayerThinkingStops notifications.
// -----------------------------------------------------------------------------
- (void) computerPlayerThinkingChanged:(NSNotification*)notification
{
  self.visibleStatesNeedUpdate = true;
  self.enabledStatesNeedUpdate = true;
  [self delayedUpdate];
}

// -----------------------------------------------------------------------------
/// @brief Responds to the #goScoreScoringEnabled notification.
// -----------------------------------------------------------------------------
- (void) goScoreScoringEnabled:(NSNotification*)notification
{
  self.visibleStatesNeedUpdate = true;
  self.enabledStatesNeedUpdate = true;
  [self delayedUpdate];
}

// -----------------------------------------------------------------------------
/// @brief Responds to the #goScoreScoringDisabled notification.
// -----------------------------------------------------------------------------
- (void) goScoreScoringDisabled:(NSNotification*)notification
{
  [[ApplicationStateManager sharedManager] applicationStateDidChange];
  self.visibleStatesNeedUpdate = true;
  self.enabledStatesNeedUpdate = true;
  [self delayedUpdate];
}

// -----------------------------------------------------------------------------
/// @brief Responds to the #goScoreCalculationStarts notification.
// -----------------------------------------------------------------------------
- (void) goScoreCalculationStarts:(NSNotification*)notification
{
  self.enabledStatesNeedUpdate = true;
  [self delayedUpdate];
}

// -----------------------------------------------------------------------------
/// @brief Responds to the #goScoreCalculationEnds notification.
// -----------------------------------------------------------------------------
- (void) goScoreCalculationEnds:(NSNotification*)notification
{
  [[ApplicationStateManager sharedManager] applicationStateDidChange];
  self.enabledStatesNeedUpdate = true;
  [self delayedUpdate];
}

// -----------------------------------------------------------------------------
/// @brief Responds to the #boardViewWillDisplayCrossHair notifications.
// -----------------------------------------------------------------------------
- (void) boardViewWillDisplayCrossHair:(NSNotification*)notification
{
  self.enabledStatesNeedUpdate = true;
  [self delayedUpdate];
}

// -----------------------------------------------------------------------------
/// @brief Responds to the #boardViewWillHideCrossHair notifications.
// -----------------------------------------------------------------------------
- (void) boardViewWillHideCrossHair:(NSNotification*)notification
{
  self.enabledStatesNeedUpdate = true;
  [self delayedUpdate];
}

// -----------------------------------------------------------------------------
/// @brief Responds to the #longRunningActionEnds notification.
// -----------------------------------------------------------------------------
- (void) longRunningActionEnds:(NSNotification*)notification
{
  [self delayedUpdate];
}

// -----------------------------------------------------------------------------
/// @brief Responds to the
/// #UIApplicationWillChangeStatusBarOrientationNotification notification.
// -----------------------------------------------------------------------------
- (void) statusBarOrientationWillChange:(NSNotification*)notification
{
  if ([LayoutManager sharedManager].uiType != UITypePhonePortraitOnly)
  {
    if (self.gameActionsActionSheetController)
    {
      // Dismiss the popover that displays the action sheet because the popover
      // will be wrongly positioned after the interface has rotated.
      [self.gameActionsActionSheetController cancelActionSheet];
    }
  }
}

#pragma mark - KVO responder

// -----------------------------------------------------------------------------
/// @brief Responds to KVO notifications.
// -----------------------------------------------------------------------------
- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
  if (object == [GoGame sharedGame].boardPosition)
  {
    if ([keyPath isEqualToString:@"currentBoardPosition"])
    {
      // It's annoying to have buttons appear and disappear all the time, so
      // we try to minimize this by keeping the same buttons in the navigation
      // bar while the user is browsing board positions.
      self.enabledStatesNeedUpdate = true;
    }
    else if ([keyPath isEqualToString:@"numberOfBoardPositions"])
    {
      self.visibleStatesNeedUpdate = true;
    }
    [self delayedUpdate];
  }
}

#pragma mark - Delayed updating

// -----------------------------------------------------------------------------
/// @brief Internal helper that correctly handles delayed updates. See class
/// documentation for details.
// -----------------------------------------------------------------------------
- (void) delayedUpdate
{
  if ([LongRunningActionCounter sharedCounter].counter > 0)
    return;
  [self updateVisibleStates];
  [self updateEnabledStates];
}

#pragma mark - Game action visibility updating

// -----------------------------------------------------------------------------
/// @brief Updates the visible states of game actions to match the current
/// application state.
// -----------------------------------------------------------------------------
- (void) updateVisibleStates
{
  if (! self.visibleStatesNeedUpdate)
    return;
  self.visibleStatesNeedUpdate = false;

  NSDictionary* visibleStates = [self visibleStatesOfGameActions];

  // During a long-running operation there may have been several visibility
  // state changes. Only the final visibility state counts, though, because
  // intermediate changes were delayed. The final visibility state may be the
  // same as the original visibility state, and that's what we check here.
  // In order for the equality check to be reliable, we need the arrays to have
  // the same sort order
  NSArray* visibleGameActions = [[visibleStates allKeys] sortedArrayUsingSelector:@selector(compare:)];
  if ([self.visibleGameActions isEqualToArray:visibleGameActions])
    return;

  self.visibleGameActions = visibleGameActions;
  if (self.uiDelegate)
  {
    [self.uiDelegate gameActionManager:self
                   updateVisibleStates:visibleStates];
  }
}

// -----------------------------------------------------------------------------
/// @brief Private helper for updateVisibleStates().
// -----------------------------------------------------------------------------
- (void) addGameAction:(enum GameAction)gameAction toVisibleStatesDictionary:(NSMutableDictionary*)visibleStates
{
  NSNumber* gameActionAsNumber = [NSNumber numberWithInt:gameAction];
  NSNumber* enabledAsNumber = self.enabledStates[gameActionAsNumber];
  visibleStates[gameActionAsNumber] = enabledAsNumber;
}

// -----------------------------------------------------------------------------
/// @brief Returns an NSDictionary that contains the game actions that are
/// currently visible, along with their enabled state.
///
/// The keys of the dictionary are NSNumber objects whose intValue returns a
/// value from the GameAction enumeration. They values of the dictionary are
/// NSNumber objects whose boolValue returns the enabled state of the game
/// action.
///
/// @see GameActionManagerUIDelegate gameActionManager:updateVisibleStates().
// -----------------------------------------------------------------------------
- (NSDictionary*) visibleStatesOfGameActions
{
  NSMutableDictionary* visibleStates = [NSMutableDictionary dictionary];
  GoGame* game = [GoGame sharedGame];
  GoBoardPosition* boardPosition = game.boardPosition;
  if (game.score.scoringEnabled)
  {
    [self addGameAction:GameActionScoringDone toVisibleStatesDictionary:visibleStates];
    [self addGameAction:GameActionDiscardBoardPosition toVisibleStatesDictionary:visibleStates];
  }
  else
  {
    switch (game.type)
    {
      case GoGameTypeComputerVsComputer:
      {
        if (GoGameStateGameIsPaused == game.state)
        {
          if (GoGameComputerIsThinkingReasonPlayerInfluence != game.reasonForComputerIsThinking)
            [self addGameAction:GameActionContinue toVisibleStatesDictionary:visibleStates];
        }
        else

        {
          if (GoGameStateGameHasEnded == game.state)
            [self addGameAction:GameActionScoringStart toVisibleStatesDictionary:visibleStates];
          else
            [self addGameAction:GameActionPause toVisibleStatesDictionary:visibleStates];
        }
        if (game.isComputerThinking)
        {
          [self addGameAction:GameActionInterrupt toVisibleStatesDictionary:visibleStates];
        }
        else
        {
          if (boardPosition.numberOfBoardPositions > 1)
            [self addGameAction:GameActionDiscardBoardPosition toVisibleStatesDictionary:visibleStates];
        }
        break;
      }
      default:
      {
        if (game.isComputerThinking)
        {
          [self addGameAction:GameActionInterrupt toVisibleStatesDictionary:visibleStates];
        }
        else
        {
          if (GoGameStateGameHasEnded == game.state)
          {
            [self addGameAction:GameActionScoringStart toVisibleStatesDictionary:visibleStates];
          }
          else
          {
            [self addGameAction:GameActionComputerPlay toVisibleStatesDictionary:visibleStates];
            [self addGameAction:GameActionPass toVisibleStatesDictionary:visibleStates];
          }
          if (boardPosition.numberOfBoardPositions > 1)
            [self addGameAction:GameActionDiscardBoardPosition toVisibleStatesDictionary:visibleStates];
        }
        break;
      }
    }
  }
  return visibleStates;
}

#pragma mark - Game action enabled state updating

// -----------------------------------------------------------------------------
/// @brief Updates the enabled states of all game actions (regardless of their
/// current visible state).
// -----------------------------------------------------------------------------
- (void) updateEnabledStates
{
  if (! self.enabledStatesNeedUpdate)
    return;
  self.enabledStatesNeedUpdate = false;

  [self updatePassEnabledState];
  [self updateDiscardBoardPositionEnabledState];
  [self updateComputerPlayEnabledState];
  [self updatePauseEnabledState];
  [self updateContinueEnabledState];
  [self updateInterruptEnabledState];
  [self updateScoringEnabledState];
  [self updateScoringDoneEnabledState];
  [self updateGameInfoEnabledState];
  [self updateMoreGameActionsEnabledState];
}

// -----------------------------------------------------------------------------
/// @brief Updates the enabled state of game action #GameActionPass.
// -----------------------------------------------------------------------------
- (void) updatePassEnabledState
{
  BOOL enabled = NO;
  GoGame* game = [GoGame sharedGame];
  if (! game.score.scoringEnabled &&
      ! [ApplicationDelegate sharedDelegate].boardViewModel.boardViewDisplaysCrossHair)
  {
    switch (game.type)
    {
      case GoGameTypeComputerVsComputer:
        break;
      default:
      {
        if (game.isComputerThinking)
          break;
        switch (game.state)
        {
          case GoGameStateGameHasStarted:
          {
            GoBoardPosition* boardPosition = game.boardPosition;
            if (boardPosition.isComputerPlayersTurn)
              enabled = NO;
            else
              enabled = YES;
            break;
          }
          default:
            break;
        }
        break;
      }
    }
  }
  [self updateEnabledState:enabled forGameAction:GameActionPass];
}


// -----------------------------------------------------------------------------
/// @brief Updates the enabled state of game action
/// #GameActionDiscardBoardPosition.
// -----------------------------------------------------------------------------
- (void) updateDiscardBoardPositionEnabledState
{
  BOOL enabled = NO;
  GoGame* game = [GoGame sharedGame];
  if ([ApplicationDelegate sharedDelegate].boardViewModel.boardViewDisplaysCrossHair)
  {
    // always disabled
  }
  else if (game.score.scoringEnabled)
  {
    if (! game.score.scoringInProgress)
      enabled = YES;
  }
  else
  {
    if (! game.isComputerThinking)
      enabled = YES;
  }
  [self updateEnabledState:enabled forGameAction:GameActionDiscardBoardPosition];
}

// -----------------------------------------------------------------------------
/// @brief Updates the enabled state of game action #GameActionComputerPlay.
// -----------------------------------------------------------------------------
- (void) updateComputerPlayEnabledState
{
  BOOL enabled = NO;
  GoGame* game = [GoGame sharedGame];
  if (! game.score.scoringEnabled &&
      ! [ApplicationDelegate sharedDelegate].boardViewModel.boardViewDisplaysCrossHair)
  {
    switch (game.type)
    {
      case GoGameTypeComputerVsComputer:
        break;
      default:
      {
        if (game.isComputerThinking)
          break;
        switch (game.state)
        {
          case GoGameStateGameHasStarted:
          {
            enabled = YES;
            break;
          }
          default:
            break;
        }
        break;
      }
    }
  }
  [self updateEnabledState:enabled forGameAction:GameActionComputerPlay];
}

// -----------------------------------------------------------------------------
/// @brief Updates the enabled state of game action #GameActionPause.
// -----------------------------------------------------------------------------
- (void) updatePauseEnabledState
{
  BOOL enabled = NO;
  GoGame* game = [GoGame sharedGame];
  if (! game.score.scoringEnabled &&
      ! [ApplicationDelegate sharedDelegate].boardViewModel.boardViewDisplaysCrossHair)
  {
    switch (game.type)
    {
      case GoGameTypeComputerVsComputer:
      {
        switch (game.state)
        {
          case GoGameStateGameHasStarted:
            enabled = YES;
            break;
          default:
            break;
        }
        break;
      }
      default:
        break;
    }
  }
  [self updateEnabledState:enabled forGameAction:GameActionPause];
}

// -----------------------------------------------------------------------------
/// @brief Updates the enabled state of game action #GameActionContinue.
// -----------------------------------------------------------------------------
- (void) updateContinueEnabledState
{
  BOOL enabled = NO;
  GoGame* game = [GoGame sharedGame];
  if (! game.score.scoringEnabled &&
      ! [ApplicationDelegate sharedDelegate].boardViewModel.boardViewDisplaysCrossHair)
  {
    switch (game.type)
    {
      case GoGameTypeComputerVsComputer:
      {
        switch (game.state)
        {
          case GoGameStateGameIsPaused:
            enabled = YES;
            break;
          default:
            break;
        }
        break;
      }
      default:
        break;
    }
  }
  [self updateEnabledState:enabled forGameAction:GameActionContinue];
}

// -----------------------------------------------------------------------------
/// @brief Updates the enabled state of game action #GameActionInterrupt.
// -----------------------------------------------------------------------------
- (void) updateInterruptEnabledState
{
  BOOL enabled = NO;
  GoGame* game = [GoGame sharedGame];
  if ([ApplicationDelegate sharedDelegate].boardViewModel.boardViewDisplaysCrossHair)
  {
    // always disabled
  }
  else if (game.score.scoringEnabled)
  {
    if (game.score.scoringInProgress)
      enabled = YES;
  }
  else
  {
    if (game.isComputerThinking)
      enabled = YES;
  }
  [self updateEnabledState:enabled forGameAction:GameActionInterrupt];
}

// -----------------------------------------------------------------------------
/// @brief Updates the enabled state of game action #GameActionScoringStart.
// -----------------------------------------------------------------------------
- (void) updateScoringEnabledState
{
  BOOL enabled = NO;
  GoGame* game = [GoGame sharedGame];
  if (game.score.scoringEnabled ||
      game.isComputerThinking ||
      [ApplicationDelegate sharedDelegate].boardViewModel.boardViewDisplaysCrossHair)
  {
    // always disabled
  }
  else
  {
    enabled = YES;
  }
  [self updateEnabledState:enabled forGameAction:GameActionScoringStart];
}

// -----------------------------------------------------------------------------
/// @brief Updates the enabled state of game action #GameActionScoringDone.
// -----------------------------------------------------------------------------
- (void) updateScoringDoneEnabledState
{
  BOOL enabled = NO;
  GoGame* game = [GoGame sharedGame];
  if (game.score.scoringEnabled)
  {
    if (! game.score.scoringInProgress)
      enabled = YES;
  }
  [self updateEnabledState:enabled forGameAction:GameActionScoringDone];
}

// -----------------------------------------------------------------------------
/// @brief Updates the enabled state of game action #GameActionGameInfo.
// -----------------------------------------------------------------------------
- (void) updateGameInfoEnabledState
{
  BOOL enabled = NO;
  GoGame* game = [GoGame sharedGame];
  if ([ApplicationDelegate sharedDelegate].boardViewModel.boardViewDisplaysCrossHair)
  {
    // always disabled
  }
  else if (game.score.scoringEnabled)
  {
    if (! game.score.scoringInProgress)
      enabled = YES;
  }
  else
  {
    // It is important that the Game Info view cannot be displayed if the
    // computer is still thinking. Reason: When the computer has finished
    // thinking, some piece of game state will change. GameInfoViewController,
    // however, is not equipped to update its information dynamically. At best,
    // the Game Info view will display outdated information. At worst, the app
    // will crash - an actual case was issue #226, where the app crashed because
    // - The game ended while the Game Info view was visible
    // - GameInfoViewController reloaded some table view rows in reaction to
    //   user input on the Game Info view
    // - An unrelated table view section suddenly had a different number of
    //   rows (because the game had ended), causing UITableView to throw an
    //   exception
    if (! game.computerThinks)
      enabled = YES;
  }
  [self updateEnabledState:enabled forGameAction:GameActionGameInfo];
}

// -----------------------------------------------------------------------------
/// @brief Updates the enabled state of game action #GameActionMoreGameActions.
// -----------------------------------------------------------------------------
- (void) updateMoreGameActionsEnabledState
{
  BOOL enabled = NO;
  GoGame* game = [GoGame sharedGame];
  if (game.isComputerThinking ||
      [ApplicationDelegate sharedDelegate].boardViewModel.boardViewDisplaysCrossHair)
  {
    // always disabled
  }
  else if (game.score.scoringEnabled)
  {
    if (! game.score.scoringInProgress)
      enabled = YES;
  }
  else
  {
    enabled = YES;
  }
  [self updateEnabledState:enabled forGameAction:GameActionMoreGameActions];
}

// -----------------------------------------------------------------------------
/// @brief Updates the enabled state of the specified game action to
/// @a newState. Notifies the UI delegate only if the new state is different
/// from the current state.
// -----------------------------------------------------------------------------
- (void) updateEnabledState:(BOOL)newState forGameAction:(enum GameAction)gameAction
{
  NSNumber* key = [NSNumber numberWithInt:gameAction];
  BOOL currentState = [[self.enabledStates objectForKey:key] boolValue];
  if (currentState == newState)
    return;
  [self.enabledStates setObject:[NSNumber numberWithBool:newState] forKey:key];
  [self.uiDelegate gameActionManager:self
                              enable:newState
                          gameAction:gameAction];
}

#pragma mark - Private helpers

// -----------------------------------------------------------------------------
/// @brief Returns true if user interaction that triggers a game action should
/// currently be ignored.
// -----------------------------------------------------------------------------
- (bool) shouldIgnoreUserInteraction
{
  return [GoGame sharedGame].isComputerThinking;
}

@end
