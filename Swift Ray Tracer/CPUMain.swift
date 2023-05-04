//
//  CPUMain.swift
//  Swift Ray Tracer
//
//  Created by Friedrich Stoltzfus on 4/22/23.
//

import Foundation
import simd
import UIKit

var gamescene:  GameScene = GameScene()

let sphereCount = gamescene.spheres.count

let PHI: Float = 1.61803398874989484820459
let PI: Float = 3.141592653589793238


func goldNoise(_ xy: simd_float2, _ seed: Float) -> Float {
    let dist = distance(xy * PHI, xy)
    let tang = tan(dist * seed)
    let fraction = modf(tang * xy[0]).1
    return fraction
}

func randomVec(_ xy: simd_float2, _ seed: Float) -> simd_float3 {
    let radius = goldNoise(xy, seed)
    let theta = 2.0 * PI * goldNoise(xy, seed + 1.0)
    let phi = PI * goldNoise(xy, seed + 2.0)
    
    return simd_float3(
        radius * cos(theta) * cos(phi),
        radius * sin(theta) * cos(phi),
        radius * sin(phi)
    )
}

func reflect(_ incoming: simd_float3, _ normal: simd_float3) -> simd_float3 {
    return incoming - 2 * dot(normal, incoming) * normal
}

func hit(_ ray: Ray, _ sphere: Sphere, _ tMin: Float, _ tMax: Float, _ renderState: inout RenderState) {
    // Thank you, Carl Friedrich Gauss, for discovering these math stuff
    let co = ray.origin - sphere.center
    let a = dot(ray.direction, ray.direction)
    let b = 2.0 * dot(ray.direction, co)
    let c = dot(co, co) - sphere.radius * sphere.radius
    let discriminant = b * b - 4.0 * a * c

    if discriminant >= 0 {
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

func trace(_ ray: Ray, _ sphereCount: Int, _ spheres: [Sphere]) -> RenderState {
    var color = simd_float3(repeating: 1.0)
    var nearestHit = Float(9999)
    var renderState = RenderState(t: 0, hit: false, position: simd_float3(), normal: simd_float3(), color: simd_float3(), reflectance: 0)
    
    for i in 0..<sphereCount {
        var newRenderState = renderState
        hit(ray, spheres[i], 0.001, nearestHit, &newRenderState)
        
        if newRenderState.hit {
            nearestHit = newRenderState.t
            renderState = newRenderState
            color = renderState.color
        }
    }
    
    renderState.color = color
    return renderState
}

func rayColor(_ xy: simd_float2, _ ray: Ray, _ sceneData: SceneData, _ spheres: [Sphere]) -> simd_float3 {
    var color = simd_float3(repeating: 1.0)
    var tempColor = simd_float3(repeating: 0.0)
    
    // Initial trace
    var result = trace(ray, sceneData.sphereCount, spheres)
    color *= result.color
    
    for i in 0..<sceneData.maxBounces {
        // Early exit
        if !result.hit {
            break
        }
        
        // Bounces
        let origin = result.position
        let matteDirection = result.normal + randomVec(xy, Float(i))
        let reflectedDirection = reflect(ray.direction, result.normal)
        let reflectance = result.reflectance
        // Use reflectance of surface to blend between matte and reflect
        var newRay = ray
        newRay.origin = origin
        newRay.direction = matteDirection
        result = trace(newRay, sceneData.sphereCount, spheres)
        tempColor = (1.0 - reflectance) * result.color
        newRay.direction = reflectedDirection
        result = trace(newRay, sceneData.sphereCount, spheres)
        tempColor += reflectance * result.color
        color *= tempColor
    }
    
    return color
}


func rayTracingCPU(imageWidth: Int, imageHeight: Int, sceneData: SceneData, spheres: [Sphere], completionHandler: @escaping (_ updatedImage: UIImage) -> Void) -> UIImage? {
    let pixelData = UnsafeMutablePointer<simd_float3>.allocate(capacity: imageWidth * imageHeight)
    
    for j in 0..<imageHeight {
        for i in 0..<imageWidth {
            let horizontal_coefficient = (Float(i) - Float(imageWidth) / 2) / Float(imageWidth)
            let vertical_coefficient = (Float(j) - Float(imageHeight) / 2) / Float(imageWidth)
            let forwards = sceneData.cameraForwards
            let right = sceneData.cameraRight
            let up = sceneData.cameraUp
            
            let myRay = Ray(origin: sceneData.cameraPos, direction: normalize(forwards + horizontal_coefficient * right + vertical_coefficient * up))
            
            let color = rayColor(simd_float2(horizontal_coefficient, vertical_coefficient), myRay, sceneData, spheres)
            let index = j * imageWidth + i
            pixelData[index] = color
        }
        
        // Call the completion handler after processing each row.
        if j % 10 == 0 {
            if let cgImage = createCGImageFromFloat3Buffer(buffer: pixelData, width: imageWidth, height: j + 1) {
                completionHandler(UIImage(cgImage: cgImage))
            }
        }
    }
    
    if let cgImage = createCGImageFromFloat3Buffer(buffer: pixelData, width: imageWidth, height: imageHeight) {
        pixelData.deallocate()
        return UIImage(cgImage: cgImage)
    } else {
        print("Error: Failed to create UIImage from CGImage.")
        pixelData.deallocate()
        return nil
    }
}


func createCGImageFromFloat3Buffer(buffer: UnsafePointer<simd_float3>, width: Int, height: Int) -> CGImage? {
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)

    guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
        print("Error: Failed to create CGContext.")
        return nil
    }
    let data = context.data!.bindMemory(to: UInt8.self, capacity: width * height * 4)
    
    for y in 0..<height {
        for x in 0..<width {
            let index = y * width + x
            let color = buffer[index]
            let pixelIndex = index * 4
            
            data[pixelIndex] = UInt8(min(max(color.x, 0), 1) * 255)
            data[pixelIndex + 1] = UInt8(min(max(color.y, 0), 1) * 255)
            data[pixelIndex + 2] = UInt8(min(max(color.z, 0), 1) * 255)
            data[pixelIndex + 3] = 255
        }
    }
    
    return context.makeImage()
}


// Save the image or display it as needed

func saveImageToDesktop(_ image: UIImage, name: String) {
    guard let data = image.pngData() else {
        print("Error: Failed to convert UIImage to PNG data.")
        return
    }
    
    let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
    let fileURL = desktopURL.appendingPathComponent("\(name).png")
    
    do {
        try data.write(to: fileURL)
        print("Image saved to desktop: \(fileURL)")
    } catch {
        print("Error: Failed to save image to desktop: \(error)")
    }
}

