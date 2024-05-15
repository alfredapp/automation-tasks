#!/usr/bin/osascript -l JavaScript

ObjC.import("AppKit")

const systemEvents = Application("System Events")
const screens = $.NSScreen.screens.js
const screenPrimary = screens.find(screen => screen.frame.origin.x === 0 && screen.frame.origin.y === 0)
const menuBarPadding = $.NSMenu.menuBarHeight + 1 // Frame begins 1 point below Menu Bar
const topWindow = systemEvents.applicationProcesses.where({ frontmost: true })[0].windows.where({ subrole: "AXStandardWindow" })[0]

// $.NSScreen.mainScreen should return screen with active window,
// but while it works in Script Editor, when run from osascript it returns the primary screen
// Window -> Screen
function getScreenWithWindow(targetWindow) {
  const windowProperties = targetWindow.properties()

  const windowRect = $.NSMakeRect(
    windowProperties.position[0],
    // Screen coordinates are relative to bottom left, but window coordinates are relative to top left
    screenPrimary.frame.size.height - windowProperties.position[1] - windowProperties.size[1],
    windowProperties.size[0],
    windowProperties.size[1]
  )

  const windowMiddle = $.NSMakePoint($.NSMidX(windowRect), $.NSMidY(windowRect))

  // Screen containing window centre
  return screens.find(screen => {
    const screenRect = $.NSMakeRect(
      screen.frame.origin.x,
      screen.frame.origin.y,
      screen.frame.size.width,
      screen.frame.size.height
    )

    return $.NSPointInRect(windowMiddle, screenRect)
  })
}

// String -> Screen
function getScreenByDesc(screenName) {
  switch (screenName) {
    case "current":
      return getScreenWithWindow(topWindow)
    case "primary":
      return screenPrimary
    case "cursor":
      return screens.find(screen => $.NSMouseInRect($.NSEvent.mouseLocation, screen.frame, false))
    case "next":
      return getSideScreen(getScreenWithWindow(topWindow), "next")
    case "previous":
      return getSideScreen(getScreenWithWindow(topWindow), "previous")
    default:
      throw "Screen name not recognised: " + screenName
  }
}

// Screen, String ("previous" or "next") -> Screen
function getSideScreen(sourceScreen, direction) {
  const moveDirection = direction === "previous" ? -1 : 1
  const targetScreenIndex = (screens.indexOf(sourceScreen) + moveDirection) % screens.length // Loop around array
  return screens.at(targetScreenIndex)
}

// Screen -> Object (frame, screen coordinates)
function getUsableScreenFrame(screen) {
  const visibleFrame = screen.visibleFrame
  const fullFrame = screen.frame

  // Screen coordinates are relative to bottom left, but window coordinates are relative to top left
  const topPadding = (screen === screenPrimary) ?
    menuBarPadding :
    (fullFrame.size.height + fullFrame.origin.y - screenPrimary.frame.size.height - menuBarPadding) * -1

  return {
    // Visible frame
    x: visibleFrame.origin.x,
    y: topPadding, // Default Y is at bottom
    w: visibleFrame.size.width,
    h: visibleFrame.size.height,
    // Full frame
    full: {
      x: fullFrame.origin.x,
      y: topPadding, // Default Y is at bottom
      w: fullFrame.size.width,
      h: fullFrame.size.height
    }
  }
}

// Object (frame, screen coordinates), Window, Number, Number, Number, Number -> ()
function reshapeWindow(frame, targetWindow, x, y, width, height) {
  x = x < frame.x ? frame.x : x
  y = y < frame.y ? frame.y : y

  targetWindow.position = [x, y]
  targetWindow.size = [width, height]

  // Correct position for windows which up end out of visible frame
  const windowProperties = topWindow.properties()
  const windowRightEdge = windowProperties.position[0] + windowProperties.size[0]
  const windowBottomEdge = windowProperties.position[1] + windowProperties.size[1]

  const dockEdge = systemEvents.dockPreferences.screenEdge()
  const frameRightEdge = dockEdge === "right" ? frame.w : frame.full.w
  const frameBottomEdge = dockEdge === "bottom" ? frame.h + frame.full.y : frame.full.h

  const newX = windowRightEdge > frameRightEdge ? frameRightEdge - windowProperties.size[0] : x
  const newY = windowBottomEdge > frameBottomEdge ? frameBottomEdge - windowProperties.size[1] : y

  if (x === newX && y === newY) return // Stop if new position would be unchanged
  if (newX < frame.full.x || newY < frame.full.y) return // Stop if new postion would change screens

  reshapeWindow(frame, targetWindow, newX, newY, width, height)
}

