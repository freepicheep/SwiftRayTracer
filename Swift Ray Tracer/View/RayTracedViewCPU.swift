import SwiftUI

struct RayTracedImageView: View {
    @ObservedObject var gameScene: GameScene
    let width: Int
    let height: Int
    
    @State private var image: UIImage?
    @State private var rayTracer: RayTracer?
    
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                VStack {
                    Text("Rendering...")
                    if let progress = rayTracer?.progress {
                        ProgressView(value: progress)
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                let rt = RayTracer(gameScene: gameScene, width: width, height: height)
                DispatchQueue.main.async {
                    rayTracer = rt
                }
                rt.render()
                
                DispatchQueue.main.async {
                    image = rt.image
                }
            }
        }
    }
}
