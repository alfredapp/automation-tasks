import Foundation

let arguments = CommandLine.arguments
let minimumArguments = 4

// Helpers
func alfredArgs(_ args: [String]) {
  let alfredObject: [String: [String: [String]]] = ["alfredworkflow": ["arg": args]]
  let jsonData: Data = try! JSONSerialization.data(withJSONObject: alfredObject)
  let jsonString: String = String(data: jsonData, encoding: .utf8)!
  print(jsonString)
}

func envVar(_ variable: String) -> String? {
  return ProcessInfo.processInfo.environment[variable]
}

func deduplicateStringArray(_ array: [String]) -> [String] {
  return Array(NSOrderedSet(array: array)).map { String(describing: $0) }
}

func isPackage(_ path: URL) -> Bool {
  guard let isPackage = try? path.resourceValues(forKeys: [.isPackageKey]).isPackage else { return false }
  return isPackage == true
}

func recursePath(_ url: URL) -> [URL] {
  // Return early if package (e.g. app bundle)
  if isPackage(url) { return [url] }

  // Get paths
  let directoryEnumerator = FileManager.default.enumerator(
    at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)!

  var fileURLs: [URL] = []

  for case let fileURL as URL in directoryEnumerator {
    if isPackage(fileURL) { directoryEnumerator.skipDescendants() }
    fileURLs.append(fileURL)
  }

  return [url] + fileURLs
}

// Usage
func usage(_ exitStatus: Int32) {
  let binName = URL(fileURLWithPath: arguments[0]).lastPathComponent

  print(
    """
    Edit tags on paths.

    Usage: \(binName) <mode> <tags> <recursive> <path...>

      mode: 'read', 'add', 'remove', 'set', 'clear'
      tags: newline-separated list (leave empty for 'read' and 'clear')
      recursive: '0' (false) or '1' (true)

    Options:
      -h, --help   Show this help.
    """
  )

  exit(exitStatus)
}

if arguments.contains("-h") || arguments.contains("--help") { usage(EXIT_SUCCESS) }
if arguments.count < minimumArguments + 1 { usage(EXIT_FAILURE) }

// Constants
let writeMode: String = arguments[1]
let newTags: [String] = arguments[2].split(separator: "\n").map { String($0) }
let recursive: Bool = arguments[3] == "1"
let initPaths: [URL] = arguments.dropFirst(minimumArguments).map { URL(fileURLWithPath: $0) }
let allPaths: [URL] = initPaths.flatMap { recursive ? recursePath($0) : [$0] }

// Read
if writeMode == "read" {
  let allTags: [String] = try allPaths.flatMap {
    try $0.resourceValues(forKeys: [.tagNamesKey]).tagNames ?? []
  }

  alfredArgs(deduplicateStringArray(allTags).sorted())
  exit(EXIT_SUCCESS)
}

// Write
try allPaths.forEach { path in
  let currentTags: [String] = try path.resourceValues(forKeys: [.tagNamesKey]).tagNames ?? []

  let wantedTags: [String] = {
    switch writeMode {
    case "add": return currentTags + newTags
    case "remove": return currentTags.filter { !newTags.contains($0) }
    case "set": return newTags
    case "clear": return []
    default: fatalError("Unrecognised mode: \(writeMode)")
    }
  }()

  let finalTags: [String] = deduplicateStringArray(wantedTags)

  try (path as NSURL).setResourceValues([.tagNamesKey: finalTags])
}
