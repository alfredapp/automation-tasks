import UniformTypeIdentifiers

let arguments = CommandLine.arguments
let minimumArguments = 3

// Helpers
func alfredArgs(_ args: [String]) {
  let alfredObject: [String: [String: [String]]] = ["alfredworkflow": ["arg": args]]
  let jsonData: Data = try! JSONSerialization.data(withJSONObject: alfredObject)
  let jsonString: String = String(data: jsonData, encoding: .utf8)!
  print(jsonString)
}

enum WriteMode: String {
  case read = "read"
  case filter = "filter-matching"
  case xfilter = "filter-not-matching"
}

func fileType(_ fileURL: URL) -> UTType {
  guard let contentType = try? fileURL.resourceValues(forKeys: [.contentTypeKey]).contentType else { fatalError("Could not determine type: \(fileURL.path)") }
  return contentType
}

// Usage
func usage(_ exitStatus: Int32) {
  let binName = URL(fileURLWithPath: arguments[0]).lastPathComponent

  print(
    """
    Usage: \(binName) <mode> <type> <path...>

      mode: 'read', 'filter-matching', 'filter-not-matching'
      type: type to filter for (leave empty for 'read')
    """
  )

  exit(exitStatus)
}

if arguments.contains("-h") || arguments.contains("--help") { usage(EXIT_SUCCESS) }

// Constants
guard
  arguments.count > minimumArguments,
  let writeMode: WriteMode = WriteMode(rawValue: arguments[1])
else {
  usage(EXIT_FAILURE)
  exit(EXIT_FAILURE)
}

let allPaths: [URL] = arguments.dropFirst(minimumArguments).map { URL(fileURLWithPath: $0) }

// Read
if (writeMode == .read) {
  let allMIMEs = allPaths.compactMap { fileType($0).preferredMIMEType }
  guard allMIMEs.count > 0 else { fatalError("Could not determine type") }

  alfredArgs(allMIMEs)
  exit(EXIT_SUCCESS)
}

// Filter
let typeFilter: String = arguments[2]

switch writeMode {
case .filter:  alfredArgs(allPaths.compactMap { fileType($0).preferredMIMEType == typeFilter ? $0.path : nil })
case .xfilter: alfredArgs(allPaths.compactMap { fileType($0).preferredMIMEType != typeFilter ? $0.path : nil })
default: fatalError("Unrecognised mode: \(writeMode)")
}
