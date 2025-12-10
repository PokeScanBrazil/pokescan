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
        // Sempre configurar câmera no main thread
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            session.beginConfiguration()
            session.sessionPreset = .high     // melhor para OCR / foco

            // Seleciona camera traseira
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: .back) else { return }

            // Cria input
            guard let input = try? AVCaptureDeviceInput(device: device) else { return }
            if session.canAddInput(input) {
                session.addInput(input)
            }

            // Cria output
            let output = AVCaptureVideoDataOutput()
            output.alwaysDiscardsLateVideoFrames = true
            output.setSampleBufferDelegate(self, queue: queue)

            if session.canAddOutput(output) {
                session.addOutput(output)
            }

            session.commitConfiguration()

            // Start da sessão
            session.startRunning()

            // ⬇️ Autofocus só funciona depois da sessão estar rodando
            self.configureAutoFocusAfterSessionStart(device: device)
        }
    }


    /// ⬇️ Auto-foco só depois de iniciar a sessão
    private func configureAutoFocusAfterSessionStart(device: AVCaptureDevice) {
        // Pequeno delay para garantir que a câmera iniciou e está entregando frames
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            do {
                try device.lockForConfiguration()

                // Melhor modo para cartão / OCR
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    device.focusMode = .continuousAutoFocus
                }

                // Focar no centro
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
                }

                // Reset de restrições de profundidade
                if device.isAutoFocusRangeRestrictionSupported {
                    device.autoFocusRangeRestriction = .far
                }

                device.unlockForConfiguration()
                print("📸 Autofocus configurado!")
                
            } catch {
                print("❌ Erro ao configurar autofocus:", error)
            }
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
        
        //let roiName = CGRect(x: 0.23, y: 0.732, width: 0.37, height:0.04)
        let roiCollection = CGRect(x: 0.24, y: 0.327, width: 0.15, height: 0.04)
        
        
        textRequestCollection.regionOfInterest = roiCollection
        
        // Update published overlay positions
        DispatchQueue.main.async {
            let screenW = UIScreen.main.bounds.width
            let screenH = UIScreen.main.bounds.height
            
            self.roiNameRect = CGRect(x: screenW * 0.23, y: screenH * 0.25, width: screenW * 0.50, height: screenH * 0.05 )
            let normX = self.roiNameRect.minX / screenW
            let normW = self.roiNameRect.width / screenW
            let normH = self.roiNameRect.height / screenH

            // inverted Y (correct for Vision's bottom-left origin)
            let normY = 1 - (self.roiNameRect.minY / screenH) - normH
            // alternatively: let normY = (screenH - self.roiNameRect.maxY) / screenH

            self.textRequestName.regionOfInterest = CGRect(
                x: normX,
                y: normY,
                width: normW,
                height: normH
            )
            
            // Vision uses bottom-left origin → convert to SwiftUI top-left
            //            self.roiNameRect = CGRect(
            //                x: roiName.minX * screenW,
            //                y: (1 - roiName.maxY) * screenH,
            //                width: roiName.width * screenW,
            //                height: roiName.height * screenH
            //            )
            
            self.roiCollectionRect = CGRect(
                x: roiCollection.minX * screenW,
                y: (1 - roiCollection.maxY) * screenH,
                width: roiCollection.width * screenW,
                height: roiCollection.height * screenH
            )
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .right)
        
        do {
            try handler.perform([textRequestName])
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
