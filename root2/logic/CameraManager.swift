//
//  CameraManager.swift
//  root2
//
//  Created by Hubert  Greszta on 30/09/2026.
//

import Foundation
import Observation
import AVFoundation

struct Lens: Identifiable, Hashable {
    var id: Int { focalLength }
    let focalLength: Int      // 35mm-equivalent, also the label
    let zoomFactor: CGFloat
    let isOptical: Bool
}

@Observable
final class CameraManager: NSObject {

    private let sessionQueue = DispatchQueue(label: "root2.sessionQueue")
    @ObservationIgnored private var isConfigured = false
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    @ObservationIgnored private var camera: AVCaptureDevice?

    private(set) var lenses: [Lens] = []                       // new
    private let customFocalLengths = [35, 48, 72]              // new

    func setExposureBias(_ bias: Float) {
        sessionQueue.async {
            guard let device = self.camera else { return }

            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }

                let clampedBias = min(
                    max(bias, device.minExposureTargetBias),
                    device.maxExposureTargetBias
                )

                device.setExposureTargetBias(clampedBias, completionHandler: nil)
            } catch {
                print("Failed to set exposure bias:", error)
            }
        }
    }
    
    func triggerShutter() {
        sessionQueue.async {
            print("triggerShutter called - session isRunning:", self.session.isRunning)
            guard self.session.isRunning else {
                print("Session is NOT running on this manager instance")
                return
            }
            let settings = AVCapturePhotoSettings()
            settings.maxPhotoDimensions = self.photoOutput.maxPhotoDimensions
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func select(_ lens: Lens, duration: Double = 0.005) {
        sessionQueue.async {
            guard let camera = self.camera else { return }
            do {
                try camera.lockForConfiguration()
                defer { camera.unlockForConfiguration() }

                if camera.isRampingVideoZoom { camera.cancelVideoZoomRamp() }

                let current = camera.videoZoomFactor
                let target = lens.zoomFactor
                guard abs(target - current) > 0.001 else { return }

                // ramp rate is in doublings per second, so derive it from the duration you want
                let doublings = abs(log2(Double(target / current)))
                let rate = Float(doublings / duration)

                camera.ramp(toVideoZoomFactor: target, withRate: rate)
            } catch {
                print("Failed to lock for zoom:", error)
            }
        }
    }
    
    private func makeLenses(for device: AVCaptureDevice) -> [Lens] {
        // constituentDevices is ordered widest → longest, matching `zooms`
        let cams = device.constituentDevices.isEmpty ? [device] : device.constituentDevices
        let zooms = [1.0] + device.virtualDeviceSwitchOverVideoZoomFactors.map { CGFloat(truncating: $0) }

        func equivalentMM(of cam: AVCaptureDevice) -> Double {
            let fov = Double(cam.activeFormat.videoFieldOfView) * .pi / 180
            return 17.3 / tan(fov / 2)
        }

        let known = [13, 15, 24, 26, 28, 52, 65, 77, 120]   // Apple's marketed values
        func snap(_ mm: Double) -> Int {
            let best = known.min { abs(Double($0) - mm) < abs(Double($1) - mm) }!
            return abs(Double(best) - mm) / mm < 0.1 ? best : Int(mm.rounded())
        }

        let optical = zip(cams, zooms).map { cam, zoom in
            let mm = equivalentMM(of: cam)
            print("Lens at \(zoom)x measures", mm)
            return Lens(focalLength: snap(mm), zoomFactor: zoom, isOptical: true)
        }

        // Custom lenses are crops from the nearest optical lens at or below the target
        let crops = customFocalLengths.compactMap { target -> Lens? in
            guard !optical.contains(where: { $0.focalLength == target }),
                  let base = optical.last(where: { $0.focalLength <= target }) else { return nil }
            let zoom = base.zoomFactor * CGFloat(target) / CGFloat(base.focalLength)
            guard zoom <= device.maxAvailableVideoZoomFactor else { return nil }
            return Lens(focalLength: target, zoomFactor: zoom, isOptical: false)
        }

        return (optical + crops).sorted { $0.focalLength < $1.focalLength }
    }
    
    func setupSession() {
        sessionQueue.async {
            guard !self.isConfigured else { return }
            self.isConfigured = true

            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            let deviceType: AVCaptureDevice.DeviceType
            if AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) != nil {
                deviceType = .builtInTripleCamera
            } else {
                deviceType = .builtInWideAngleCamera
            }

            guard let device = AVCaptureDevice.default(deviceType, for: .video, position: .back) else {
                print("No camera device found")
                self.session.commitConfiguration()
                return
            }
            
            self.camera = device
            let built = self.makeLenses(for: device)
            DispatchQueue.main.async { self.lenses = built }
            print("Virtual switchover factors:", device.virtualDeviceSwitchOverVideoZoomFactors)
            print("Min zoom:", device.minAvailableVideoZoomFactor)
            print("Max zoom:", device.maxAvailableVideoZoomFactor)

            func select(_ lens: Lens) {
                self.sessionQueue.async {
                    guard let camera = self.camera else { return }
                    do {
                        try camera.lockForConfiguration()
                        defer { camera.unlockForConfiguration() }
                        camera.videoZoomFactor = lens.zoomFactor
                    } catch { print("Failed to lock for zoom:", error) }
                }
            }

            do {
                let input = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                } else {
                    print("Cannot add camera input")
                }
            } catch {
                print("Failed to create camera input:", error)
            }

            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                
                if let camera = self.camera {
                    
                    let supportedDimensions = camera.activeFormat.supportedMaxPhotoDimensions
                    if let maxDim = supportedDimensions.max(by: { $0.width * $0.height < $1.width * $1.height }) {
                        self.photoOutput.maxPhotoDimensions = maxDim
                        print("Configured max photo dimensions:", maxDim.width, "x", maxDim.height)
                    }
                }
            } else {
                print("Cannot add photo output")
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
    
    override init() {
        super.init()
        checkPermissions()
    }
}


    
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: (any Error)?
    ) {
        if let error {
            print("Photo capture error:", error)
            return
        }
        guard let data = photo.fileDataRepresentation() else {
            print("Failed to get photo data representation")
            return
        }
        
        ImageProcessor.processAndSave(data: data)
        print("Photo data byte count:", data.count)
        print("Captured photo buffer:", photo)
    }
        
}


