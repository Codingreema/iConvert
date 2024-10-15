//
//  ImagePicker.swift
//  JPEG
//
//  Created by Rimah on 29/06/1445 AH.
//

import SwiftUI
import UIKit

struct ImagePicker0: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var isImagePickerPresented = false
    @State private var selectedImages: [UIImage] = []
    @State private var jsonData: Data?
    @State private var isProcessing = false
    @State private var errorMessage: String?

    struct ProcessedImageData: Codable {
        let imageName: String
        let imageData: Data
        let description: String
    }

    var body: some View {
        VStack {
            // 1
            Button("Select Images") {
                isImagePickerPresented.toggle()
            }
            .padding()
                          .frame(width: 300, height: 50)
                          .background(Color.gray)
                                  .foregroundColor(Color(colorScheme == .light ? .white : .black))
                                  .cornerRadius(5.0)

            if !selectedImages.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                        }
                    }
                }
            }

            if isProcessing {
                ProgressView()
            }
            // 2
            Button("Convert to PDF") {
                convertImagesToPDF()
            }
            .padding()
            .frame(width: 300, height: 50)
            .background(Color.gray)
            .foregroundColor(Color(colorScheme == .light ? .white : .black))
            .cornerRadius(5.0)
            // 3
            Button("Convert to JSON") {
                ConvertImageToJSON()
            }
            .padding()
            .frame(width: 300, height: 50)
            .background(Color.gray)
            .foregroundColor(Color(colorScheme == .light ? .white : .black))
            .cornerRadius(5.0)
            
            // 4
            
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImages: $selectedImages)
        }
        .background(Color(colorScheme == .dark ? .black : .white))
        .edgesIgnoringSafeArea(.all)

        .onChange(of: selectedImages) { _ in
            processImages()
        }
    }
    func convertJSONToImage() {
        guard let jsonData = jsonData else {
            errorMessage = "No JSON data available"
            return
        }
        
        do {
            let processedData = try JSONDecoder().decode(ProcessedImageData.self, from: jsonData)
            if let convertedImage = UIImage(data: processedData.imageData) {
                selectedImages.append(convertedImage)
            } else {
                errorMessage = "Failed to convert JSON to image: Invalid image data"
            }
        } catch {
            errorMessage = "Failed to convert JSON to image: \(error.localizedDescription)"
        }
    }
    func convertImagesToPDF() {
        guard !selectedImages.isEmpty else {
            errorMessage = "No images selected"
            return
        }

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)

        for image in selectedImages {
            UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height), nil)
            let context = UIGraphicsGetCurrentContext()
            image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }

        UIGraphicsEndPDFContext()

        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let fileURL = temporaryDirectoryURL.appendingPathComponent("convertedPDF.pdf")
        pdfData.write(to: fileURL, atomically: true)

        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }

    func convertImagesToJSON() {
        guard !selectedImages.isEmpty else {
            errorMessage = "No images selected"
            return
        }

        do {
            let processedData = try simulateImageProcessing(images: selectedImages)
            jsonData = try JSONEncoder().encode(processedData)

            // Print the JSON data as a string (for demonstration purposes)
            if let jsonString = String(data: jsonData!, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
  
    func processImages() {
        isProcessing = true
        errorMessage = nil

        DispatchQueue.global().async {
            do {
                let processedData = try simulateImageProcessing(images: selectedImages)
                jsonData = try JSONEncoder().encode(processedData)
            } catch {
                errorMessage = error.localizedDescription
            }

            DispatchQueue.main.async {
                isProcessing = false
            }
        }
    }
    func ConvertImageToJSON() {
        guard !selectedImages.isEmpty else {
            errorMessage = "No images selected"
            return
        }

        do {
            let processedData = try simulateImageProcessing(images: selectedImages)
            jsonData = try JSONEncoder().encode(processedData)

            // Print the JSON data as a string (for demonstration purposes)
            if let jsonString = String(data: jsonData!, encoding: .utf8) {
                print(jsonString)
            }

            let temporaryDirectoryURL = FileManager.default.temporaryDirectory
            let fileURL = temporaryDirectoryURL.appendingPathComponent("convertedJSON.json")
            try jsonData?.write(to: fileURL, options: .atomic)

            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    func simulateImageProcessing(images: [UIImage]) throws -> ProcessedImageData {
        guard let image = images.first,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageProcessing", code: 1, userInfo: ["error": "Failed toconvert the image to data."])
        }

        let processedData = ProcessedImageData(imageName: "Processed Image", imageData: imageData, description: "This is a processed image.")
        return processedData
    }
}

struct JSONImageData: Codable {
    let imageName: String
    let imageData: String
    let description: String
}

func simulateImageProcessing(images: [UIImage]) throws -> JSONImageData {
    guard let image = images.first,
          let imageData = image.jpegData(compressionQuality: 0.8)?.base64EncodedString() else {
        throw NSError(domain: "ImageProcessing", code: 1, userInfo: ["error": "Failed to convert the image to data."])
    }

    let processedData = JSONImageData(imageName: "Processed Image", imageData: imageData, description: "This is a processed image.")
    return processedData
}
struct ImagePicker1: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.mediaTypes = ["public.image"]
        picker.navigationBar.tintColor = .white
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker1

        init(_ parent: ImagePicker1) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImages.append(image)
            }

            picker.dismiss(animated: true, completion: nil)
        }
    }
}

#Preview {
        ImagePicker0()
    }