function run(argv) {
  let windowProperties, windowWidth, windowHeight // Used in centre and custom-*
  const frame = getUsableScreenFrame(getScreenByDesc(argv[0]))

  switch (argv[1]) {
    case "half-left":
      return reshapeWindow(frame, topWindow,
        frame.x,
        frame.y,
        frame.w / 2,
        frame.h
      )
    case "half-right":
      return reshapeWindow(frame, topWindow,
        frame.x + frame.w / 2,
        frame.y,
        frame.w / 2,
        frame.h
      )
    case "half-centrewidth":
      return reshapeWindow(frame, topWindow,
        frame.x + frame.w / 4,
        frame.y,
        frame.w / 2,
        frame.h
      )
    case "half-top":
      return reshapeWindow(frame, topWindow,
        frame.x,
        frame.y,
        frame.w,
        frame.h / 2
      )
    case "half-bottom":
      return reshapeWindow(frame, topWindow,
        frame.x,
        frame.y + frame.h / 2,
        frame.w,
        frame.h / 2
      )
    case "quarter-top-left":
      return reshapeWindow(frame, topWindow,
        frame.x,
        frame.y,
        frame.w / 2,
        frame.h / 2
      )
    case "quarter-top-right":
      return reshapeWindow(frame, topWindow,
        frame.x + frame.w / 2,
        frame.y,
        frame.w / 2,
        frame.h / 2
      )
    case "quarter-bottom-left":
      return reshapeWindow(frame, topWindow,
        frame.x,
        frame.y + frame.h / 2,
        frame.w / 2,
        frame.h / 2
      )
    case "quarter-bottom-right":
      return reshapeWindow(frame, topWindow,
        frame.x + frame.w / 2,
        frame.y + frame.h / 2,
        frame.w / 2,
        frame.h / 2
      )
    case "quarter-centrewidth-centreheight":
      return reshapeWindow(frame, topWindow,
        frame.x + frame.w / 4,
        frame.y + frame.h / 4,
        frame.w / 2,
        frame.h / 2
      )
    case "third-left":
      return reshapeWindow(frame, topWindow,
        frame.x,
        frame.y,
        frame.w / 3,
        frame.h
      )
    case "third-right":
      return reshapeWindow(frame, topWindow,
        frame.x + frame.w / 1.5,
        frame.y,
        frame.w / 3,
        frame.h
      )
    case "third-centrewidth":
      return reshapeWindow(frame, topWindow,
        frame.x + frame.w / 3,
        frame.y,
        frame.w / 3,
        frame.h
      )
    case "twothirds-left":
      return reshapeWindow(frame, topWindow,
        frame.x,
        frame.y,
        frame.w / 1.5,
        frame.h
      )
    case "twothirds-right":
      return reshapeWindow(frame, topWindow,
        frame.x + frame.w / 3,
        frame.y,
        frame.w / 1.5,
        frame.h
      )
    case "twothirds-centrewidth":
      return reshapeWindow(frame, topWindow,
        frame.x + frame.w / 6,
        frame.y,
        frame.w / 1.5,
        frame.h
      )
    case "maximise":
      return reshapeWindow(frame, topWindow,
        frame.x,
        frame.y,
        frame.w,
        frame.h
      )
    case "centre":
      windowProperties = topWindow.properties()
      windowWidth = windowProperties.size[0] > frame.w ? frame.w : windowProperties.size[0]
      windowHeight = windowProperties.size[1] > frame.h ? frame.h : windowProperties.size[1]

      return reshapeWindow(frame, topWindow,
        frame.w / 2 - windowWidth / 2 + frame.x,
        frame.h / 2 - windowHeight / 2 + frame.y,
        windowWidth,
        windowHeight
      )
    case "custom":
      windowProperties = topWindow.properties()
      windowX = argv[2].length > 0 ? argv[2] : windowProperties.position[0]
      windowY = argv[3].length > 0 ? argv[3] : windowProperties.position[1]
      windowWidth = argv[4].length > 0 ? argv[4] : windowProperties.size[0]
      windowheight = argv[5].length > 0 ? argv[5] : windowProperties.size[1]

      return reshapeWindow(frame, topWindow,
        windowX,
        windowY,
        windowWidth,
        windowheight
      )
    case "custom-sizefromwindowcentre":
      windowProperties = topWindow.properties()
      windowWidth = argv[2] > frame.w ? frame.w : argv[2]
      windowHeight = argv[3] > frame.h ? frame.h : argv[3]

      const initWindowCentreX = windowProperties.position[0] + windowProperties.size[0] / 2
      const initWindowCentreY = windowProperties.position[1] + windowProperties.size[1] / 2

      return reshapeWindow(frame, topWindow,
        initWindowCentreX - windowWidth / 2,
        initWindowCentreY - windowHeight / 2,
        windowWidth,
        windowHeight
      )
    default:
      throw "Position not recognised: " + argv[1]
  }
}
