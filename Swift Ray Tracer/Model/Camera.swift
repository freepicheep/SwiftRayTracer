//
//  Camera.swift
//  Project
//
//  Created by Andrew Mengede on 3/9/2022.
//

import Foundation

class Camera {
    /*
     Represents a camera in the scene
     */
    
    var position: simd_float3
    var theta: Float
    var phi: Float
    var forwards: simd_float3
    var right: simd_float3
    var up: simd_float3
    
    init(position: simd_float3) {
        
        self.position = position;
        theta = 0
        phi = 0
        forwards = [0.0, 0.0, 0.0];
        right = [0.0, 0.0, 0.0];
        up = [0.0, 0.0, 0.0];
        
        recalculate_vectors()
    }
    
    func recalculate_vectors() {
        
        forwards = [
            cos(theta * 180.0 / .pi) * cos(phi * 180.0 / .pi),
            sin(theta * 180.0 / .pi) * cos(phi * 180.0 / .pi),
            sin(phi * 180.0 / .pi)
        ]
        
        let global_up: simd_float3 = [0.0, 0.0, 1.0];
        
        right = normalize(cross(forwards, global_up))
        
        up = normalize(cross(right, forwards))
    }
    
    func getRay(u: Float, v: Float, height: Int, width: Int) -> Ray {
        let viewportWidth = 2.0 * tan(60.0 * Float.pi / 180.0 / 2.0)
        let viewportHeight = viewportWidth * Float(height) / Float(width)
        
        let lowerLeftCorner = position + forwards - right * (viewportWidth / 2.0) - up * (viewportHeight / 2.0)
        let horizontal = right * viewportWidth
        let vertical = up * viewportHeight
        
        let direction = lowerLeftCorner + horizontal * u + vertical * v - position
        return Ray(origin: position, direction: normalize(direction))
    }
}
