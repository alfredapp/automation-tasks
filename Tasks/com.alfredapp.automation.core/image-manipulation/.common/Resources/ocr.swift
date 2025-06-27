import AppKit
import Vision

// Prepare recognition
let request = VNRecognizeTextRequest()

switch CommandLine.arguments[1] {
case "fast":
  request.recognitionLevel = .fast
  request.usesLanguageCorrection = false
default:
  request.recognitionLevel = .accurate
  request.usesLanguageCorrection = true
}

// Recognise all images
CommandLine.arguments.dropFirst(2).forEach { imagePath in
  let imageURL = URL(fileURLWithPath: imagePath)

  // Load image data
  guard let image = NSImage(contentsOf: imageURL)?.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    fputs("Unable to load \(imagePath)", stderr)
    return
  }

  // Perform recognition
  guard (try? VNImageRequestHandler(cgImage: image).perform([request])) != nil else {
    fputs("Unable to perform OCR on \(imagePath)", stderr)
    return
  }

  // Return early if no text found
  guard let observations = request.results else { return }

  // Output text
  let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
  print(recognizedStrings.joined(separator: "\n"))
}
