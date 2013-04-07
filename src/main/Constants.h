// -----------------------------------------------------------------------------
// Copyright 2011-2013 Patrick Näf (herzbube@herzbube.ch)
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


/// @file

// -----------------------------------------------------------------------------
/// @name GUI constants
// -----------------------------------------------------------------------------
//@{
/// @brief The value of this constant should be added to all drawing operations'
/// parameters to prevent anti-aliasing. See README.developer for details.
extern const float gHalfPixel;
/// @brief An alpha value that can be used to make a view (e.g. the label of a
/// table view cell) appear disabled.
///
/// This is based on
/// http://stackoverflow.com/questions/5905608/how-do-i-make-a-uitableviewcell-appear-disabled
extern const float gDisabledViewAlpha;
/// @brief The long press gesture recognizer on the PlayView must use a small
/// delay so as not to interfere with other gestures (notably the gestures used
/// to scroll and zoom, and on the iPad the swipe gesture of the main
/// UISplitViewController).
extern const CFTimeInterval gPlayViewLongPressDelay;
//@}

// -----------------------------------------------------------------------------
/// @name Logging constants
// -----------------------------------------------------------------------------
//@{
/// @brief The log level used by the application. This is always set to the
/// highest possible value. Whether or not logging is actually enabled is a user
/// preference that can be changed at runtime from within the application. If
/// logging is enabled the log output goes to a DDFileLogger with default
/// values.
extern const int ddLogLevel;
//@}

/// @brief Enumerates possible types of GoMove objects.
enum GoMoveType
{
  GoMoveTypePlay,   ///< @brief The player played a stone in this move.
  GoMoveTypePass    ///< @brief The player passed in this move.
};

/// @brief Enumerates colors in Go. The values from this enumeration can be
/// attributed to various things: stones, players, points, moves, etc.
enum GoColor
{
  GoColorNone,   ///< @brief Used, among other things, to say that a GoPoint is empty and has no stone placed on it.
  GoColorBlack,
  GoColorWhite
};

/// @brief Enumerates the possible types of GoGame objects.
enum GoGameType
{
  GoGameTypeUnknown,             ///< @brief Unknown game type.
  GoGameTypeComputerVsHuman,     ///< @brief A computer and a human player play against each other.
  GoGameTypeComputerVsComputer,  ///< @brief Two computer players play against each other.
  GoGameTypeHumanVsHuman         ///< @brief Two human players play against each other.
};

/// @brief Enumerates the possible states of a GoGame.
enum GoGameState
{
  GoGameStateGameHasNotYetStarted,  ///< @brief Denotes a new game that is ready to begin.
  GoGameStateGameHasStarted,        ///< @brief Denotes a game that has started and has at least 1 GoMove.
  GoGameStateGameIsPaused,          ///< @brief Denotes a computer vs. computer game that is paused.
  GoGameStateGameHasEnded           ///< @brief Denotes a game that has ended, no moves can be played anymore.
};

/// @brief Enumerates the possible reasons why a GoGame has reached the state
/// #GoGameStateGameHasEnded.
enum GoGameHasEndedReason
{
  GoGameHasEndedReasonNotYetEnded,   ///< @brief The game has not yet ended.
  GoGameHasEndedReasonTwoPasses,     ///< @brief The game ended due to two consecutive pass moves.
  GoGameHasEndedReasonResigned,      ///< @brief The game ended due to one of the players resigning.
  GoGameHasEndedReasonNoStonesLeft,  ///< @brief The game ended due to both players running out of stones.
  GoGameHasEndedReasonTimeExceeded   ///< @brief The game ended due to one of the players having no time left.
};

/// @brief Enumerates the possible results of a game that has reached the state
/// #GoGameStateGameHasEnded.
enum GoGameResult
{
  GoGameResultNone,         ///< @brief The game has not been decided yet, usually because the game has not yet ended.
  GoGameResultBlackHasWon,  ///< @brief Black has won the game.
  GoGameResultWhiteHasWon,  ///< @brief White has won the game.
  GoGameResultTie           ///< @brief The game is a tie.
};

