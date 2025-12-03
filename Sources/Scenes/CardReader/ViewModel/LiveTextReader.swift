//
//  OCR.swift
//  PokéScan
//
//  Created by João Guilherme on 02/12/25.
//

import Vision

final class LiveTextReader {
    func detectText(pixelBuffer: CVPixelBuffer, completion: @escaping ([String]) -> Void) {
        let request = VNRecognizeTextRequest { request, error in
            guard let results = request.results as? [VNRecognizedTextObservation] else {
                completion([])
                return
            }
            
            let strings = results.compactMap { $0.topCandidates(1).first?.string }
            completion(strings)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        try? handler.perform([request])
    }
}

