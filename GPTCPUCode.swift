//
//  GPTCPUCode.swift
//  Swift Ray Tracer
//
//  Created by Friedrich Stoltzfus on 4/23/23.
//

import Foundation

func hit(ray: Ray, sphere: Sphere, tMin: Float, tMax: Float, renderState: inout RenderState) {
    let co = ray.origin - sphere.center
    let a = dot(ray.direction, ray.direction)
    let b = 2.0 * dot(ray.direction, co)
    let c = dot(co, co) - sphere.radius * sphere.radius
    let discriminant = b * b - 4.0 * a * c

    if discriminant > 0 {
        let t = (-b - sqrt(discriminant)) / (2.0 * a)

        if t > tMin && t < tMax {
            renderState.t = t
            renderState.color = sphere.color
            renderState.hit = true
            renderState.position = ray.origin + t * ray.direction
            renderState.normal = normalize(renderState.position - sphere.center)
            renderState.reflectance = sphere.reflectance
        }
    } else {
        renderState.hit = false
    }
}

func trace(ray: Ray, sphereCount: Int, spheres: [Sphere]) -> RenderState {
    var color = simd_float3(repeating: 1.0)
    var nearestHit = Float(9999)
    var renderState = RenderState(t: 0.0, hit: false, position: simd_float3(repeating: 0), normal: simd_float3(repeating: 0), color: simd_float3(repeating: 0), reflectance: 0.0)

    for i in 0..<sphereCount {
        var newRenderState = renderState
        hit(ray: ray, sphere: spheres[i], tMin: 0.001, tMax: nearestHit, renderState: &newRenderState)

        if newRenderState.hit {
            nearestHit = newRenderState.t
            renderState = newRenderState
            color = renderState.color
        }
    }

    renderState.color = color
    return renderState
}

func rayColor(xy: simd_float2, ray: Ray, sceneData: SceneData, spheres: [Sphere]) -> simd_float3 {
    var color = simd_float3(repeating: 1.0)
    var tempColor = simd_float3(repeating: 0.0)

    // Initial trace
    var result = trace(ray: ray, sphereCount: Int(sceneData.sphereCount), spheres: spheres)
    color = color * result.color

    for i in 0..<sceneData.maxBounces {
        // Early exit
        if !result.hit {
            break
        }

        // Bounces
        let origin = result.position
        let matteDirection = result.normal + randomVec(xy: xy, seed: Float(i))
        let reflectedDirection = reflect(ray.direction, n: result.normal)
        let reflectance = result.reflectance
        // Use reflectance of surface to blend between matte and reflect
        ray.origin = origin
        ray.direction = matteDirection
        result = trace(ray: ray, sphereCount: sceneData.sphereCount, spheres: spheres)
        tempColor = (1.0 - reflectance) * result.color
        ray.direction = reflectedDirection
        result = trace(ray: ray, sphereCount: sceneData.sphereCount, spheres: spheres)
        tempColor = tempColor + reflectance * result.color
        color = color * tempColor
    }

    return color
}

let PHI: Float = 1.61803398874989484820459  // Φ = Golden Ratio
let PI: Float = 3.141592653589793238

func gold_noise(xy: simd_float2, seed: Float) -> Float {
    return fract(tan(distance(xy * PHI, xy) * seed) * xy.x)
}

func randomVec(xy: simd_float2, seed: Float) -> simd_float3 {
    let radius = gold_noise(xy: xy, seed: seed)
    let theta = 2.0 * PI * gold_noise(xy: xy, seed: seed + 1.0)
    let phi = PI * gold_noise(xy: xy, seed: seed + 2.0)

    return simd_float3(
        radius * cos(theta) * cos(phi),
        radius * sin(theta) * cos(phi),
        radius * sin(phi)
    )
}

func rayTracingCPU(colorBuffer: inout [[simd_float4]], spheres: [Sphere], sceneData: SceneData) {
    let width = colorBuffer.count
    let height = colorBuffer[0].count

    for x in 0..<width {
        for y in 0..<height {
            let horizontalCoefficient = (Float(x) - Float(width) / 2) / Float(width)
            let verticalCoefficient = (Float(y) - Float(height) / 2) / Float(width)
            let forwards = sceneData.cameraForwards
            let right = sceneData.cameraRight
            let up = sceneData.cameraUp

            var myRay = Ray(origin: sceneData.cameraPos, direction: normalize(forwards + horizontalCoefficient * right + verticalCoefficient * up))
            let color = rayColor(xy: simd_float2(horizontalCoefficient, verticalCoefficient), ray: myRay, sceneData: sceneData, spheres: spheres)
            colorBuffer[x][y] = simd_float4(color, 1.0)
        }
    }
}

