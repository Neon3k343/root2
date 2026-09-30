//
//  File.swift
//  root2
//
//  Created by Hubert  Greszta on 30/09/2026.
//

import Foundation
import Observation
import AVFoundation

@Observable

final class CameraManager {
    let session = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: "root2.sessionQueue")
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Camera: Already authorized")
            setupSession()
        case .notDetermined:
            print("Camera: Not determined, requesting...")
            AVCaptureDevice.requestAccess(for: .video) { granted in
                print("Camera: User answered prompt, granted =", granted)
                if granted {
                    self.setupSession()
                }
            }
        case .denied, .restricted:
            print("Camera: Access denied or restricted")
        @unknown default:
            break
        }
    }
    
    func setupSession() {
        
    }
    
    init() {
        checkPermissions()
    }
}

