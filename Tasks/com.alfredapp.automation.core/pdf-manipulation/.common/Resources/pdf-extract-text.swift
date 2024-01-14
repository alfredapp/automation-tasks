#!/usr/bin/env swift

import PDFKit

// Get details from arguments
let pdfFile = URL(fileURLWithPath: CommandLine.arguments[1])

// Load PDF
guard let pdfDocument = PDFDocument(url: pdfFile) else {
  fatalError("Unable to load file: \(pdfFile.path)")
}

// Extract text
print(pdfDocument.string ?? "")
