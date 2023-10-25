#!/usr/bin/env swift

import Quartz

// Define available keys
let supportedKeys: [String: UInt32] = [
  "screen-brightness-up": 2,
  "screen-brightness-down": 3,
  "keyboard-brightness-up": 21,
  "keyboard-brightness-down": 22,
  "play-pause": 16,
  "fast-forward": 17,
  "rewind": 18,
  "volume-mute-toggle": 7,
  "volume-up": 0,
  "volume-down": 1,
]

// How to press keys
func pressKey(_ key: UInt32) {
  func keyDown(_ down: Bool) {
    let flags = NSEvent.ModifierFlags(rawValue: (down ? 0xa00 : 0xb00))
    let data1 = Int((key << 16) | (down ? 0xa00 : 0xb00))

    let event = NSEvent.otherEvent(
      with: NSEvent.EventType.systemDefined,
      location: NSPoint(x: 0, y: 0),
      modifierFlags: flags,
      timestamp: 0,
      windowNumber: 0,
      context: nil,
      subtype: 8,
      data1: data1,
      data2: -1
    )

    let cgevent = event?.cgEvent
    cgevent?.post(tap: CGEventTapLocation.cgSessionEventTap)
  }

  keyDown(true)
  keyDown(false)
}

// Set bounds for repeated key presses
let minRepeats = 1
let maxRepeats = 16

// Ensure correct arguments
// Else fail with usage
guard
  CommandLine.arguments.count == 3,  // Binary name plus two arguments
  let targetKey = supportedKeys[CommandLine.arguments[1]],  // Key to press
  let targetRepeats = Int(CommandLine.arguments[2]),  // How many times to press key
  targetRepeats >= minRepeats,
  targetRepeats <= maxRepeats
else {
  fatalError(
    """
      Usage:
        \(CommandLine.arguments[0]) <key-to-press> <times-to-press>

      Key to press must be one of: \(supportedKeys.keys.sorted().joined(separator: ", "))
      Times to press must be an integer between \(minRepeats) and \(maxRepeats)
    """)
}

// Press keys
for _ in 1...targetRepeats { pressKey(targetKey) }
usleep(100000)  // Prevent execution from terminating too soon
