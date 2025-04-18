import SwiftUI

struct ImageCropView: View {
    let image: UIImage
    let onComplete: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var cropRect: CGRect
    @State private var imageSize: CGSize = .zero
    @State private var imageFrame: CGRect = .zero
    @State private var isDragging = false
    
    // Define Neon Purple Color
    let neonPurple = Color(red: 0.6, green: 0.0, blue: 1.0)
    // Reduce sensitivity for smoother dragging
    let dragSensitivityFactor: CGFloat = 0.25 // Reduced from 0.4
    
    init(image: UIImage, onComplete: @escaping (UIImage) -> Void) {
        self.image = image
        self.onComplete = onComplete
        // Start with a centered rectangle crop frame
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let width = screenWidth * 0.8
        let height = screenHeight * 0.4
        let x = (screenWidth - width) / 2
        let y = (screenHeight - height) / 2
        _cropRect = State(initialValue: CGRect(x: x, y: y, width: width, height: height))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                // --- Image View (stays in background) ---
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(GeometryReader { imageGeometry in
                        Color.clear.onAppear {
                            imageSize = imageGeometry.size
                            imageFrame = imageGeometry.frame(in: .global)
                        }
                    })
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // --- Crop Frame Overlay and Text (remain in ZStack) ---
                ZStack {
                    // Semi-transparent overlay
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .mask(
                            Rectangle()
                                .overlay(
                                    Rectangle()
                                        .frame(width: cropRect.width, height: cropRect.height)
                                        .position(x: cropRect.midX, y: cropRect.midY)
                                        .blendMode(.destinationOut)
                                )
                        )
                    
                    // Crop rectangle outline
                    Rectangle()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: cropRect.width, height: cropRect.height)
                        .position(x: cropRect.midX, y: cropRect.midY)
                    
                    // --- Text Label Positioned Above Crop Rect ---
                    Text("Crop only one problem")
                        .font(.headline)
                        .foregroundColor(neonPurple)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(5)
                        .position(x: cropRect.midX, y: cropRect.minY - 25)
                    
                    // Corner controls
                    Group {
                        // Top Left
                        CornerControl(color: neonPurple)
                            .position(x: cropRect.minX, y: cropRect.minY)
                            .gesture(DragGesture()
                                .onChanged { value in
                                    let newX = min(cropRect.maxX - 100, value.location.x)
                                    let newY = min(cropRect.maxY - 100, value.location.y)
                                    let deltaW = cropRect.minX - newX
                                    let deltaH = cropRect.minY - newY
                                    cropRect = CGRect(
                                        x: newX,
                                        y: newY,
                                        width: cropRect.width + deltaW,
                                        height: cropRect.height + deltaH
                                    )
                                }
                            )
                        
                        // Top Right
                        CornerControl(color: neonPurple)
                            .position(x: cropRect.maxX, y: cropRect.minY)
                            .gesture(DragGesture()
                                .onChanged { value in
                                    let newWidth = max(100, value.location.x - cropRect.minX)
                                    let newY = min(cropRect.maxY - 100, value.location.y)
                                    let deltaH = cropRect.minY - newY
                                    cropRect = CGRect(
                                        x: cropRect.minX,
                                        y: newY,
                                        width: newWidth,
                                        height: cropRect.height + deltaH
                                    )
                                }
                            )
                        
                        // Bottom Left
                        CornerControl(color: neonPurple)
                            .position(x: cropRect.minX, y: cropRect.maxY)
                            .gesture(DragGesture()
                                .onChanged { value in
                                    let newX = min(cropRect.maxX - 100, value.location.x)
                                    let newHeight = max(100, value.location.y - cropRect.minY)
                                    let deltaW = cropRect.minX - newX
                                    cropRect = CGRect(
                                        x: newX,
                                        y: cropRect.minY,
                                        width: cropRect.width + deltaW,
                                        height: newHeight
                                    )
                                }
                            )
                        
                        // Bottom Right
                        CornerControl(color: neonPurple)
                            .position(x: cropRect.maxX, y: cropRect.maxY)
                            .gesture(DragGesture()
                                .onChanged { value in
                                    let newWidth = max(100, value.location.x - cropRect.minX)
                                    let newHeight = max(100, value.location.y - cropRect.minY)
                                    cropRect = CGRect(
                                        x: cropRect.minX,
                                        y: cropRect.minY,
                                        width: newWidth,
                                        height: newHeight
                                    )
                                }
                            )
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if !isDragging {
                                if cropRect.contains(value.startLocation) {
                                    isDragging = true
                                }
                            } else {
                                // Apply reduced sensitivity factor
                                let adjustedTranslationX = value.translation.width * dragSensitivityFactor
                                let adjustedTranslationY = value.translation.height * dragSensitivityFactor
                                
                                let potentialX = cropRect.origin.x + adjustedTranslationX
                                let potentialY = cropRect.origin.y + adjustedTranslationY
                                
                                // Boundary checks with smoother movement
                                let clampedX = max(0, min(potentialX, geometry.size.width - cropRect.width))
                                let clampedY = max(0, min(potentialY, geometry.size.height - cropRect.height))
                                
                                withAnimation(.interactiveSpring()) {
                                    cropRect.origin.x = clampedX
                                    cropRect.origin.y = clampedY
                                }
                            }
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                )
                
                // --- Bottom Controls Overlay ---
                VStack {
                    Spacer()
                    HStack(spacing: 40) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            if let cropped = cropImage() {
                                onComplete(cropped)
                                dismiss()
                            }
                        }) {
                            Image(systemName: "checkmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.purple)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }
    
    private func cropImage() -> UIImage? {
        guard imageFrame.width > 0, imageFrame.height > 0 else { return nil }

        // 1. Calculate the actual scale factor used by .fit
        let viewWidth = imageFrame.width
        let viewHeight = imageFrame.height
        let imageWidth = image.size.width
        let imageHeight = image.size.height

        let widthScale = viewWidth / imageWidth
        let heightScale = viewHeight / imageHeight
        let scale = min(widthScale, heightScale) // The scale used by .fit
        
        // 2. Calculate the size of the image as displayed on screen
        let displayedImageWidth = imageWidth * scale
        let displayedImageHeight = imageHeight * scale

        // 3. Calculate the offset of the displayed image within the view frame (due to letterboxing/pillarboxing)
        let offsetX = (viewWidth - displayedImageWidth) / 2.0
        let offsetY = (viewHeight - displayedImageHeight) / 2.0

        // 4. Calculate the top-left corner of the *actual* displayed image in global coordinates
        let displayedImageMinX = imageFrame.minX + offsetX
        let displayedImageMinY = imageFrame.minY + offsetY

        // 5. Convert cropRect coordinates to be relative to the displayed image
        let cropRelativeX = cropRect.minX - displayedImageMinX
        let cropRelativeY = cropRect.minY - displayedImageMinY
        
        // Clamp relative coordinates to be within the displayed image bounds
        let clampedCropRelativeX = max(0, cropRelativeX)
        let clampedCropRelativeY = max(0, cropRelativeY)
        let clampedCropRelativeWidth = min(cropRect.width, displayedImageWidth - clampedCropRelativeX)
        let clampedCropRelativeHeight = min(cropRect.height, displayedImageHeight - clampedCropRelativeY)

        // 6. Scale the relative coordinates back to the original image's pixel coordinates
        let finalScale = 1.0 / scale // Scale from display coords back to original image coords
        let finalCropX = clampedCropRelativeX * finalScale
        let finalCropY = clampedCropRelativeY * finalScale
        let finalCropWidth = clampedCropRelativeWidth * finalScale
        let finalCropHeight = clampedCropRelativeHeight * finalScale

        // Create the final crop zone in the original image's coordinate system
        let cropZone = CGRect(
            x: finalCropX,
            y: finalCropY,
            width: finalCropWidth,
            height: finalCropHeight
        )

        // Ensure the crop zone is valid within the original image dimensions
        let validCropZone = cropZone.intersection(CGRect(origin: .zero, size: image.size))
        
        guard validCropZone.width > 0, validCropZone.height > 0 else {
            print("Invalid crop zone calculated.")
            return nil
        }

        // Perform the actual cropping
        guard let cgImage = image.cgImage?.cropping(to: validCropZone) else {
            print("Failed to crop CGImage.")
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}
