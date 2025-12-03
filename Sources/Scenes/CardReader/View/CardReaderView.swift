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
            VStack {
                Spacer()
                Text("Camera Preview")
                    .font(.title2)
                    .padding()
                    .background(.black.opacity(0.6))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    CardReaderView()
}
