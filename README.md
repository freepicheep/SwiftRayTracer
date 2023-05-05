# SwiftRayTracer

A simple ray tracer largely based on amengede's work [here](https://github.com/amengede/getIntoMetalDev/tree/main/11%20Reflections/finished). He has a video explaining the process [here](https://youtu.be/GjOfrxjwiaU). 

The goal of this project is to compare ray tracing on the CPU and GPU. Currently, the program just renders a bunch of random spheres with random reflectivity. Once the program is launched, the `GameScene` is created and the same `GameScene` will be used for both the CPU and GPU raytracing so the comparison is fair. 

# Usage

Because this project uses Apple’s Metal architecture, you will need a Mac to compile the code. In theory the program can also run on iOS devices as well, but I think you would need to make a few changes. 

On a Mac, open the project in Xcode. You will have to change the developer team to your dev profile under the project settings. If you don’t know where this is, just try running the project and the error will show you were to change it. You can then run the project by clicking on the run button or by pressing `Command + R`. This will compile the code and launch the SwiftUI application. There are two main tabs to launch the CPU and GPU ray tracers respectively. Just select the tab and click the button to begin ray tracing!

Check the log in Xcode to see the printed CPU and GPU results. 

# Project Description

### Ray Tracing Overview

My program allows the user to ray trace a pseudorandom array of spheres. Ray tracing is a technique for rendering images by simulating the way light interacts with objects in a 3D scene. There are both CPU and GPU implementations to demonstrate the incredible efficiency that can be achieved by using the GPU for parallelizable tasks like ray tracing. Currently, the project only parallelizes the rendering of the pixels, but parallelization could be added for the vector math. Here are the basic high level details about ray tracing and specifically my implementation of it:

1. Rays: In ray tracing, we shoot rays from the camera into the scene to determine the color of each pixel in the final image. In this code, rays are represented by the `Shader_Ray` structure, which consists of an origin (camera position) and a direction.

2. Scene: The 3D scene consists of objects like spheres, represented by the `Shader_Sphere` structure. A sphere has a center, radius, color, and reflectance. The scene is described by the `Shader_SceneData` structure, which contains information about the camera, number of spheres, and maximum bounces.

3. Intersections: To determine if a ray intersects with an object, we need to perform intersection tests. The `hit` function in the Metal code calculates the intersection between a ray and a sphere. If the ray intersects the sphere, the function returns information about the intersection point, such as the distance (t), normal vector, and surface properties (color, reflectance).

4. Bounces: When a ray hits a surface, it can either be absorbed or reflected. In this code, the ray can bounce off the surface, and the direction of the bounce is calculated using the surface normal and a random vector. The `rayColor` function iterates through the bounces, calculating the color contribution for each bounce.

5. Accumulating color: For each bounce, the ray tracer calculates the color contribution based on the surface properties of the intersected object. The final color of a pixel is the product of the colors from all bounces.

6. Parallelization: Ray tracing can be computationally expensive, especially for complex scenes. In the Metal code, the `ray_tracing_kernel` function processes each pixel in parallel by executing the kernel on the GPU. This allows for efficient rendering, as each thread on the GPU calculates the color for a single pixel independently.

The ray tracing process in the given Metal code involves shooting rays from the camera into the scene, testing for intersections with objects, calculating the color contribution from each bounce, and accumulating the colors to determine the final pixel color. The entire process is parallelized on the GPU to optimize performance.

### What to Expect

When you run the program for both the CPU and GPU, you should see a pseudorandom assortment of spheres (different sizes, positions, colors, reflectivity, etc.). The reflections and shading should be realistic. Please note that the CPU implementation does not correctly render shadows when the `maxBounces` is set higher than `1`. I was unsuccessful in analyzing the source of this issue. Here are some gifs of the CPU and GPU ray tracing respectively.

#### CPU Ray Tracing

[](CPU_Demo.gif)

#### GPU Ray Tracing

[](GPU_Demo.gif)

### Performance Analysis

The GPU absolutely crushes the CPU for ray tracing. The results will vary, but the CPU version takes `14.38` seconds and the GPU version took `0.022` seconds. This was with the `maxBounce` being set to `50`. The CPU would be faster if I would not update the UI image until the rendering was complete. I think it shaved a few seconds off. You can easily change it back to just showing the image by removing the code for it in the `CPUContentView` and the `CPUMain`. You can also parallelize the CPU by using the number of threads available on your Mac, but I did not do this because I wanted to emphasize the difference between multithreading and just using one thread. 

# A Deeper Dive Into the Code 

