#!/usr/bin/swift

import CoreGraphics
import Foundation

// Constants
let arguments = CommandLine.arguments
let argumentNumber = 2

// Usage
func usage(_ exitStatus: Int32) {
  let binName = URL(fileURLWithPath: arguments[0]).lastPathComponent

  print(
    """
    Type text character by character

    Usage: \(binName) <text to type> <delay in microseconds>

    Options:
      -h, --help   Show this help.
    """
  )

  exit(exitStatus)
}

if arguments.count != argumentNumber + 1 { usage(EXIT_FAILURE) }
if arguments.contains("-h") || arguments.contains("--help") { usage(EXIT_SUCCESS) }

// Main
let typeText = arguments[1].precomposedStringWithCanonicalMapping.utf16
let delaySpeed = UInt32(arguments[2]) ?? 1000
var uChar: UniChar
var keyEvent: CGEvent? = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true)

for i in 0..<typeText.count {
  uChar = typeText[typeText.index(typeText.startIndex, offsetBy: i)]
  keyEvent?.keyboardSetUnicodeString(stringLength: 1, unicodeString: &uChar)
  keyEvent?.post(tap: .cghidEventTap)
  keyEvent?.type = .keyUp
  keyEvent?.post(tap: .cghidEventTap)
  keyEvent?.type = .keyDown
  usleep(delaySpeed)
}

usleep(100000)  // Prevent execution from terminating too soon
