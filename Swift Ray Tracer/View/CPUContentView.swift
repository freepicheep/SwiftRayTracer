//
//  CPUContentView.swift
//  Swift Ray Tracer
//
//  Created by Friedrich Stoltzfus on 4/25/23.
//

import SwiftUI

struct CPUContentView: View {
    @EnvironmentObject var gamescene: GameScene
    @ObservedObject var renderedImageModel = RenderedImageModel()
    
    
    var body: some View {
        Button(action: createCPUExample) {
            Text("Ray Trace Using CPU")
        }
        if let image = renderedImageModel.image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        
    }
    
    func createCPUExample() {
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

        if let renderedImage = rayTracingCpu(imageWidth: imageWidth, imageHeight: imageHeight, sceneData: sceneData, spheres: gamescene.spheres) {
                renderedImageModel.image = renderedImage
            let endTime = CACurrentMediaTime()
            let duration = endTime - startTime
                print("CPU ray tracing took \(duration) seconds")
        } else {
            print("Error: Failed to render image.")
        }
    }
}
