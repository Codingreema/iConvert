//  ContentView.swift
//  JPEG
//
//  Created by Rimah on 29/06/1445 AH.
//
import SwiftUI
import UIKit
import PhotosUI

struct ContentView: View {
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
            Button("Select Images") {
                isImagePickerPresented.toggle()
            }
            .padding()
            .frame(width: 300, height: 50)
            .background(Color(colorScheme == .dark ? .gray : .white))
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

            Button("Convert to PDF") {
                convertImagesToPDF()
            }
            .padding()
            .frame(width: 300, height: 50)
            .background(Color(colorScheme == .dark ? .gray : .white))
            .foregroundColor(Color(colorScheme == .light ? .white : .black))
            .cornerRadius(5.0)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
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

    func simulateImageProcessing(images: [UIImage]) throws -> ProcessedImageData {
        guard let image = images.first,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageProcessing", code: 1, userInfo: ["error": "Failed to process image"])
        }

        return ProcessedImageData(imageName: "processedImage.jpg",
                                  imageData: imageData,
                                  description: "Processed image data")
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0  // Set the desired image selection limit (0 means no limit)

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            var selectedImages: [UIImage] = []
            let group = DispatchGroup()

            for result in results {
                group.enter()

                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        selectedImages.append(image)
                    }

                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.parent.selectedImages = selectedImages
            }
        }
    }
}

        #Preview {
                ContentView()
            }
        
    
