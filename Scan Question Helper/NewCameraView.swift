import SwiftUI
import Combine
import AVFoundation
import PhotosUI

// REMOVE UIImage Extension for Orientation Correction

final class CameraModel: ObservableObject {
    private let service = CameraService()
    
    @Published var photo: Photo!
    @Published var showAlertError = false
    @Published var isFlashOn = false
    @Published var willCapturePhoto = false
    @Published var cropRect: CGRect = .zero
    @Published var isDragging = false // Keep isDragging if needed by previous state
    @Published var selectedImage: UIImage?
    @Published var isImagePickerPresented = false
    @Published var finalCroppedImage: UIImage?
    
    var alertError: AlertError!
    
    
    var session: AVCaptureSession
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        self.session = service.session
        
        // Initialize crop rect (relative to screen) - Revert to original init
        
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let width = screenWidth * 0.8
        let height = screenHeight * 0.4 // Adjusted height to be more rectangular for problems
        let x = (screenWidth - width) / 2
        let y = (screenHeight - height) / 2 // Center vertically
        self.cropRect = CGRect(x: x, y: y, width: width, height: height)
        
        // Revert sink logic
        
        
        service.$photo.sink { [weak self] (photo) in
            guard let self = self, let pic = photo else { return }
            self.photo = pic
            // Process the *captured* photo (Original simpler logic)
            if let image = pic.image {
                self.selectedImage = image // Just set selectedImage
                // Original logic did NOT crop immediately after capture here
                // Cropping happened on button press if selectedImage was set
                // Let's keep it simple: set selectedImage, cropping happens on capture button press
            }
        }
        .store(in: &self.subscriptions)
        
        service.$shouldShowAlertView.sink { [weak self] (val) in
            self?.alertError = self?.service.alertError
            self?.showAlertError = val
        }
        .store(in: &self.subscriptions)
        
        service.$flashMode.sink { [weak self] (mode) in
            self?.isFlashOn = mode == .on
        }
        .store(in: &self.subscriptions)
        
        service.$willCapturePhoto.sink { [weak self] (val) in
            self?.willCapturePhoto = val
        }
        .store(in: &self.subscriptions)
    }
    
    func configure() {
        service.checkForPermissions()
        service.configure()
    }
    
    // Revert capturePhoto logic
    func capturePhoto() {
        // Reset final image before capture
        finalCroppedImage = nil
        service.capturePhoto()
    }
    
    func flipCamera() {
        selectedImage = nil
        finalCroppedImage = nil
        service.changeCamera()
    }
    
    func zoom(with factor: CGFloat) {
        service.set(zoom: factor)
    }
    
    func switchFlash() {
        service.flashMode = service.flashMode == .on ? .off : .on
    }
    
    // Revert updateCropRect
    func updateCropRect(_ rect: CGRect) {
        // Original simple update
        cropRect = rect
    }
    
    // --- REVERTED Cropping Logic ---
     func cropImageAndSetFinal(_ image: UIImage) {
         print("Attempting to crop image...")
         
         // 1. Calculate the scale factor between displayed image and actual image
         let viewBounds = UIScreen.main.bounds
         let imageSize = image.size
         let widthScale = viewBounds.width / imageSize.width
         let heightScale = viewBounds.height / imageSize.height
         let scale = min(widthScale, heightScale)
         
         // 2. Calculate the displayed image's position
         
         
         
         let displayedImageWidth = imageSize.width * scale
         let displayedImageHeight = imageSize.height * scale
         let offsetX = (viewBounds.width - displayedImageWidth) / 2.0
         let offsetY = (viewBounds.height - displayedImageHeight) / 2.0
         
         // 3. Convert screen coordinates to image coordinates
         
         
         
         let cropRelativeX = cropRect.minX - offsetX
         let cropRelativeY = cropRect.minY - offsetY
         
         // 4. Scale back to original image coordinates
         
         
         
         let finalScale = 1.0 / scale
         let finalCropX = cropRelativeX * finalScale
         let finalCropY = cropRelativeY * finalScale
         let finalCropWidth = cropRect.width * finalScale
         let finalCropHeight = cropRect.height * finalScale
         
         // 5. Create the final crop zone
         let cropZone = CGRect(
             x: finalCropX,
             y: finalCropY,
             width: finalCropWidth,
             height: finalCropHeight
         )
         
         // 6. Ensure the crop zone is valid within the image bounds
         let imageRect = CGRect(origin: .zero, size: imageSize)
         let validCropZone = cropZone.intersection(imageRect)
         
         guard validCropZone.width > 0 && validCropZone.height > 0 else {
             print("Error: Invalid crop zone calculated.")
             self.finalCroppedImage = image
             return
         }
         
         // 7. Perform the actual cropping
         guard let cgImage = image.cgImage?.cropping(to: validCropZone) else {
             print("Error: Failed to crop CGImage.")
             self.finalCroppedImage = image
             return
         }
         
         // 8. Create the final cropped image
         
         
         
         self.finalCroppedImage = UIImage(cgImage: cgImage)
         print("Image cropped successfully and stored in finalCroppedImage.")
     }
}

