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

    private let output = AVCaptureVideoDataOutput()
    var onFrame: ((CVPixelBuffer) -> Void)?

    override init() {
        super.init()
        configure()
    }

    private func configure() {
        queue.async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .hd1280x720

            guard
                let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back),
                let input = try? AVCaptureDeviceInput(device: device),
                self.session.canAddInput(input)
            else {
                print("❌ Failed camera input")
                return
            }

            self.session.addInput(input)

            // Frame output
            if self.session.canAddOutput(self.output) {
                self.output.setSampleBufferDelegate(self, queue: self.queue)
                self.session.addOutput(self.output)
            }

            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        onFrame?(pixelBuffer)
    }
}
