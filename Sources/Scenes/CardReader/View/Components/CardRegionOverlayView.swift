//
//  CardRegionOverlayView.swift
//  PokéScan
//
//  Created by João Guilherme on 02/12/25.
//

import SwiftUI

struct CardRegionOverlayView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 3)
                    .frame(width: geo.size.width * 0.50,
                           height: geo.size.height * 0.05)
                    .position(x: geo.size.width * 0.38,
                              y: geo.size.height * 0.07)
                
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 3)
                    .frame(width: geo.size.width * 0.15,
                           height: geo.size.height * 0.05)
                    .position(x: geo.size.width * 0.23,
                              y: geo.size.height * 0.93)
            }
        }
        .allowsHitTesting(false)
    }
}
