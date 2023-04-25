//
//  Sphere.swift
//  Project
//
//  Created by Andrew Mengede on 3/9/2022.
//

import Foundation

class Sphere {
    
    var center: simd_float3
    var radius: Float
    var color: simd_float3
    var reflectance: Float
    
    init(center: simd_float3, radius: Float, color: simd_float3, reflectance: Float) {
        
        self.center = center
        self.radius = radius
        self.color = color
        self.reflectance = reflectance
    }
}