/// @brief Enumerates the possible directions one can take to get from one
/// GoPoint to another neighbouring GoPoint.
enum GoBoardDirection
{
  GoBoardDirectionLeft,     ///< @brief Used for navigating to the left neighbour of a GoPoint.
  GoBoardDirectionRight,    ///< @brief Used for navigating to the right neighbour of a GoPoint.
  GoBoardDirectionUp,       ///< @brief Used for navigating to the neighbour that is above a GoPoint.
  GoBoardDirectionDown,     ///< @brief Used for navigating to the neighbour that is below a GoPoint.
  GoBoardDirectionNext,     ///< @brief Used for iterating all GoPoints. The first point is always A1, on a 19x19 board the last point is Q19.
  GoBoardDirectionPrevious  ///< @brief Same as #GoBoardDirectionNext, but for iterating backwards.
};

/// @brief How should Play view mark up inconcistent territory during scoring?
enum InconsistentTerritoryMarkupType
{
  InconsistentTerritoryMarkupTypeDotSymbol,  ///< @brief Mark up territory using a dot symbol
  InconsistentTerritoryMarkupTypeFillColor,  ///< @brief Mark up territory by filling it with a color
  InconsistentTerritoryMarkupTypeNeutral     ///< @brief Don't mark up territory
};

/// @brief Enumerates all existing tabs in the GUI.
///
/// Values in this enumeration must match the "tag" property values of each
/// TabBarItem in MainWindow.xib.
enum TabType
{
  TabTypePlay,
  TabTypeSettings,
  TabTypeArchive,
  TabTypeDiagnostics,
  TabTypeManual,
  TabTypeAbout,
  TabTypeSourceCode,
  TabTypeLicenses,
  TabTypeCredits
};

/// @brief Enumerates the supported board sizes.
enum GoBoardSize
{
  GoBoardSize7 = 7,
  GoBoardSize9 = 9,
  GoBoardSize11 = 11,
  GoBoardSize13 = 13,
  GoBoardSize15 = 15,
  GoBoardSize17 = 17,
  GoBoardSize19 = 19,
  GoBoardSizeMin = GoBoardSize7,
  GoBoardSizeMax = GoBoardSize19,
  GoBoardSizeUndefined = 0
};

/// @brief Enumerates the types of alert views used across the application.
///
/// Enumeration values are used as UIView tags so that an alert view delegate
/// that manages several alert views knows how to distinguish between them.
enum AlertViewType
{
  AlertViewTypeGameHasEnded,
  AlertViewTypeNewGame,
  AlertViewTypeSaveGame,
  AlertViewTypeRenameGame,
  AlertViewTypeLoadGameFailed,
  AlertViewTypeSaveGameFailed,
  AlertViewTypeUndoMoveFailed,
  AlertViewTypeAddToCannedCommands,
  AlertViewTypeMemoryWarning,
  AlertViewTypeCannotSendEmail,
  AlertViewTypeDiagnosticsInformationFileGenerated,
  AlertViewTypeDiagnosticsInformationFileNotGenerated,
  AlertViewTypeComputerPlayedIllegalMove,
  AlertViewTypeNewGameAfterComputerPlayedIllegalMove,
  AlertViewTypeActionWillDiscardAllFutureMoves,
  AlertViewTypeHandleDocumentInteractionSucceeded,
  AlertViewTypeHandleDocumentInteractionFailed
};

/// @brief Enumerates the types of buttons used by the various alert views in
/// #AlertViewType.
enum AlertViewButtonType
{
  AlertViewButtonTypeOk = 0,  ///< @brief Used as the single button in a simple alert view
  AlertViewButtonTypeNo = 0,  ///< @brief Used as the "cancel" button in a Yes/No alert view
  AlertViewButtonTypeYes = 1  ///< @brief Used as the first "other" button in a Yes/No alert view
};

/// @brief Enumerates the supported sort criteria on the Archive view.
enum ArchiveSortCriteria
{
  ArchiveSortCriteriaFileName,
  ArchiveSortCriteriaFileDate
};

