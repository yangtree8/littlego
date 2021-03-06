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


// Forward declarations
@class MagnifyingViewController;


// -----------------------------------------------------------------------------
/// @brief The MagnifyingGlassOwner protocol allows clients to gain access to
/// the application's magnifying glass functionality, without having to know
/// which controller exactly owns the magnifying glass.
// -----------------------------------------------------------------------------
@protocol MagnifyingGlassOwner

// -----------------------------------------------------------------------------
/// @brief Enables/disables the magnifying glass.
///
/// Enabling the magnifying glass causes the property
/// @e magnifyingViewController to be initialized. From now on, clients may use
/// the MagnifyingControllerView instance to manage the magnified content.
///
/// Disabling the magnifying glass causes the property
/// @e magnifyingViewController to be reset to nil.
// -----------------------------------------------------------------------------
@property(nonatomic, assign) bool magnifyingGlassEnabled;

// -----------------------------------------------------------------------------
/// @brief Provides the MagnifyingViewController object that clients can use to
/// manage the magnified content. An object is available only while
/// @e magnifyingGlassEnabled is set to true.
// -----------------------------------------------------------------------------
@property(nonatomic, retain, readonly) MagnifyingViewController* magnifyingViewController;

@end
