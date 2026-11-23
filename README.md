# 📄 iConvert

An iOS app that converts one or many photos into a **PDF** or **JSON** file in a few taps, then lets you share or save the result.

## Features

- Select any number of images from your photo library
- Combine them into a single PDF, with one page per image at its original size
- Export image data as a JSON file
- Share or save the file through the iOS share sheet

## Tech stack

- **SwiftUI** for the interface
- **PhotosUI** (`PHPickerViewController`) for multi-image selection
- **UIKit PDF rendering** (`UIGraphicsBeginPDFContextToData`) to build the PDF
- **Codable / JSONEncoder** for the JSON export
- `UIActivityViewController` for sharing
- Localized with String Catalogs (`Localizable.xcstrings`)

## Run it

1. Open `JPEG/JPEG.xcodeproj` in Xcode.
2. Build and run on an iPhone or the iOS Simulator.

## Author

**Rimah Aldaghfaq**: [Portfolio](https://codingreema.github.io) · [LinkedIn](https://www.linkedin.com/in/rimahaldaghfaq)
