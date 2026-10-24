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
    
    private let sessionQueue = DispatchQueue(label: "root2.sessionQueue")
    private var isConfigured = false
    let session = AVCaptureSession()
    private var camera: AVCaptureDevice?

    func setExposureBias(_ bias: Float) {
        sessionQueue.async {
            guard let camera = self.camera else { return }

            do {
                try camera.lockForConfiguration()
                defer { camera.unlockForConfiguration() }

                let clampedBias = min(
                    max(bias, camera.minExposureTargetBias),
                    camera.maxExposureTargetBias
                )

                camera.setExposureTargetBias(clampedBias, completionHandler: nil)
            } catch {
                print("Failed to set exposure bias:", error)
            }
        }
    }
    
    func triggerShutter() {
        
    }
    
    func setupSession() {
        self.camera = camera
        
        sessionQueue.async {
            guard !self.isConfigured else { return }
            self.isConfigured = true
            
            self.session.beginConfiguration()
            
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("No back wide angle camera found")
                self.session.commitConfiguration()
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                } else {
                    print("Cannot add camera input")
                }
            } catch {
                print("Failed to create camera input:", error)
            }
            
            self.session.commitConfiguration()
            self.session.startRunning()
            print("Session configured and running")
        }
    }
    
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
    
    init() {
        checkPermissions()
        setupSession()
    }
}

