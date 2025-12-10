//
//  ScanningOverlayView.swift
//  PokéScan
//
//  Created by João Guilherme on 03/12/25.
//
import SwiftUI

struct ScanningOverlay: View {
    let rect: CGRect
    var color: Color = .cyan
    @State private var animateBeam = false
    
    var body: some View {
        ZStack {
            // Neon Border
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.9), lineWidth: 3)
                .shadow(color: color, radius: 12)
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)
            
            // Animated Scan Beam
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.35))
                .frame(width: rect.width * 0.9, height: 4)
                .position(
                    x: rect.midX,
                    y: rect.minY + (animateBeam ? rect.height - 10 : 10)
                )
                .onAppear {
                    withAnimation(.linear(duration: 1.3).repeatForever(autoreverses: false)) {
                        animateBeam.toggle()
                    }
                }
        }
    }
}
