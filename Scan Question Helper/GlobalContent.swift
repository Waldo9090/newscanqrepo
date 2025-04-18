import Foundation
import UIKit  // Needed for UIDevice
import SwiftUI // Needed for ObservableObject

class GlobalContent: ObservableObject {
    static let shared = GlobalContent() // Optional: Singleton for easy access
    
    // Stores the device's unique identifier (or a fallback if nil)
    @Published var deviceId: String
    
    // Other global properties can be added here
    // @Published var someOtherSetting: String = "Default"

    private init() {
        // Get the ID on initialization
        if let id = UIDevice.current.identifierForVendor?.uuidString {
            self.deviceId = id
            print("Device ID Initialized: \(id)") // Log for debugging
        } else {
            // Fallback - should ideally not happen on physical devices
            let fallbackId = "unknown-\(UUID().uuidString)"
            self.deviceId = fallbackId
            print("Warning: Could not get identifierForVendor. Using fallback: \(fallbackId)")
        }
    }
} 