/// @brief Enumerates different ways how the application can be launched.
enum ApplicationLaunchMode
{
  ApplicationLaunchModeUnknown,
  ApplicationLaunchModeNormal,      ///< @brief The application was launched normally. Production uses
                                    ///  this mode only.
  ApplicationLaunchModeDiagnostics  ///< @brief The application was launched to diagnose a bug report. This
                                    ///  mode is available only in the simulator.
};

/// @brief Enumerates the types of information that the Info view can display.
enum InfoType
{
  ScoreInfoType,
  GameInfoType,
  BoardInfoType
};

// -----------------------------------------------------------------------------
/// @name Go constants
// -----------------------------------------------------------------------------
//@{
extern const enum GoGameType gDefaultGameType;
extern const enum GoBoardSize gDefaultBoardSize;
extern const int gNumberOfBoardSizes;
extern const bool gDefaultComputerPlaysWhite;
extern const int gDefaultHandicap;
extern const double gDefaultKomi;
//@}

// -----------------------------------------------------------------------------
/// @name Filesystem related constants
// -----------------------------------------------------------------------------
//@{
/// @brief Simple file name that violates none of the GTP protocol restrictions
/// for file names. Is used for the "loadsgf" and "savesgf" GTP commands.
extern NSString* sgfTemporaryFileName;
/// @brief Name of the primary NSCoding archive file used for backup/restore
/// when the app goes to/returns from the background. The file is stored in the
/// Library folder.
extern NSString* archiveBackupFileName;
/// @brief Name of the secondary .sgf file used for the same purpose as
/// @e archiveBackupFileName.
extern NSString* sgfBackupFileName;
/// @brief Name of the folder used by the document interaction system to pass
/// files into the app. The folder is located in the Documents folder.
extern NSString* inboxFolderName;
//@}

// -----------------------------------------------------------------------------
/// @name Application notifications
// -----------------------------------------------------------------------------
//@{
/// @brief Is sent after the application delegate has finished setting up the
/// application (includes creating all objects that are important for the
/// application's lifecycle). The application is now "ready for action".
///
/// This notification is sent exactly once.
extern NSString* applicationIsReadyForAction;
//@}

// -----------------------------------------------------------------------------
/// @name GTP notifications
// -----------------------------------------------------------------------------
//@{
/// @brief Is sent just before a command is submitted to the GTP engine. The
/// GtpCommand instance that is submitted is associated with the notification.
///
/// @attention This notification is delivered in a secondary thread.
extern NSString* gtpCommandWillBeSubmittedNotification;
/// @brief Is sent after a response is received from the GTP engine. The
/// GtpResponse instance that was received is associated with the notification.
///
/// @attention This notification is delivered in a secondary thread.
extern NSString* gtpResponseWasReceivedNotification;
/// @brief Is sent to indicate that the GTP engine is no longer idle.
extern NSString* gtpEngineRunningNotification;
/// @brief Is sent to indicate that the GTP engine is idle.
extern NSString* gtpEngineIdleNotification;
//@}

// -----------------------------------------------------------------------------
/// @name GoGame notifications
// -----------------------------------------------------------------------------
//@{
/// @brief Is sent to indicate that a new GoGame object is about to be created
/// and and old GoGame object (if one exists) is about to be deallocated.
///
/// This notification is sent while the old GoGame object and its dependent
/// objects (e.g. GoBoard) are still around and fully functional.
///
/// The old GoGame object is associated with the notification.
///
/// @note If this notification is sent during application startup, i.e. the
/// first game is about to be created, the old GoGame object is nil.
extern NSString* goGameWillCreate;
/// @brief Is sent to indicate that a new GoGame object has been created. This
/// notification is sent after the GoGame object and its dependent objects (e.g.
/// GoBoard) have been fully configured.
///
/// The new GoGame object is associated with the notification.
extern NSString* goGameDidCreate;
/// @brief Is sent to indicate that the GoGame state has changed in some way,
/// i.e. the game has started or ended.
///
/// The GoGame object is associated with the notification.
extern NSString* goGameStateChanged;
//@}

