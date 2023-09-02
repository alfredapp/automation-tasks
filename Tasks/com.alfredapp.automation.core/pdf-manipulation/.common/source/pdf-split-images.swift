#!/usr/bin/env swift

import PDFKit

// Get details from arguments
let pdfFile = URL(fileURLWithPath: CommandLine.arguments[1])
let imageFolder = URL(fileURLWithPath: CommandLine.arguments[2])
let imageFormat = CommandLine.arguments[3]
let imageScale = CGFloat(Int(CommandLine.arguments[4])!) / 72  // The default resolution is 72

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

// Set details from file format
// Available types: https://developer.apple.com/documentation/appkit/nsbitmapimagerep/filetype
let imageExtension: String
let imageType: NSBitmapImageRep.FileType

switch imageFormat {
case "tiff":
  imageExtension = "tiff"
  imageType = .tiff
case "bmp":
  imageExtension = "bmp"
  imageType = .bmp
case "gif":
  imageExtension = "gif"
  imageType = .gif
case "jpeg":
  imageExtension = "jpeg"
  imageType = .jpeg
case "png":
  imageExtension = "png"
  imageType = .png
case "jp2":
  imageExtension = "jp2"
  imageType = .jpeg2000
default:
  fatalError("Invalid image format: \(imageFormat)")
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
  at: imageFolder, withIntermediateDirectories: true, attributes: nil)

// Extract pages
let outputImages: [String] = pageIndexes.compactMap { pageIndex in
  let pageNumber = pageIndex + 1
  let pageName = String(format: "Page %0\(leadingZeros)d", pageNumber)
  let imageURL = imageFolder.appendingPathComponent("\(pageName).\(imageExtension)")

  guard let page = pdfDocument.page(at: pageIndex) else {
    warning("Failed to load page: \(pageNumber)")
    return nil
  }

  // Create image representation
  let pageBounds = page.bounds(for: .mediaBox)
  let pageWidth = pageBounds.size.width * imageScale
  let pageHeight = pageBounds.size.height * imageScale

  guard
    let tiffRep = page.thumbnail(of: CGSize(width: pageWidth, height: pageHeight), for: .mediaBox)
      .tiffRepresentation,
    let imageData = NSBitmapImageRep(data: tiffRep)?.representation(
      using: imageType, properties: [:])
  else {
    warning("Failed to extract page: \(pageNumber)")
    return nil
  }

  // Save image
  try? imageData.write(to: imageURL)
  return imageURL.path
}

// Output JSON
alfredArgs(outputImages)