struct CameraView: View {
    @StateObject var model = CameraModel()
    @State var currentZoomFactor: CGFloat = 1.0
    // Restore imageFrame state
    @State private var imageFrame: CGRect = .zero
    @State private var showMathChat = false
    @Environment(\.presentationMode) var presentationMode
    
    // REMOVE Debouncer
    
    // Revert galleryButton action
    var galleryButton: some View {
        Button(action: {
            model.selectedImage = nil // Original logic might have only done this
            model.finalCroppedImage = nil // Keep this reset
            model.isImagePickerPresented = true
        }) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 45, height: 45)
                .background(Color.gray.opacity(0.2))
                .clipShape(Circle())
        }
    }
    
    // Revert captureButton action
    var captureButton: some View {
        Button(action: {
            if let imageToCrop = model.selectedImage {
                print("Capture button pressed with selected image. Cropping...")
                model.cropImageAndSetFinal(imageToCrop)
            } else {
                print("Capture button pressed in camera mode. Capturing photo...")
                model.capturePhoto()
            }
        }) {
            Circle()
                .foregroundColor(.white)
                .frame(width: 80, height: 80, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                        .frame(width: 65, height: 65, alignment: .center)
                )
        }
    }
    
    // Revert flipCameraButton action (was likely already correct)
    var flipCameraButton: some View {
        Button(action: {
            model.selectedImage = nil
            model.finalCroppedImage = nil
            model.flipCamera()
        }) {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(systemName: "camera.rotate.fill")
                        .foregroundColor(.white))
        }
    }
    
    // Revert cropOverlay implementation
    var cropOverlay: some View {
        ZStack {
            // Semi-transparent overlay using original mask approach
            Rectangle()
                .fill(Color.black.opacity(0.5))
                .mask(
                    Rectangle()
                        .overlay(
                            Rectangle()
                                .frame(width: model.cropRect.width, height: model.cropRect.height)
                                .position(x: model.cropRect.midX, y: model.cropRect.midY)
                                .blendMode(.destinationOut)
                        )
                )

            // Crop rectangle outline
            Rectangle()
                .stroke(Color.white, lineWidth: 1)
                .frame(width: model.cropRect.width, height: model.cropRect.height)
                .position(x: model.cropRect.midX, y: model.cropRect.midY)

            // Corner controls - Use the original CornerControl struct and gestures
            Group {
                CornerControl(color: .purple) // Top-Left
                    .position(x: model.cropRect.minX, y: model.cropRect.minY)
                    .gesture(DragGesture()
                        .onChanged { value in
                            let newX = min(model.cropRect.maxX - 100, value.location.x)
                            let newY = min(model.cropRect.maxY - 100, value.location.y)
                            let deltaW = model.cropRect.minX - newX
                            let deltaH = model.cropRect.minY - newY
                            model.updateCropRect(CGRect(
                                x: newX,
                                y: newY,
                                width: model.cropRect.width + deltaW,
                                height: model.cropRect.height + deltaH
                            ))
                        }
                    )

                CornerControl(color: .purple) // Top-Right
                    .position(x: model.cropRect.maxX, y: model.cropRect.minY)
                    .gesture(DragGesture()
                        .onChanged { value in
                            let newWidth = max(100, value.location.x - model.cropRect.minX)
                            let newY = min(model.cropRect.maxY - 100, value.location.y)
                            let deltaH = model.cropRect.minY - newY
                            model.updateCropRect(CGRect(
                                x: model.cropRect.minX,
                                y: newY,
                                width: newWidth,
                                height: model.cropRect.height + deltaH
                            ))
                        }
                    )

                CornerControl(color: .purple) // Bottom-Left
                    .position(x: model.cropRect.minX, y: model.cropRect.maxY)
                    .gesture(DragGesture()
                        .onChanged { value in
                            let newX = min(model.cropRect.maxX - 100, value.location.x)
                            let newHeight = max(100, value.location.y - model.cropRect.minY)
                            let deltaW = model.cropRect.minX - newX
                            model.updateCropRect(CGRect(
                                x: newX,
                                y: model.cropRect.minY,
                                width: model.cropRect.width + deltaW,
                                height: newHeight
                            ))
                        }
                    )

                CornerControl(color: .purple) // Bottom-Right
                    .position(x: model.cropRect.maxX, y: model.cropRect.maxY)
                    .gesture(DragGesture()
                        .onChanged { value in
                            let newWidth = max(100, value.location.x - model.cropRect.minX)
                            let newHeight = max(100, value.location.y - model.cropRect.minY)
                            model.updateCropRect(CGRect(
                                x: model.cropRect.minX,
                                y: model.cropRect.minY,
                                width: newWidth,
                                height: newHeight
                            ))
                        }
                    )
            }
             // .frame modifier might have been on Group or individual CornerControls before, adjust if needed
        }
        // Revert outer gesture for moving
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Simple move logic from previous state
                    let sensitivity: CGFloat = 0.3 // Or whatever was used
                    let translation = value.translation
                    let newX = model.cropRect.origin.x + (translation.width * sensitivity)
                    let newY = model.cropRect.origin.y + (translation.height * sensitivity)

                    // Simple bounds checking if it existed
                     let minX: CGFloat = 0
                     let minY: CGFloat = 0
                     let viewWidth = UIScreen.main.bounds.width
                     let viewHeight = UIScreen.main.bounds.height
                     let maxX = viewWidth - model.cropRect.width
                     let maxY = viewHeight - model.cropRect.height

                     let clampedX = max(minX, min(newX, maxX))
                     let clampedY = max(minY, min(newY, maxY))

                     // Update directly or with animation if used before
                    // Assuming direct update was used:
                     model.updateCropRect(CGRect(
                         x: clampedX,
                         y: clampedY,
                         width: model.cropRect.width,
                         height: model.cropRect.height
                     ))

//                    // Or with animation if used before:
//                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
//                        model.updateCropRect(CGRect(
//                            x: clampedX,
//                            y: clampedY,
//                            width: model.cropRect.width,
//                            height: model.cropRect.height
//                        ))
//                    }
                }
        )
    }
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Revert Top Controls layout
                    HStack {
                         if model.selectedImage == nil {
                             Button(action: { model.switchFlash() }) {
                                 Image(systemName: model.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                     .font(.system(size: 20, weight: .medium, design: .default))
                                     .frame(width: 44, height: 44)
                             }
                             .accentColor(model.isFlashOn ? .yellow : .white)
                         } else {
                             Spacer().frame(width: 44, height: 44)
                         }
                        
                         Spacer()
                         
                         // Add close button
                         Button(action: {
                             presentationMode.wrappedValue.dismiss()
                         }) {
                             Image(systemName: "xmark")
                                 .font(.system(size: 20, weight: .medium))
                                 .foregroundColor(.white)
                                 .frame(width: 44, height: 44)
                                 .background(Color.black.opacity(0.3))
                                 .clipShape(Circle())
                         }
                    }
                    .padding(.horizontal)
                    .padding(.top, reader.safeAreaInsets.top)
                    .frame(height: 50)

                    // Revert Main Content Area
                    ZStack {
                        if let imageToShow = model.selectedImage {
                            Image(uiImage: imageToShow)
                                .resizable()
                                .scaledToFit()
                        } else {
                            CameraPreview(session: model.session)
                                // Revert to DragGesture for zoom
                                .gesture(
                                     DragGesture().onChanged({ (val) in
                                         if abs(val.translation.height) > abs(val.translation.width) {
                                             let percentage: CGFloat = -(val.translation.height / reader.size.height)
                                             let calc = currentZoomFactor + percentage
                                             let zoomFactor: CGFloat = min(max(calc, 1), 5)
                                             currentZoomFactor = zoomFactor
                                             model.zoom(with: zoomFactor)
                                         }
                                     })
                                )
                                .onAppear { model.configure() } // Revert configure logic
                                .alert(isPresented: $model.showAlertError) {
                                    Alert(title: Text(model.alertError.title),
                                          message: Text(model.alertError.message),
                                          dismissButton: .default(Text(model.alertError.primaryButtonTitle)) {
                                        model.alertError.primaryAction?()
                                    })
                                }
                                .overlay(
                                    // Revert overlay logic
                                    Group { if model.willCapturePhoto { Color.black } }
                                )
                                .animation(.easeInOut) // Keep animation?
                        }

                        cropOverlay
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    // Remove .clipped()

                    // Revert Bottom Controls layout
                    HStack {
                        galleryButton
                        Spacer()
                        captureButton
                        Spacer()
                        if model.selectedImage == nil {
                            flipCameraButton
                        } else {
                            // Revert spacer logic
                            Spacer().frame(width: 45)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20) // Revert padding
                    .background(Color.black.opacity(0.5)) // Revert background
                }
                .edgesIgnoringSafeArea(.bottom) // Restore edgesIgnoringSafeArea
            }
             // Revert onChange logic if necessary, keep it simple
             .onChange(of: model.finalCroppedImage) { newImage in
                 if newImage != nil {
                      print("Final cropped image detected. Triggering navigation.")
                      showMathChat = true
                 }
             }
            .fullScreenCover(isPresented: $showMathChat) {
                 if let imageToSend = model.finalCroppedImage {
                      MathChatView(selectedImage: imageToSend)
                          .onDisappear {
                              model.finalCroppedImage = nil
                              model.selectedImage = nil
                          }
                 } else {
                     Text("Error: Could not prepare image for analysis.")
                         .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                showMathChat = false
                            }
                         }
                 }
             }
        }
        .sheet(isPresented: $model.isImagePickerPresented) {
             // Revert Image Picker presentation logic if changed
             ImagePicker(image: $model.selectedImage)
                // Remove onDisappear added in last step
        }
        .statusBarHidden(true)
    }
}

// Restore original CornerControl struct
struct CornerControl: View {
    let color: Color
    var body: some View {
        Rectangle()
            .fill(color)
             .frame(width: 20, height: 20) // Restore original size?
            .overlay(Rectangle().stroke(Color.white, lineWidth: 1))
             // Remove background hit area added last step
    }
}

// REMOVE Debouncer Class
// REMOVE HoleShapeMask struct

// Revert Image Picker implementation to original
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration() // Original simple config
        config.filter = .images
        config.selectionLimit = 1
        // Remove preferredAssetRepresentationMode
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            guard let provider = results.first?.itemProvider else { return } // Original guard

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in // Original completion handler
                    // Remove error handling added last step
                     DispatchQueue.main.async {
                         self.parent.image = image as? UIImage // Original assignment
                     }
                 }
            } // Remove else block added last step
        }
    }
}
