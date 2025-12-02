//
//  Image.swift
//  PokéScan
//
//  Created by João Guilherme on 26/11/25.
//

import SwiftUI

extension Image {
    static func fromURL(_ urlString: String,
                        placeholder: Image = Image(systemName: "photo")) -> some View {
        RemoteImage(url: urlString, placeholder: placeholder)
    }
}

struct RemoteImage: View {
    let url: String
    let placeholder: Image

    @State private var downloaded: UIImage?

    var body: some View {
        Group {
            if let image = downloaded {
                Image(uiImage: image)
                    .resizable()
            } else {
                placeholder
                    .resizable()
                    .onAppear {
                        downloadImage()
                    }
            }
        }
    }

    private func downloadImage() {
        guard let url = URL(string: url) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data, let img = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.downloaded = img
                }
            }
        }.resume()
    }
}