// -----------------------------------------------------------------------------
/// @name Computer player notifications
// -----------------------------------------------------------------------------
//@{
/// @brief Is sent to indicate that the computer player has started to think
/// about its next move.
///
/// The GoGame object is associated with the notification.
extern NSString* computerPlayerThinkingStarts;
/// @brief Is sent to indicate that the computer player has stopped to think
/// about its next move. Occurs only after the move has actually been made, i.e.
/// any GoGame notifications have already been delivered.
///
/// The GoGame object is associated with the notification.
extern NSString* computerPlayerThinkingStops;
//@}

// -----------------------------------------------------------------------------
/// @name Archive related notifications
// -----------------------------------------------------------------------------
//@{
/// @brief Is sent to indicate that something about the content of the archive
/// has changed (e.g. a game has been added, removed, renamed etc.).
extern NSString* archiveContentChanged;
//@}

// -----------------------------------------------------------------------------
/// @name GTP log related notifications
// -----------------------------------------------------------------------------
//@{
/// @brief Is sent to indicate that the something about the content of the
/// GTP log has changed (e.g. a new GtpLogItem has been added, the log has
/// been cleared, the log has rotated).
extern NSString* gtpLogContentChanged;
/// @brief Is sent to indicate that the information stored in a GtpLogItem
/// object has changed.
///
//// The GtpLogItem object is associated with the notification.
extern NSString* gtpLogItemChanged;
//@}

// -----------------------------------------------------------------------------
/// @name Scoring related notifications
// -----------------------------------------------------------------------------
//@{
/// @brief Is sent to indicate that scoring mode has been enabled. Is sent
/// before the first score is calculated.
extern NSString* goScoreScoringModeEnabled;
/// @brief Is sent to indicate that scoring mode has been disabled.
extern NSString* goScoreScoringModeDisabled;
/// @brief Is sent to indicate that the calculation of a new score is about to
/// start.
///
/// The GoScore object is associated with the notification.
extern NSString* goScoreCalculationStarts;
/// @brief Is sent to indicate that a new score has been calculated and is
/// available display.
///
/// The GoScore object is associated with the notification.
extern NSString* goScoreCalculationEnds;
//@}

// -----------------------------------------------------------------------------
/// @name Other notifications
// -----------------------------------------------------------------------------
//@{
/// @brief Is sent when a long-running action starts that is known to trigger
/// many UI updates on the Play tab.
///
/// Each instance of #longRunningActionStarts being sent will eventually be
/// matched by a corresponding #longRunningActionEnds. However, a second
/// #longRunningActionStarts may be sent before #longRunningActionEnds for the
/// first action is sent.
///
/// When an observer receives the first #longRunningActionStarts, it may start
/// to delay view updates (or other similar expensive actions) until it receives
/// a corresponding number of #longRunningActionEnds.
///
/// The typical example for when this notification is sent is when a game is
/// loaded from the archive. Views on the Play tab can protect themselves from
/// an update for each move in the archived game being replayed.
///
/// @attention This notification is guaranteed to be delivered in the main
/// thread.
extern NSString* longRunningActionStarts;
/// @brief Is sent when a long-running action ends that is known to trigger
/// many UI updates on the Play tab.
///
/// See #longRunningActionStarts for details.
///
/// @attention This notification is guaranteed to be delivered in the main
/// thread.
extern NSString* longRunningActionEnds;
/// @brief Is sent (B-A) times while the current board position in
/// GoBoardPosition changes from A to B. Observers can use this notification to
/// power a progress meter.
extern NSString* boardPositionChangeProgress;
//@}

// -----------------------------------------------------------------------------
/// @name Play view settings default values
// -----------------------------------------------------------------------------
//@{
extern const float maximumZoomScaleDefault;
extern const float maximumZoomScaleMaximum;
extern const float stoneDistanceFromFingertipDefault;
extern const float stoneDistanceFromFingertipMaximum;
extern const float moveNumbersPercentageDefault;
//@}

// -----------------------------------------------------------------------------
/// @name Board position settings default values
// -----------------------------------------------------------------------------
//@{
extern const bool discardFutureMovesAlertDefault;
//@}

