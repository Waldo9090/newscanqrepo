//
//  CameraService+Enums.swift
//  SwiftCamera
//
//  Created by Rolando Rodriguez on 10/15/20.
//

import Foundation

//  MARK: CameraService Enums


extension CameraService {
    
    
    enum LivePhotoMode {
        
        
        case on
        case off
        
        
    }
    
    enum DepthDataDeliveryMode {
        case on
        case off
    }
    
    enum PortraitEffectsMatteDeliveryMode {
        case on
        case off
    }
    
    enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    enum CaptureMode: Int {
        case photo = 0
        case movie = 1


    }
}
