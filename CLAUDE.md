# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projects

This repository contains two Xcode projects:

- **`NavyDecoder/NavyDecoder.xcodeproj`** — The main iOS app (Objective-C, UIKit)
- **`NavyDecoderDatabaseLoader/NavyDecoderDatabaseLoader.xcodeproj`** — A macOS command-line tool that generates the SQLite database from JSON

Open **`NavyDecoder.xcworkspace`** in Xcode to work with the iOS app. Build and run via Xcode (Cmd+R). Tests are in the `NavyDecoderTests` target (Cmd+U).

## Database Update Workflow

The app ships with a read-only SQLite database bundled in the app bundle. To update the data:

1. Edit `NavyDecoderDatabaseLoader/NavyDecoderDatabaseLoader/DecoderData.json`
2. Build and run the `NavyDecoderDatabaseLoader` macOS command-line tool in Xcode
3. Copy the generated `DecoderData.sqlite` to `NavyDecoder/NavyDecoder/DecoderData.sqlite`

The JSON format is: `{ "categoryTitle": "...", "codeKey": "...", "codeValue": "...", "codeSource": "..." }`

## Architecture

### Core Data Model

Three entities in `NavyDecoder.xcdatamodeld`:
- **`Category`** — `categoryTitle` string; one-to-many relationship to `Item`
- **`Item`** — `codeKey` string; belongs to one `Category`; has one `Details`
- **`Details`** — `codeValue` and `codeSource` strings; belongs to one `Item`

The persistent store is opened read-only directly from the app bundle (no copy to Documents directory).

### Navigation Flow

The app uses a `UISplitViewController` (`OverallSplitViewController`) as the root, supporting both iPhone (navigation stack) and iPad (split view) layouts:

1. **`CategoryViewController`** — Lists all `Category` objects from Core Data. Selecting a row segues to either `ItemViewController` (segue `showItem`) or `RfasViewController` (segue `showRFAS`) — RFAS categories are detected by checking if the cell's title contains the string `"RFAS"`.
2. **`ItemViewController`** — Lists `Item` objects for the selected category with a `UISearchController` that filters by `codeKey` or `codeValue`. Segues to `DetailTableViewController` on selection.
3. **`DetailTableViewController`** — Displays `codeKey`, `codeValue`, and `codeSource` for a single item. Section 3 provides email sharing and App Store review actions.
4. **`RfasViewController`** — Special three-component `UIPickerView` UI for RFAS codes (officer or enlisted). Results rendered in a `WKWebView`/`UIWebView` with dark mode support. Supports email sharing of decoded result.

`NavyDecoderMasterViewController` is a shared base class for table view controllers that manages the rotating background image and App Store review prompts.

### Key Utilities

- **`NDCViewUtilities`** (singleton) — Manages background images. Cycles through 8 images named `{0-7}_2048x2048_background.png`, center-cropped to the current screen size. The background index increments on each app termination (stored in `NSUserDefaults`).
- **`ViewConstants`** / `NDPTextSize` — iPad-specific text size constant used across all view controllers.
- **`UIImage+ProportionalFill`** — Category providing center-crop image scaling.
- **`Rfas`** — Model class encapsulating all RFAS code lookup logic (first, second/third, and fourth character meanings, for both officer and enlisted variants).