// -----------------------------------------------------------------------------
/// @name GTP engine profile constants
///
/// @brief See GtpEngineProfile for attribute documentation.
// -----------------------------------------------------------------------------
//@{
extern const int minimumPlayingStrength;
extern const int maximumPlayingStrength;
extern const int customPlayingStrength;
extern const int defaultPlayingStrength;
extern const int fuegoMaxMemoryMinimum;
extern const int fuegoMaxMemoryMaximum;
extern const int fuegoMaxMemoryDefault;
extern const int fuegoThreadCountMinimum;
extern const int fuegoThreadCountMaximum;
extern const int fuegoThreadCountDefault;
extern const bool fuegoPonderingDefault;
extern const unsigned int fuegoMaxPonderTimeMinimum;
extern const unsigned int fuegoMaxPonderTimeMaximum;
extern const unsigned int fuegoMaxPonderTimeDefault;
extern const bool fuegoReuseSubtreeDefault;
extern const unsigned int fuegoMaxThinkingTimeMinimum;
extern const unsigned int fuegoMaxThinkingTimeMaximum;
extern const unsigned int fuegoMaxThinkingTimeDefault;
extern const unsigned long long fuegoMaxGamesMinimum;
extern const unsigned long long fuegoMaxGamesMaximum;
extern const unsigned long long fuegoMaxGamesDefault;
extern const unsigned long long fuegoMaxGamesPlayingStrength1;
extern const unsigned long long fuegoMaxGamesPlayingStrength2;
extern const unsigned long long fuegoMaxGamesPlayingStrength3;
/// @brief The hardcoded UUID of the default GTP engine profile. This profile
/// is the fallback profile if no other profile is available or appropriate.
/// The user cannot delete this profile.
extern NSString* defaultGtpEngineProfileUUID;
//@}

// -----------------------------------------------------------------------------
/// @name Archive view constants
// -----------------------------------------------------------------------------
//@{
extern NSString* sgfMimeType;
extern NSString* sgfUTI;
//@}

// -----------------------------------------------------------------------------
/// @name Diagnostics view settings default values
// -----------------------------------------------------------------------------
//@{
extern const int gtpLogSizeMinimum;
extern const int gtpLogSizeMaximum;
//@}

// -----------------------------------------------------------------------------
/// @name Bug report constants
// -----------------------------------------------------------------------------
//@{
extern const int bugReportFormatVersion;
/// @brief Name of the diagnostics information file that is attached to the
/// bug report email.
///
/// The file name should relate to the project name because the file is user
/// visible, either as an email attachment or when the user transfers it via
/// iTunes file sharing.
extern NSString* bugReportDiagnosticsInformationFileName;
/// @brief Mime-type used for attaching the diagnostics information file to the
/// bug report email.
extern NSString* bugReportDiagnosticsInformationFileMimeType;
/// @brief Name of the bug report information file that stores the bug report
/// format number, the iOS version and the device type.
extern NSString* bugReportInfoFileName;
/// @brief Name of the bug report file that stores an archive of in-memory
/// objects.
extern NSString* bugReportInMemoryObjectsArchiveFileName;
/// @brief Name of the bug report file that stores user defaults.
extern NSString* bugReportUserDefaultsFileName;
/// @brief Name of the bug report file that stores the current game in .sgf
/// format.
extern NSString* bugReportCurrentGameFileName;
/// @brief Name of the bug report file that stores a screenshot of the views
/// visible on the Play tab.
extern NSString* bugReportScreenshotFileName;
/// @brief Name of the bug report file that stores a depiction of the board as
/// it is seen by the GTP engine.
extern NSString* bugReportBoardAsSeenByGtpEngineFileName;
/// @brief Name of the .zip archive file that is used to collect the application
/// log files.
extern NSString* bugReportLogsArchiveFileName;
/// @brief Email address of the bug report email recipient.
extern NSString* bugReportEmailRecipient;
/// @brief Subject for the bug report email.
extern NSString* bugReportEmailSubject;
//@}