Here are some good explanations of what is happening under the covers, especially for the GPU. Thanks to GPT-4 for helping out with the explanations.

### Metal Code

1. `ray_tracing_kernel`: This is the main kernel function that gets executed on the GPU for each pixel in the final image. It calculates the ray direction for the current pixel, traces the ray through the scene, and computes the final color. The calculated color is then written to the `color_buffer` texture at the corresponding pixel location.

2. `rayColor`: This function is responsible for calculating the color of a ray as it bounces through the scene. It takes the initial ray, scene data, and a list of spheres as input. For each bounce (up to `maxBounces`), it traces the ray to find the nearest intersection, and then calculates the new ray direction for the next bounce based on the surface normal and a random vector. The color contribution from each bounce is accumulated to produce the final color.

3. `trace`: This function takes a ray, the number of spheres in the scene, and a list of spheres as input. It loops through all the spheres and tests for intersections with the ray using the `hit` function. If an intersection is found, it updates the render state with information about the nearest intersection. The function returns the render state with details about the nearest intersection, such as the color, position, normal, and reflectance.

4. `hit`: This function calculates the intersection between a ray and a sphere. It takes the ray, sphere, minimum and maximum distance values, and the current render state as input. If the ray intersects the sphere within the specified distance range, it updates the render state with information about the intersection, such as the distance (t), color, normal, position, and reflectance. If there's no intersection, it returns the unchanged render state.

5. `randomVec`: This function generates a random 3D vector using a 2D input coordinate (xy) and a seed value. It uses the golden ratio (PHI) and the distance function to produce a pseudorandom number, which is then used to compute the radius, theta, and phi for a spherical coordinate system. The function returns a 3D vector in Cartesian coordinates.

6. `gold_noise`: This function generates a pseudorandom number using a 2D input coordinate (xy) and a seed value. It uses the golden ratio (PHI), the distance function, and the input seed to create the pseudorandom number. The function returns a floating-point value between 0 and 1.

These functions work together to implement the ray tracing process. The main `ray_tracing_kernel` function calculates the ray for each pixel and calls `rayColor` to compute the final color. The `rayColor` function traces the ray through the scene using the `trace` function and accumulates the color contribution for each bounce. The `trace` function tests for intersections with spheres using the `hit` function. Finally, the `randomVec` and `gold_noise` functions are used to generate random vectors and pseudorandom numbers for the ray bounces.

### Calling the Metal Code

The `Renderer` class runs on the CPU and manages the work to copy the data to the GPU and all the related tasks.

1. `class Renderer`: This class conforms to the `MTKViewDelegate` protocol, which means it handles rendering for a Metal-backed view (MTKView). It includes properties for the rendering loop control, Metal device, command queue, and compute pipeline.

2. `init(_ parent: GPUContentView, gamescene: GameScene, shouldRender: Bool)`: This initializer sets up the Metal device, command queue, and compute pipeline state. It creates a default library and a function named `ray_tracing_kernel`, which will be used for parallelized GPU-based ray tracing.

3. `makeSphereBuffer() -> MTLBuffer?`: This method creates an MTLBuffer containing information about the spheres in the scene. It first calculates the memory size required for the buffer, then allocates and fills it with the sphere data. Finally, it creates an MTLBuffer with the allocated memory and returns it.

4. `draw(in view: MTKView)`: This is the main rendering method called every frame. It starts by checking if rendering should continue based on the `shouldRender` property and `frameCount`. Then, it sets up a command buffer, a compute command encoder, and binds resources such as textures, buffers, and bytes to the encoder.

5. The most important part of the parallelization is in the `draw` method when the work is dispatched to the GPU:

```swift
let workGroupWidth = pipeline.threadExecutionWidth
let workGroupHeight = pipeline.maxTotalThreadsPerThreadgroup / workGroupWidth
let threadsPerGroup = MTLSizeMake(workGroupWidth, workGroupHeight, 1)
let threadsPerGrid = MTLSizeMake(Int(view.drawableSize.width),
                                 Int(view.drawableSize.height), 1)

renderEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
```

Here, the workGroupWidth and workGroupHeight represent the dimensions of each work group (or thread group) that the GPU will process. threadsPerGroup and threadsPerGrid define the number of threads in a group and the total number of threads in the grid, respectively.

When calling `dispatchThreads`, it tells the GPU to execute the kernel function (in this case, `ray_tracing_kernel`) with the specified number of threads per group and threads per grid. This allows the GPU to process multiple pixels in parallel, significantly speeding up the ray tracing process.

6. After the work has been dispatched, the code waits for the command buffer to complete, then calculates the time taken for the GPU ray tracing and prints the result.