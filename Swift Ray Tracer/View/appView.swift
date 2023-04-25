//
//  appView.swift
//  Transformations
//
//  Created by Andrew Mengede on 2/3/2022.
//

import SwiftUI

struct appView: View {
    
    @EnvironmentObject var gamescene: GameScene
    
    var body: some View {
        TabView {
            GPUContentView()
                .frame(width: 800, height: 600)
                .environmentObject(gamescene)
                .tabItem {
                    VStack {
                        Image(systemName: "power")
                        Text("GPU Rendered")
                    }
                }
                .tag(0)
            
            CPUContentView()
                .environmentObject(gamescene)
                .tabItem {
                    VStack {
                        Image(systemName: "cpu")
                        Text("CPU Rendered")
                    }
                }
                .tag(1)
        }
    }
}
