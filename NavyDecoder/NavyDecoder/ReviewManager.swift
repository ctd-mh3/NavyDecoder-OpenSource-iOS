//
// ReviewManager.swift
// NavyDecoder-iOS
//
// This file is part of Navy Decoder-iOS.
//
// Navy Decoder-iOS is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Navy Decoder-iOS is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Navy Decoder-iOS.  If not, see <https://www.gnu.org/licenses/>.
//
// Copyright (c) 2014-2025 Crash Test Dummy Limited, LLC
//

import StoreKit
import UIKit

/// Manages App Store review prompts keyed off meaningful user interactions.
///
/// Requests a review after the user has viewed at least `minimumDetailViews`
/// item detail screens, and at most once per app build version.
@objc class ReviewManager: NSObject {

    private static let detailViewCountKey = "reviewDetailViewCount"
    private static let lastVersionReviewedKey = "reviewLastVersionPrompted"
    private static let minimumDetailViews = 5

    /// Call this each time the item detail screen appears.
    /// Increments an interaction counter and requests a review when appropriate.
    @objc @MainActor static func requestReviewIfAppropriate(in windowScene: UIWindowScene?) {
        let defaults = UserDefaults.standard

        let count = defaults.integer(forKey: detailViewCountKey) + 1
        defaults.set(count, forKey: detailViewCountKey)

        guard
            let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            count >= minimumDetailViews,
            defaults.string(forKey: lastVersionReviewedKey) != currentVersion,
            let scene = windowScene
        else { return }

        AppStore.requestReview(in: scene)
        defaults.set(currentVersion, forKey: lastVersionReviewedKey)
    }
}
