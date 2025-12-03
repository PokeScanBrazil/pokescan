//
//  CameraManager.swift
//  PokéScan
//
//  Created by João Guilherme on 02/12/25.
//

import AVFoundation

final class CameraManager: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    private let queue = DispatchQueue(label: "camera.queue")

    override init() {
        super.init()
        configure()
    }
    
    private func configure() {
        queue.async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input)
            else {
                print("❌ Failed to setup camera input")
                return
            }

            self.session.addInput(input)

            let output = AVCaptureVideoDataOutput()
            if self.session.canAddOutput(output) {
                self.session.addOutput(output)
            }

            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }
}

