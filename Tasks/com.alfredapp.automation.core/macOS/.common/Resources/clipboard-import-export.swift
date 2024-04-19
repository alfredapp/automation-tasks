import AppKit

// Constants
let arguments = CommandLine.arguments
let numberArguments = 2

// Helpers
func exportClipboard(to saveFile: URL, pasteboard: NSPasteboard = NSPasteboard.general) {
  guard
    let pasteboardContents: NSMutableDictionary = pasteboard.types?.reduce(
      into: [:], { $0[$1] = pasteboard.data(forType: $1) })
  else { fatalError("Unable to read clipboard data") }

  do { try pasteboardContents.write(to: saveFile) }
  catch { fatalError("Unable to save clipboard data to file: \(saveFile.path)") }
}

func importClipboard(from saveFile: URL, pasteboard: NSPasteboard = NSPasteboard.general) {
  let pasteboardContents = NSDictionary(contentsOf: saveFile)
  pasteboard.clearContents()
  pasteboardContents?.forEach {
    pasteboard.setData($0.value as? Data, forType: $0.key as! NSPasteboard.PasteboardType)
  }
}

// Usage
func usage(_ exitStatus: Int32) {
  let binName = URL(fileURLWithPath: arguments[0]).lastPathComponent

  print(
    """
    Usage:
      \(binName) <export|import> <file>
    """
  )

  exit(exitStatus)
}

if arguments.count != numberArguments + 1 { usage(EXIT_FAILURE) }
if arguments.contains("-h") || arguments.contains("--help") { usage(EXIT_SUCCESS) }

let writeMode = CommandLine.arguments[1]
let filePath = URL(fileURLWithPath: CommandLine.arguments[2])

switch writeMode {
case "export": exportClipboard(to: filePath)
case "import": importClipboard(from: filePath)
default: fatalError("Unrecognised mode: \(writeMode)")
}
