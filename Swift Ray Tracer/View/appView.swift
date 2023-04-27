//
//  appView.swift
//  Transformations
//
//  Created by Andrew Mengede on 2/3/2022.
//

import SwiftUI

struct appView: View {
    
    @EnvironmentObject var gamescene: GameScene
    @State var shouldRender: Bool = false
    
    var body: some View {
        TabView {
            CPUContentView()
                .environmentObject(gamescene)
                .tabItem {
                    VStack {
                        Image(systemName: "cpu")
                        Text("CPU Rendered")
                    }
                }
                .tag(0)
            
            GPUContentViewContainer(shouldRender: $shouldRender)
                .environmentObject(gamescene)
                .tabItem {
                    VStack {
                        Image(systemName: "power")
                        Text("GPU Rendered")
                    }
                }
                .tag(1)
        }
    }
}
