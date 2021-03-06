// -----------------------------------------------------------------------------
// Copyright 2011-2014 Patrick Näf (herzbube@herzbube.ch)
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
/// @brief The StatusViewController class is responsible for displaying status
/// information about the current game situation in a status view that is
/// visible in #UIAreaPlay.
///
/// Most of the time the status view displays textual information, but whenever
/// the GTP engine is taking a long time to calculate something (e.g. computer
/// player makes its move), the status view also displays an activity indicator.
///
/// StatusViewController is a child view controller.
// -----------------------------------------------------------------------------
@interface StatusViewController : UIViewController
{
}

@end
