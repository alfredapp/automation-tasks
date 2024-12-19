#!/usr/bin/env swift

import QuickLookUI

let arguments = CommandLine.arguments
let minimumArguments = 1

// Helpers
class Preview: NSObject, QLPreviewPanelDelegate, QLPreviewPanelDataSource {
  private let panel: QLPreviewPanel = QLPreviewPanel.shared()
  private let items: [Item]

  init(items: [Item]) {
    self.items = items
  }

  func numberOfPreviewItems(in panel: QLPreviewPanel) -> Int {
    return items.count
  }

  func previewPanel(_ panel: QLPreviewPanel, previewItemAt index: Int) -> QLPreviewItem {
    return items[index]
  }

  func show() {
    panel.currentPreviewItemIndex = 0
    panel.dataSource = self
    panel.delegate = self
    panel.updateController()
    panel.makeKeyAndOrderFront(nil)
  }

  class Item: NSObject, QLPreviewItem {
    private let url: URL
    private let title: String

    init(path: URL) {
      self.url = path
      self.title = path.lastPathComponent
    }

    var previewItemURL: URL {
      return url
    }

    var previewItemTitle: String {
      return title
    }
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  private let paths: [URL]

  init(paths: [URL]) {
    self.paths = paths
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.accessory)
    NSApp.activate(ignoringOtherApps: true)

    Preview(items: paths.map { Preview.Item(path: $0) }).show()
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}

// Usage
func usage(_ exitStatus: Int32) {
  let binName = URL(fileURLWithPath: arguments[0]).lastPathComponent

  print(
    """
    Preview paths with Quick Look.

    Usage: \(binName) <path...>

    Options:
      -h, --help   Show this help.
    """
  )

  exit(exitStatus)
}

if arguments.contains("-h") || arguments.contains("--help") { usage(EXIT_SUCCESS) }
if arguments.count < minimumArguments + 1 { usage(EXIT_FAILURE) }

// Main
let previewPaths = arguments.dropFirst(minimumArguments).map { URL(fileURLWithPath: $0) }
let delegate = AppDelegate(paths: previewPaths)

let app = NSApplication.shared
app.delegate = delegate
app.run()