// -----------------------------------------------------------------------------
/// @name Crash reporting constants
// -----------------------------------------------------------------------------
//@{
extern NSString* crashReportSubmissionURL;
//@}

// -----------------------------------------------------------------------------
/// @name Resource file names
// -----------------------------------------------------------------------------
//@{
extern NSString* openingBookResource;
extern NSString* aboutDocumentResource;
extern NSString* sourceCodeDocumentResource;
extern NSString* apacheLicenseDocumentResource;
extern NSString* GPLDocumentResource;
extern NSString* LGPLDocumentResource;
extern NSString* boostLicenseDocumentResource;
extern NSString* MBProgressHUDLicenseDocumentResource;
extern NSString* lumberjackLicenseDocumentResource;
extern NSString* zipkitLicenseDocumentResource;
extern NSString* quincykitLicenseDocumentResource;
extern NSString* plcrashreporterLicenseDocumentResource;
extern NSString* protobufcLicenseDocumentResource;
extern NSString* readmeDocumentResource;
extern NSString* manualDocumentResource;
extern NSString* creditsDocumentResource;
extern NSString* registrationDomainDefaultsResource;
extern NSString* playStoneSoundFileResource;
extern NSString* computerPlayButtonIconResource;
extern NSString* passButtonIconResource;
extern NSString* pauseButtonIconResource;
extern NSString* continueButtonIconResource;
extern NSString* gameInfoButtonIconResource;
extern NSString* interruptButtonIconResource;
extern NSString* playButtonIconResource;
extern NSString* fastForwardButtonIconResource;
extern NSString* forwardToEndButtonIconResource;
extern NSString* backButtonIconResource;
extern NSString* rewindButtonIconResource;
extern NSString* rewindToStartButtonIconResource;
extern NSString* humanIconResource;
extern NSString* computerIconResource;
extern NSString* stoneBlackImageResource;
extern NSString* stoneWhiteImageResource;
extern NSString* stoneCrosshairImageResource;
extern NSString* computerVsComputerImageResource;
extern NSString* humanVsComputerImageResource;
extern NSString* humanVsHumanImageResource;
extern NSString* woodenBackgroundImageResource;
extern NSString* bugReportMessageTemplateResource;
//@}

