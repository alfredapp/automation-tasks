#!/usr/bin/env swift

import AppKit

// Constants
let browserNames: Set<String> = [
  "Safari", "Webkit", "Orion",
  "Google Chrome", "Chromium", "Opera", "Vivaldi", "Brave Browser", "Microsoft Edge", "Arc"
]

// Grab windows
let windowList: CFArray? = CGWindowListCopyWindowInfo(
  [.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)

guard let windows = windowList as? [[String: Any]] else { fatalError("Unable to get window list") }

let firstMatchingBrowserWindow = windows.first { window in
  // Ensure valid app names from windows
  guard
    window["kCGWindowLayer"] as? Int == 0,
    let appName = window["kCGWindowOwnerName"] as? String
  else { return false }

  // Check if app is a supported browser
  return browserNames.contains { appName.hasPrefix($0) }
}

// Output
guard
  let firstMatchingBrowserWindow,
  let matchedBrowser = firstMatchingBrowserWindow["kCGWindowOwnerName"] as? String
else { fatalError("Did not find a supported web browser") }

print(matchedBrowser)
