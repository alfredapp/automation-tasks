#!/usr/bin/env swift

import PDFKit

// Get details from arguments
let pdfFile = URL(fileURLWithPath: CommandLine.arguments[1])
let pdfFolder = URL(fileURLWithPath: CommandLine.arguments[2])

// Helpers
func alfredArgs(_ args: [String]) {
  let alfredObject: [String: [String: [String]]] = ["alfredworkflow": ["arg": args]]
  let jsonData: Data = try! JSONSerialization.data(withJSONObject: alfredObject)
  let jsonString: String = String(data: jsonData, encoding: .utf8)!
  print(jsonString)
}

func warning(_ message: String) {
  fputs("\(message)\n", stderr)
}

// Load PDF
guard let pdfDocument = PDFDocument(url: pdfFile) else {
  fatalError("Unable to load file: \(pdfFile.path)")
}

let pageCount = pdfDocument.pageCount
let leadingZeros = String(pageCount).count
let pageIndexes = Array(0..<pageCount)

// Create output directory
try FileManager.default.createDirectory(
  at: pdfFolder, withIntermediateDirectories: true, attributes: nil)

// Extract pages
let outputPDFs: [String] = pageIndexes.compactMap { pageIndex in
  let pageNumber = pageIndex + 1
  let pageName = String(format: "Page %0\(leadingZeros)d", pageNumber)
  let pdfURL = pdfFolder.appendingPathComponent("\(pageName).pdf")

  guard let page = pdfDocument.page(at: pageIndex) else {
    warning("Failed to load page: \(pageNumber)")
    return nil
  }

  // Save PDF
  let newDocument = PDFDocument()
  newDocument.insert(page, at: 0)
  newDocument.write(to: pdfURL)
  return pdfURL.path
}

// Output JSON
alfredArgs(outputPDFs)
