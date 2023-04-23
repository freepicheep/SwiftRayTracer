//
//  Ray.swift
//  Swift Ray Tracer
//
//  Created by Friedrich Stoltzfus on 4/23/23.
//

import Foundation

struct Ray {
    var origin: simd_float3
    var direction: simd_float3
    
    func pointAt(destination: Float) -> simd_float3 {
        return origin + direction * destination
    }
}
