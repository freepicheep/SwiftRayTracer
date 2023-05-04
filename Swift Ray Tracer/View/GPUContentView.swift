//
//  ContentView.swift
//  HelloTriangle
//
//  Created by Andrew Mengede on 27/2/2022.
//

import SwiftUI
import MetalKit

struct GPUContentView: UIViewRepresentable {
    
    @EnvironmentObject var gamescene: GameScene
    @Binding var shouldRender: Bool
    
    func makeCoordinator() -> Renderer {
        Renderer(self, gamescene: gamescene, shouldRender: shouldRender)
    }
    
    func makeUIView(context: UIViewRepresentableContext<GPUContentView>) -> MTKView {
        
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 1
        mtkView.enableSetNeedsDisplay = true
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        mtkView.isPaused = false
        mtkView.depthStencilPixelFormat = .depth32Float
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<GPUContentView>) {
    }
}
