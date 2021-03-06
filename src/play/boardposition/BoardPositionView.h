// -----------------------------------------------------------------------------
// Copyright 2013-2014 Patrick Näf (herzbube@herzbube.ch)
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


// -----------------------------------------------------------------------------
/// @brief The BoardPositionView class shows information about a board position.
///
/// BoardPositionView is used on the iPhone only.
///
/// All BoardPositionView instances have the same pre-calculated size.
///
/// The view layout is this:
///
/// @verbatim
/// +-----------------------------------------------+
/// | +-UILabel----------+  +-UIImageView---------+ |
/// | | Board position   |  | Stone image         | |
/// | +------------------+  +---------------------+ |
/// | +-UILabel----------+  +-UILabel-------------+ |
/// | | Intersection     |  | Captured stones     | |
/// | +------------------+  +---------------------+ |
/// +-----------------------------------------------+
/// @endverbatim
// -----------------------------------------------------------------------------
@interface BoardPositionView : UIView
{
}

- (id) initWithBoardPosition:(int)boardPosition;

+ (CGSize) boardPositionViewSize;

/// @brief The board position that this view represents. A value of -1 for this
/// property causes the BoardPositionView to display nothing.
@property(nonatomic, assign) int boardPosition;
/// @brief True if this view represents the current board position.
@property(nonatomic, assign) bool currentBoardPosition;

@end
