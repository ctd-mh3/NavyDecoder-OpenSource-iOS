# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Single Xcode project: open **`NavyDecoder.xcworkspace`** in Xcode. Build and run via Xcode (Cmd+R). Tests are in the `NavyDecoderTests` target (Cmd+U). The source is at `NavyDecoder/NavyDecoder.xcodeproj`.

## Data Update Workflow

The app bundles `NavyDecoder/NavyDecoder/DecoderData.json` directly. To update the data:

1. Edit the SQL source files in the Android sibling project (`NavyDecoderPlus-OpenSource/database/`)
2. Run `convertSqlScriptsToJson.pl` from that directory to regenerate `DecoderData.json`
3. Copy the result to `NavyDecoder/NavyDecoder/DecoderData.json`

JSON record format: `{ "categoryTitle": "...", "codeKey": "...", "codeValue": "...", "codeSource": "..." }`

RFAS categories appear as placeholder rows (`RFAS-Enlisted`, `RFAS-Officer`) — their codes are handled by the hardcoded `Rfas.m` model, not from the JSON.

## Architecture

### Data Layer

**`NDDataStore`** (singleton) — loads and parses `DecoderData.json` once at startup (warmed on a background queue in `AppDelegate`). Provides:
- `categoryTitles` — sorted list of unique category names
- `itemsForCategoryTitle:` — items for a category, sorted by `codeKey`
- `searchAllItemsForText:` — cross-category search on `codeKey` and `codeValue`

**`NDDecoderItem`** — plain model object with `categoryTitle`, `codeKey`, `codeValue`, `codeSource`. Replaces the old Core Data entities (`Category`, `Item`, `Details`).

### Navigation Flow

The app root is a `UISplitViewController` supporting both iPhone (navigation stack) and iPad (split view):

1. **`CategoryViewController`** — lists `NDDataStore.categoryTitles`. Has a global search bar (`navigationItem.searchController`) that searches all items across all categories via `searchAllItemsForText:`. Tapping a category segues to `ItemViewController` (`showItem`) or `RfasViewController` (`showRFAS`) — RFAS detection checks if the category title contains `"RFAS"`.
2. **`ItemViewController`** — lists items for the selected category. Inline `UISearchController` filters `codeKey`/`codeValue` within the category. Segues to `DetailTableViewController` (`showDetails` or `showDetailsAccessoryButton`).
3. **`DetailTableViewController`** — displays a single `NDDecoderItem`. Section 3 rows trigger share sheet, correction email, and App Store link.
4. **`RfasViewController`** — three-component `UIPickerView` for RFAS codes (officer or enlisted, set via `isEnlisted`). Result rendered in a `WKWebView` with dark mode support. Supports email sharing.

**`NavyDecoderMasterViewController`** — shared base class for all three table view controllers. Manages the rotating background image (`setBackgroundForSize:`), transparent cell/header backgrounds, mail compose delegate, and the open-source notice header view.

### Key Utilities

- **`NDCViewUtilities`** (singleton) — manages background images. Cycles through 8 images named `{0-7}_2048x2048_background.png`, center-cropped via `UIImage+ProportionalFill`. Index increments in `NSUserDefaults` on each app termination (`settingsBackgroundImageKey`).
- **`Rfas`** — encapsulates all RFAS code lookup logic for both officer and enlisted variants.
- **`ReviewManager`** (Swift, `@objc`) — increments a visit counter in `UserDefaults` each time `DetailTableViewController` appears; calls `SKStoreReviewController.requestReview(in:)` after 5 visits, at most once per build version.

## Mixed-Language Notes

Objective-C project with one Swift file (`ReviewManager.swift`). `SWIFT_VERSION = 5.0` and `SWIFT_OBJC_BRIDGING_HEADER` are already configured. To call Swift from ObjC: `#import "NavyDecoder-Swift.h"`. The bridging header (`NavyDecoder-Bridging-Header.h`) is empty — add ObjC headers there only if a Swift file needs to reference ObjC types directly.