// -----------------------------------------------------------------------------
/// @name Constants (mostly keys) for user defaults
// -----------------------------------------------------------------------------
//@{
// Device-specific suffixes
extern NSString* iPhoneDeviceSuffix;
extern NSString* iPadDeviceSuffix;
// User Defaults versioning
extern NSString* userDefaultsVersionRegistrationDomainKey;
extern NSString* userDefaultsVersionApplicationDomainKey;
// Play view settings
extern NSString* playViewKey;
extern NSString* markLastMoveKey;
extern NSString* displayCoordinatesKey;
extern NSString* moveNumbersPercentageKey;
extern NSString* playSoundKey;
extern NSString* vibrateKey;
extern NSString* backgroundColorKey;
extern NSString* boardColorKey;
extern NSString* lineColorKey;
extern NSString* boundingLineWidthKey;
extern NSString* normalLineWidthKey;
extern NSString* starPointColorKey;
extern NSString* starPointRadiusKey;
extern NSString* stoneRadiusPercentageKey;
extern NSString* crossHairColorKey;
extern NSString* maximumZoomScaleKey;
extern NSString* stoneDistanceFromFingertipKey;
extern NSString* infoTypeLastSelectedKey;
// New game settings
extern NSString* newGameKey;
extern NSString* gameTypeKey;
extern NSString* gameTypeLastSelectedKey;
extern NSString* humanPlayerKey;
extern NSString* computerPlayerKey;
extern NSString* computerPlaysWhiteKey;
extern NSString* humanBlackPlayerKey;
extern NSString* humanWhitePlayerKey;
extern NSString* computerPlayerSelfPlayKey;
extern NSString* boardSizeKey;
extern NSString* handicapKey;
extern NSString* komiKey;
// Players
extern NSString* playerListKey;
extern NSString* playerUUIDKey;
extern NSString* playerNameKey;
extern NSString* isHumanKey;
extern NSString* gtpEngineProfileReferenceKey;
extern NSString* statisticsKey;
extern NSString* gamesPlayedKey;
extern NSString* gamesWonKey;
extern NSString* gamesLostKey;
extern NSString* gamesTiedKey;
extern NSString* starPointsKey;
// GTP engine profiles
extern NSString* gtpEngineProfileListKey;
extern NSString* gtpEngineProfileUUIDKey;
extern NSString* gtpEngineProfileNameKey;
extern NSString* gtpEngineProfileDescriptionKey;
extern NSString* fuegoMaxMemoryKey;
extern NSString* fuegoThreadCountKey;
extern NSString* fuegoPonderingKey;
extern NSString* fuegoMaxPonderTimeKey;
extern NSString* fuegoReuseSubtreeKey;
extern NSString* fuegoMaxThinkingTimeKey;
extern NSString* fuegoMaxGamesKey;
// Archive view settings
extern NSString* archiveViewKey;
extern NSString* sortCriteriaKey;
extern NSString* sortAscendingKey;
// GTP Log view settings
extern NSString* gtpLogViewKey;
extern NSString* gtpLogSizeKey;
extern NSString* gtpLogViewFrontSideIsVisibleKey;
// GTP canned commands settings
extern NSString* gtpCannedCommandsKey;
// Scoring settings
extern NSString* scoringKey;
extern NSString* scoreWhenGameEndsKey;
extern NSString* askGtpEngineForDeadStonesKey;
extern NSString* markDeadStonesIntelligentlyKey;
extern NSString* alphaTerritoryColorBlackKey;
extern NSString* alphaTerritoryColorWhiteKey;
extern NSString* alphaTerritoryColorInconsistencyFoundKey;
extern NSString* deadStoneSymbolColorKey;
extern NSString* deadStoneSymbolPercentageKey;
extern NSString* inconsistentTerritoryMarkupTypeKey;
extern NSString* inconsistentTerritoryDotSymbolColorKey;
extern NSString* inconsistentTerritoryDotSymbolPercentageKey;
extern NSString* inconsistentTerritoryFillColorKey;
extern NSString* inconsistentTerritoryFillColorAlphaKey;
// Crash reporting settings
extern NSString* collectCrashDataKey;
extern NSString* automaticReportCrashDataKey;
extern NSString* allowContactCrashDataKey;
extern NSString* contactEmailCrashDataKey;
// Board position settings
extern NSString* boardPositionKey;
extern NSString* discardFutureMovesAlertKey;
// Logging settings
extern NSString* loggingEnabledKey;
//@}

