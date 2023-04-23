//
//  RenderState.swift
//  Swift Ray Tracer
//
//  Created by Friedrich Stoltzfus on 4/23/23.
//

import Foundation


struct RenderState {
    var t: Float
    var hit: Bool
    var position: simd_float3
    var normal: simd_float3
    var color: simd_float3
    var reflectance: Float
}
