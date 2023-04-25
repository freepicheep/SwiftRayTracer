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
    
    let startTime = CACurrentMediaTime()
    
    func makeCoordinator() -> Renderer {
        Renderer(self, gamescene: gamescene)
    }
    
    func makeUIView(context: UIViewRepresentableContext<GPUContentView>) -> MTKView {
        
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        mtkView.isPaused = false
        mtkView.depthStencilPixelFormat = .depth32Float
        
        //debug
//        let duration = endTime - startTime
//        print("GPU ray tracing took \(duration) seconds")
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<GPUContentView>) {
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GPUContentView()
    }
}
