//
//  CardReaderView.swift
//  PokéScan
//
//  Created by João Guilherme on 26/11/25.
//

import SwiftUI
import AVFoundation

struct CardReaderView: View {
    @StateObject private var viewModel = CardReaderViewModel()
    @StateObject private var camera = CameraManager()
    
    var body: some View {
        
        ZStack {
            CameraPreviewView(manager: camera)
                .ignoresSafeArea()
            
            CardRegionOverlayView()
                .cornerRadius(8)
                .border(Color.gray, width: 3)
                .padding(.horizontal, 60)
                .padding(.vertical, 200)
            
            VStack {
                Spacer()
                Text(viewModel.detectedText)
                    .font(.title2)
                    .padding()
                    .background(.black.opacity(0.6))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.bottom, 40)
            }
        }.onAppear {
            camera.onFrame = { buffer in
                viewModel.handleFrame(buffer)
            }
        }
    }
}

#Preview {
    CardReaderView()
}
