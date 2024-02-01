import Foundation

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

let sortOrder = CommandLine.arguments[1]
let dirPaths = Array(CommandLine.arguments.dropFirst(2)).map { URL(fileURLWithPath: $0) }

dirPaths.forEach { if !isDir($0) { fatalError("Not a folder: \($0.path)") } }

let dirContents = dirPaths.flatMap { dirPath -> [URL] in
  guard let contents = try? FileManager.default.contentsOfDirectory(
    at: dirPath,
    includingPropertiesForKeys: [.addedToDirectoryDateKey],
    options: .skipsHiddenFiles)
  else { fatalError("Could not get folder contents: \(dirPath.path)") }

  return contents
}

switch sortOrder {
  case "by_name": alfredArgs(byName(dirContents).map { $0.path })
  case "by_added": alfredArgs(byAdded(dirContents).map { $0.path })
  default: fatalError("Unrecognised sort order: \(sortOrder)")
}
