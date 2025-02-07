import Foundation

let arguments = CommandLine.arguments
let minimumArguments = 3

// Helpers
func alfredArgs(_ args: [String]) {
  let alfredObject: [String: [String: [String]]] = ["alfredworkflow": ["arg": args]]
  let jsonData: Data = try! JSONSerialization.data(withJSONObject: alfredObject)
  let jsonString: String = String(data: jsonData, encoding: .utf8)!
  print(jsonString)
}

func isDir(_ path: URL) -> Bool {
  guard let dirStatus = try? path.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true else { return false }
  return dirStatus
}

func byName(_ paths: [URL]) -> [URL] {
  return paths.sorted { $0.path.localizedStandardCompare($1.path) == .orderedAscending }
}

func byAdded(_ paths: [URL]) -> [URL] {
  return paths.sorted {
    guard let a = try? $0.resourceValues(forKeys: [.addedToDirectoryDateKey]).addedToDirectoryDate else { return false }
    guard let b = try? $1.resourceValues(forKeys: [.addedToDirectoryDateKey]).addedToDirectoryDate else { return true }

    return a > b
  }
}

func shallowContents(_ path: URL) -> [URL] {
  guard let contents = try? FileManager.default.contentsOfDirectory(
    at: path,
    includingPropertiesForKeys: [.addedToDirectoryDateKey],
    options: .skipsHiddenFiles)
  else { fatalError("Could not get folder contents: \(path.path)") }

  return contents
}

func deepContents(_ path: URL) -> [URL] {
  guard let directoryEnumerator = FileManager.default.enumerator(
    at: path,
    includingPropertiesForKeys: nil,
    options: .skipsHiddenFiles)
  else { fatalError("Could not get folder contents: \(path.path)") }

  var files: [URL] = []
  for case let file as URL in directoryEnumerator { files.append(file) }
  return files
}

// Constants
let sortOrder: String = arguments[1]
let recursive: Bool = arguments[2] == "1"
let dirPaths: [URL] = arguments.dropFirst(minimumArguments).map { URL(fileURLWithPath: $0) }

// Main
dirPaths.forEach { if !isDir($0) { fatalError("Not a folder: \($0.path)") } }

let dirContents = recursive ?
  dirPaths.flatMap { deepContents($0) } :
  dirPaths.flatMap { shallowContents($0) }

switch sortOrder {
  case "by_name": alfredArgs(byName(dirContents).map { $0.path })
  case "by_added": alfredArgs(byAdded(dirContents).map { $0.path })
  default: fatalError("Unrecognised sort order: \(sortOrder)")
}