// -----------------------------------------------------------------------------
/// @name Constants for NSCoding
// -----------------------------------------------------------------------------
//@{
// General constants
extern const int nscodingVersion;
extern NSString* nscodingVersionKey;
// Top-level object keys
extern NSString* nsCodingGoGameKey;
extern NSString* nsCodingGoScoreKey;
// GoGame keys
extern NSString* goGameTypeKey;
extern NSString* goGameBoardKey;
extern NSString* goGameHandicapPointsKey;
extern NSString* goGameKomiKey;
extern NSString* goGamePlayerBlackKey;
extern NSString* goGamePlayerWhiteKey;
extern NSString* goGameMoveModelKey;
extern NSString* goGameStateKey;
extern NSString* goGameReasonForGameHasEndedKey;
extern NSString* goGameIsComputerThinkingKey;
extern NSString* goGameBoardPositionKey;
extern NSString* goGameDocumentKey;
// GoPlayer keys
extern NSString* goPlayerPlayerUUIDKey;
extern NSString* goPlayerIsBlackKey;
// GoMove keys
extern NSString* goMoveTypeKey;
extern NSString* goMovePlayerKey;
extern NSString* goMovePointKey;
extern NSString* goMovePreviousKey;
extern NSString* goMoveNextKey;
extern NSString* goMoveCapturedStonesKey;
extern NSString* goMoveMoveNumberKey;
// GoMoveModel keys
extern NSString* goMoveModelGameKey;
extern NSString* goMoveModelMoveListKey;
extern NSString* goMoveModelNumberOfMovesKey;
// GoBoardPosition keys
extern NSString* goBoardPositionGameKey;
extern NSString* goBoardPositionCurrentBoardPositionKey;
extern NSString* goBoardPositionNumberOfBoardPositionsKey;
// GoBoard keys
extern NSString* goBoardSizeKey;
extern NSString* goBoardVertexDictKey;
extern NSString* goBoardStarPointsKey;
// GoBoardRegion keys
extern NSString* goBoardRegionPointsKey;
extern NSString* goBoardRegionRandomColorKey;
extern NSString* goBoardRegionScoringModeKey;
extern NSString* goBoardRegionTerritoryColorKey;
extern NSString* goBoardRegionTerritoryInconsistencyFoundKey;
extern NSString* goBoardRegionDeadStoneGroupKey;
extern NSString* goBoardRegionCachedSizeKey;
extern NSString* goBoardRegionCachedIsStoneGroupKey;
extern NSString* goBoardRegionCachedColorKey;
extern NSString* goBoardRegionCachedLibertiesKey;
extern NSString* goBoardRegionCachedAdjacentRegionsKey;
// GoPoint keys
extern NSString* goPointVertexKey;
extern NSString* goPointBoardKey;
extern NSString* goPointLeftKey;
extern NSString* goPointRightKey;
extern NSString* goPointAboveKey;
extern NSString* goPointBelowKey;
extern NSString* goPointNeighboursKey;
extern NSString* goPointNextKey;
extern NSString* goPointPreviousKey;
extern NSString* goPointIsStarPointKey;
extern NSString* goPointStoneStateKey;
extern NSString* goPointRegionKey;
extern NSString* goPointIsLeftValidKey;
extern NSString* goPointIsRightValidKey;
extern NSString* goPointIsAboveValidKey;
extern NSString* goPointIsBelowValidKey;
extern NSString* goPointIsNextValidKey;
extern NSString* goPointIsPreviousValidKey;
// GoVertex keys
extern NSString* goVertexStringKey;
extern NSString* goVertexNumericXKey;
extern NSString* goVertexNumericYKey;
extern NSString* goVertexLetterAxisCompoundKey;
extern NSString* goVertexNumberAxisCompoundKey;
// GoScore keys
extern NSString* goScoreTerritoryScoresAvailableKey;
extern NSString* goScoreScoringInProgressKey;
extern NSString* goScoreKomiKey;
extern NSString* goScoreCapturedByBlackKey;
extern NSString* goScoreCapturedByWhiteKey;
extern NSString* goScoreDeadBlackKey;
extern NSString* goScoreDeadWhiteKey;
extern NSString* goScoreTerritoryBlackKey;
extern NSString* goScoreTerritoryWhiteKey;
extern NSString* goScoreTotalScoreBlackKey;
extern NSString* goScoreTotalScoreWhiteKey;
extern NSString* goScoreResultKey;
extern NSString* goScoreNumberOfMovesKey;
extern NSString* goScoreStonesPlayedByBlackKey;
extern NSString* goScoreStonesPlayedByWhiteKey;
extern NSString* goScorePassesPlayedByBlackKey;
extern NSString* goScorePassesPlayedByWhiteKey;
extern NSString* goScoreGameKey;
extern NSString* goScoreBoardIsInitializedKey;
extern NSString* goScoreLastCalculationHadErrorKey;
extern NSString* goScoreAllRegionsKey;
// GtpLogItem keys
extern NSString* gtpLogItemCommandStringKey;
extern NSString* gtpLogItemTimeStampKey;
extern NSString* gtpLogItemHasResponseKey;
extern NSString* gtpLogItemResponseStatusKey;
extern NSString* gtpLogItemParsedResponseStringKey;
extern NSString* gtpLogItemRawResponseStringKey;
// GoGameDocument keys
extern NSString* goGameDocumentDirtyKey;
extern NSString* goGameDocumentDocumentNameKey;
//@}
