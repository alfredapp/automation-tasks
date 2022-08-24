import Foundation

let argv = CommandLine.arguments

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

func isDir(_ path: URL) -> Bool {
  do {
    return try path.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true
  } catch {
    return false
  }
}

func recursePath(_ url: URL) -> [URL] {
  // Return path early if not directory
  guard isDir(url) else { return [url] }

  // Return path if cannot get directory contents
  guard
    let directoryEnumerator = FileManager.default.enumerator(
      at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
  else { return [url] }

  // Get paths
  var fileURLs: [URL] = []
  for case let fileURL as URL in directoryEnumerator { fileURLs.append(fileURL) }

  return [url] + fileURLs
}

func deduplicateStringArray(_ array: [String]) -> [String] {
  return Array(NSOrderedSet(array: array)).map { String(describing: $0) }
}

// Usage
func usage() {
  print(
    """
    Usage: tag <mode> <tags> <recursive> <path...>

      mode: 'read', 'add', 'remove', 'set', 'clear'
      tags: newline-separated list (leave empty for 'read' and 'clear')
      recursive: '0' (false) or '1' (true)
    """
  )
}

if argv.count < 5 {
  usage()
  exit(1)
}

if argv.contains("-h") || argv.contains("--help") {
  usage()
  exit(0)
}

// Constants
let writeMode: String = argv[1]
let newTags: [String] = argv[2].split(separator: "\n").map { String($0) }
let recursive: Bool = argv[3] == "1"
let initPaths: [URL] = argv.dropFirst(4).map { URL(fileURLWithPath: $0) }
let allPaths: [URL] = initPaths.flatMap { recursive ? recursePath($0) : [$0] }

// Read tags
if writeMode == "read" {
  let allTags: [String] = try allPaths.flatMap {
    try $0.resourceValues(forKeys: [.tagNamesKey]).tagNames ?? []
  }

  alfredArgs(deduplicateStringArray(allTags).sorted())
  exit(EXIT_SUCCESS)
}

// Write tags
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
