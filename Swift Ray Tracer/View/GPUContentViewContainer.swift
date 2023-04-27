//
//  GPUContentViewContainer.swift
//  Swift Ray Tracer
//
//  Created by Friedrich Stoltzfus on 4/26/23.
//

import SwiftUI

struct GPUContentViewContainer: View {
    @EnvironmentObject var gamescene: GameScene
    @Binding var shouldRender: Bool
    
    var body: some View {
        if shouldRender {
            GPUContentView(shouldRender: $shouldRender)
                .environmentObject(gamescene)
                .frame(width: 800, height: 600)
        } else {
            Button(action: {
                shouldRender.toggle()
            }) {
                Text("Ray Trace Using GPU!")
            }
        }
    }
}
