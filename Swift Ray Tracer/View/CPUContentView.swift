//
//  CPUContentView.swift
//  Swift Ray Tracer
//
//  Created by Friedrich Stoltzfus on 4/25/23.
//

import SwiftUI

struct CPUContentView: View {
    @EnvironmentObject var gamescene: GameScene
    @StateObject private var renderedImageModel = RenderedImageModel()
    @State private var shouldRender: Bool = false
    
    var body: some View {
        VStack {
            if !shouldRender {
                Button(action: {
                    shouldRender.toggle()
                    callCPURayTracer()
                    
                }) {
                    Text("Ray Trace Using CPU!")
                }
            }
            RenderedImageView(renderedImageModel: renderedImageModel)
                .id(renderedImageModel.image) // Add this line
        }
    }
    
    func callCPURayTracer() {
        DispatchQueue.global(qos: .userInitiated).async {
            let startTime = CACurrentMediaTime()
            let sceneData = SceneData(
                cameraPos: gamescene.camera.position,
                sphereCount: gamescene.spheres.count,
                maxBounces: gamescene.maxBounces,
                cameraForwards: gamescene.camera.forwards,
                cameraRight: gamescene.camera.right,
                cameraUp: gamescene.camera.up
            )
            
            let imageWidth = 800
            let imageHeight = 600
            
            let pixelData = UnsafeMutablePointer<simd_float3>.allocate(capacity: imageWidth * imageHeight)
            
            if let finalImage = rayTracingCPU(imageWidth: imageWidth, imageHeight: imageHeight, sceneData: sceneData, spheres: gamescene.spheres, completionHandler: { updatedImage in
                DispatchQueue.main.async {
                    renderedImageModel.image = updatedImage
                }
            }) {
                DispatchQueue.main.async {
                    renderedImageModel.image = finalImage
                }
            }
            
            let endTime = CACurrentMediaTime()
            let duration = endTime - startTime
            print("CPU ray tracing took \(duration) seconds")
            
            pixelData.deallocate()
        }
    }
}
