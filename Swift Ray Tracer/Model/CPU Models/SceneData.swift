//
//  SceneData.swift
//  Swift Ray Tracer
//
//  Created by Friedrich Stoltzfus on 4/23/23.
//

import Foundation

struct SceneData {
    var cameraPos: simd_float3
    var sphereCount: Int
    var maxBounces: Int
    var cameraForwards: simd_float3
    var cameraRight: simd_float3
    var cameraUp: simd_float3
}
