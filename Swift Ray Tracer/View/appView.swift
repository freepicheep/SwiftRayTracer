//
//  appView.swift
//  Transformations
//
//  Created by Andrew Mengede on 2/3/2022.
//

import SwiftUI
import Foundation

/*
 game scene will be automatically forwarded here...
 */
struct appView: View {
    
    @EnvironmentObject var gamescene: GameScene
    @ObservedObject var renderedImageModel = RenderedImageModel()
    
    var body: some View {
        VStack{
            Button(action: createCPUExample) {
                Text("Save CPU Image")
            }
            .padding()
            .buttonStyle(.borderedProminent)
            
            if let image = renderedImageModel.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        
//            ContentView()
//                .frame(width: 800, height: 600)
            
        }
    }
    
    func createCPUExample() {
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

        if let renderedImage = ray_tracing_cpu(imageWidth: imageWidth, imageHeight: imageHeight, sceneData: sceneData, spheres: gamescene.spheres) {
                renderedImageModel.image = renderedImage
        } else {
            print("Error: Failed to render image.")
        }
    }
}

/*
 ...but must be manually forwarded if a preview is requested
 */
struct appView_Previews: PreviewProvider {
    static var previews: some View {
        appView().environmentObject(GameScene())
    }
}
