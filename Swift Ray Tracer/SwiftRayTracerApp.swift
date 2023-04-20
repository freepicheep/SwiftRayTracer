//
//  SwiftRayTracerApp.swift
//  Project
//
//  Created by Andrew Mengede on 3/3/2022.
//

import SwiftUI

@main
struct SwiftRayTracerApp: App {
    
    @StateObject private var gamescene = GameScene()
    
    var body: some Scene {
        
        //create a view of the underlying scene data
        WindowGroup {
            appView()
                .environmentObject(gamescene)
        }
    }
}
