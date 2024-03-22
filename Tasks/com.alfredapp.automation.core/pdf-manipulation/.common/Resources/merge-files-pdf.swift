#!/usr/bin/env swift

import PDFKit
import UniformTypeIdentifiers

// Get details from arguments
let pdfFile = URL(fileURLWithPath: CommandLine.arguments[1])
let joinFiles = Array(CommandLine.arguments.dropFirst(2)).map { URL(fileURLWithPath: $0) }

// Helpers
func conformsToType(file: URL, type: UTType) -> Bool {
  guard let fileType = try? file.resourceValues(forKeys: [.contentTypeKey]).contentType else {
    return false
  }

  return fileType.conforms(to: type)
}

// Create output directory
try FileManager.default.createDirectory(
  at: pdfFile.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)

// Join to PDF
let pdfDocument = PDFDocument()

joinFiles.forEach { joinFile in
  // If input file is PDF, append every page
  if conformsToType(file: joinFile, type: .pdf) {
    guard let joinPDF = PDFDocument(url: joinFile) else {
      fatalError("Failed to load file: \(joinFile.path)")
    }

    let pageCount = joinPDF.pageCount
    let pageIndexes = Array(0..<pageCount)

    pageIndexes.forEach { pageIndex in
      guard let page = joinPDF.page(at: pageIndex) else {
        fatalError("Failed to load file: \(joinFile.path)")
      }

      pdfDocument.insert(page, at: pdfDocument.pageCount)
    }

    return
  }

  // If input file is image
  if conformsToType(file: joinFile, type: .image) {
    let image = {
      let imageRef = NSImage(byReferencing: joinFile)
      // Redraw the image to avoid the "Invalid image orientation, assuming 1." error
      return NSImage(size: imageRef.size, flipped: false, drawingHandler: { imageRef.draw(in: $0); return true })
    }()

    guard let page = PDFPage(image: image) else {
      fatalError("Failed to load file: \(joinFile.path)")
    }

    pdfDocument.insert(page, at: pdfDocument.pageCount)
    return
  }

  // If we reach this point, file isn't of a supported type
  fatalError("Inputs must be PDFs or images. Failed on: \(joinFile.path)")
}

// Write PDF
pdfDocument.write(to: pdfFile)
print(pdfFile.path)
