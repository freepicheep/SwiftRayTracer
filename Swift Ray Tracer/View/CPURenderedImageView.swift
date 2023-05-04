//
//  CPURenderedImageView.swift
//  Swift Ray Tracer
//
//  Created by Friedrich Stoltzfus on 4/26/23.
//

import SwiftUI

struct RenderedImageView: View {
    @ObservedObject var renderedImageModel: RenderedImageModel

    var body: some View {
        if let image = renderedImageModel.image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 800, height: 600)
        }
    }
}
