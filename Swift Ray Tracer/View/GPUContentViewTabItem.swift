//
//  GPUContentViewTabItem.swift
//  Swift Ray Tracer
//
//  Created by Friedrich Stoltzfus on 4/26/23.
//

import SwiftUI

struct GPUContentViewTabItem: View {
    @EnvironmentObject var gamescene: GameScene
    @Binding var shouldRender: Bool
    
    var body: some View {
        GPUContentView(shouldRender: $shouldRender)
            .frame(width: 800, height: 600)
            .environmentObject(gamescene)
        Button(action: {
            shouldRender.toggle()
        }) {
            Text("Render using GPU")
        }
    }
}
