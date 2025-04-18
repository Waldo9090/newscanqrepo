import SwiftUI
import AVFoundation
import Photos
import UIKit

// Add Identifiable conformance to UIImage (or use a wrapper struct)
extension UIImage: Identifiable {
    public var id: String { UUID().uuidString }
}

// MARK: - Custom Camera Picker
struct CustomCameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed.
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CustomCameraPicker
        
        init(parent: CustomCameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Custom Photo Library Picker
struct CustomPhotoLibraryPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType  // Typically .photoLibrary

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed.
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CustomPhotoLibraryPicker
        
        init(parent: CustomPhotoLibraryPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Main ScanView Using Custom Pickers
struct ScanView: View {
    @State private var selectedImage: UIImage?
    @State private var showCameraPicker = false
    @State private var showPhotoLibraryPicker = false
    @State private var showCropView = false
    @State private var finalCroppedImage: UIImage?
    @State private var navigateToMathChat = false

    @Environment(\.dismiss) private var dismiss

    private var placeholderImage: UIImage {
        UIImage(named: "MathPlaceholder") ?? UIImage()
    }
    
    private func generateHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                // Close button
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
                
                VStack(spacing: 16) {
                    Text("Scan Problem")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.top, 50)
                        .multilineTextAlignment(.center)
                    
                    Text("Use the camera to capture your problems")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                    
                    // Button for taking a picture using the camera.
                    Button(action: {
                        showCameraPicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                                .font(.title2)
                            Text("Take Picture")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    
                    // Button for uploading a picture from the photo library.
                    Button(action: {
                        showPhotoLibraryPicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                            Text("Upload Picture")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    
                    // Extra spacer or padding to ensure content sits above the TabBar.
                    Spacer(minLength: 0)
                        .frame(height: 80)
                }
                // --- NavigationLink to MathChatView after cropping ---
                NavigationLink(
                    destination: finalCroppedImage.map { MathChatView(selectedImage: $0) },
                    isActive: $navigateToMathChat
                ) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
            .preferredColorScheme(.dark)
            // Present the Custom Camera Picker
            .sheet(isPresented: $showCameraPicker) {
                CustomCameraPicker(image: $selectedImage, sourceType: .camera)
            }
            // Present the Custom Photo Library Picker
            .sheet(isPresented: $showPhotoLibraryPicker) {
                CustomPhotoLibraryPicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            // Present the ImageCropView when an image is selected
            .fullScreenCover(isPresented: $showCropView) {
                if let image = selectedImage {
                    ImageCropView(image: image) { croppedImage in
                        self.finalCroppedImage = croppedImage
                        self.navigateToMathChat = true
                    }
                }
            }
            .onChange(of: selectedImage) { newImage in
                if newImage != nil {
                    generateHapticFeedback()
                    showCropView = true
                }
            }
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
            .preferredColorScheme(.dark)
    }
}

// Camera preview view
struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        previewLayer.frame = uiView.frame
    }
}

// Camera controller
class CameraController: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var completionHandler: ((UIImage?) -> Void)?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func checkPermissions() {
        // Check camera permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        case .restricted, .denied:
            break
        case .authorized:
            setupCamera()
        @unknown default:
            break
        }
        
        // Check photo library permission
        PHPhotoLibrary.requestAuthorization { status in
            // Handle photo library permission
        }
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        session.beginConfiguration()
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCapturePhotoOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            self.photoOutput = output
        }
        
        session.commitConfiguration()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        
        DispatchQueue.main.async {
            self.previewLayer = previewLayer
            self.captureSession = session
            session.startRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard let photoOutput = self.photoOutput else {
            completion(nil)
            return
        }
        
        self.completionHandler = completion
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("Error capturing photo: \(error)")
                self.completionHandler?(nil)
                return
            }
            
            guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) else {
                self.completionHandler?(nil)
                return
            }
            
            self.completionHandler?(image)
        }
    }
} 
