//
//  CameraManager.swift
//  PokéScan
//
//  Created by João Guilherme on 02/12/25.
//

import SwiftUI
import AVFoundation
import Vision

final class CameraManager: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var roiNameRect: CGRect = .zero
    @Published var roiCollectionRect: CGRect = .zero
    private let queue = DispatchQueue(label: "camera.queue")
    
    
    var onCardNameDetected: ((String) -> Void)?
    var onCollectionDetected: ((String) -> Void)?
    
    private lazy var textRequestName: VNRecognizeTextRequest = {
        let req = VNRecognizeTextRequest(completionHandler: handleNameText)
        req.recognitionLevel = .accurate
        req.usesLanguageCorrection = true
        return req
    }()
    
    private lazy var textRequestCollection: VNRecognizeTextRequest = {
        let req = VNRecognizeTextRequest(completionHandler: handleCollectionText)
        req.recognitionLevel = .accurate
        req.usesLanguageCorrection = false
        return req
    }()
    
    override init() {
        super.init()
        configureCamera()
    }
    
    // MARK: - Camera Config
    private func configureCamera() {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back) else { return }
        
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: queue)
        
        if let connection = output.connection(with: .video) {
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .auto
            }
        }
                
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
        
        self.configureAutoFocusAfterSessionStart(device: device)
    }
    
    private func configureAutoFocusAfterSessionStart(device: AVCaptureDevice?) {
        guard let device = device else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Error configuring camera: \(error)")
        }
    }
    
    
    // MARK: - Text Handlers
    private func handleNameText(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        
        if let best = observations.first?.topCandidates(1).first {
            DispatchQueue.main.async {
                self.onCardNameDetected?(best.string)
            }
        }
    }
    
    private func handleCollectionText(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        
        if let best = observations.first?.topCandidates(1).first {
            DispatchQueue.main.async {
                self.onCollectionDetected?(best.string)
            }
        }
    }
    
    // MARK: - Frame Processing
    func processFrame(_ buffer: CVPixelBuffer) {
        
        // Normalized ROIs (0–1)
        
        // Update published overlay positions
        DispatchQueue.main.async {
            let screenW = UIScreen.main.bounds.width
            let screenH = UIScreen.main.bounds.height
            
            self.roiNameRect = CGRect(x: screenW * 0.23, y: screenH * 0.25, width: screenW * 0.50, height: screenH * 0.05 )
            let normXName = self.roiNameRect.minX / screenW
            let normWName = self.roiNameRect.width / screenW
            let normHName = self.roiNameRect.height / screenH
            
            // inverted Y (correct for Vision's bottom-left origin)
            let normYName = 1 - (self.roiNameRect.minY / screenH) - normHName
            // alternatively: let normY = (screenH - self.roiNameRect.maxY) / screenH
            
            self.textRequestName.regionOfInterest = CGRect(
                x: normXName,
                y: normYName,
                width: normWName,
                height: normHName
            )
            
            self.roiCollectionRect = CGRect(x: screenW * 0.23, y: screenH * 0.70, width: screenW * 0.15, height: screenH * 0.04 )
            let normXCollection = self.roiCollectionRect.minX / screenW
            let normWCollection = self.roiCollectionRect.width / screenW
            let normHCollection = self.roiCollectionRect.height / screenH
            
            // inverted Y (correct for Vision's bottom-left origin)
            let normYCollection = 1 - (self.roiCollectionRect.minY / screenH) - normHCollection
            // alternatively: let normY = (screenH - self.roiNameRect.maxY) / screenH
            
            self.textRequestCollection.regionOfInterest = CGRect(
                x: normXCollection,
                y: normYCollection,
                width: normWCollection,
                height: normHCollection
            )
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .right)
        
        do {
            try handler.perform([textRequestName, textRequestCollection])
        } catch {
            print("❌ Vision error:", error)
        }
    }
    
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        processFrame(buffer)
    }
}
