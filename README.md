# SwiftRayTracer

A simple ray tracer largely based on amengede's work [here](https://github.com/amengede/getIntoMetalDev/tree/main/11%20Reflections/finished). He has a video explaining the process [here](https://youtu.be/GjOfrxjwiaU). 

The goal of this project is to compare ray tracing on the CPU and GPU. Currently, the program just renders a bunch of random spheres with random reflectivity. Once the program is launched, the `GameScene` is created and the same `GameScene` will be used for both the CPU and GPU raytracing so the comparison is fair. 

# Usage

Open the project in Xcode. You will probably have to change the developer team to your dev profile under the project settings. You can then run the project by clicking on the run button or by pressing `Command + R`.

# Nerdy Details 

Here are some good explanations of what is happening under the covers, especially for the GPU. Thanks to GPT-4 for helping out with the explanations.

## Metal Code

1. `ray_tracing_kernel`: This is the main kernel function that gets executed on the GPU for each pixel in the final image. It calculates the ray direction for the current pixel, traces the ray through the scene, and computes the final color. The calculated color is then written to the `color_buffer` texture at the corresponding pixel location.

2. `rayColor`: This function is responsible for calculating the color of a ray as it bounces through the scene. It takes the initial ray, scene data, and a list of spheres as input. For each bounce (up to `maxBounces`), it traces the ray to find the nearest intersection, and then calculates the new ray direction for the next bounce based on the surface normal and a random vector. The color contribution from each bounce is accumulated to produce the final color.

3. `trace`: This function takes a ray, the number of spheres in the scene, and a list of spheres as input. It loops through all the spheres and tests for intersections with the ray using the `hit` function. If an intersection is found, it updates the render state with information about the nearest intersection. The function returns the render state with details about the nearest intersection, such as the color, position, normal, and reflectance.

4. `hit`: This function calculates the intersection between a ray and a sphere. It takes the ray, sphere, minimum and maximum distance values, and the current render state as input. If the ray intersects the sphere within the specified distance range, it updates the render state with information about the intersection, such as the distance (t), color, normal, position, and reflectance. If there's no intersection, it returns the unchanged render state.

5. `randomVec`: This function generates a random 3D vector using a 2D input coordinate (xy) and a seed value. It uses the golden ratio (PHI) and the distance function to produce a pseudorandom number, which is then used to compute the radius, theta, and phi for a spherical coordinate system. The function returns a 3D vector in Cartesian coordinates.

6. `gold_noise`: This function generates a pseudorandom number using a 2D input coordinate (xy) and a seed value. It uses the golden ratio (PHI), the distance function, and the input seed to create the pseudorandom number. The function returns a floating-point value between 0 and 1.

These functions work together to implement the ray tracing process. The main `ray_tracing_kernel` function calculates the ray for each pixel and calls `rayColor` to compute the final color. The `rayColor` function traces the ray through the scene using the `trace` function and accumulates the color contribution for each bounce. The `trace` function tests for intersections with spheres using the `hit` function. Finally, the `randomVec` and `gold_noise` functions are used to generate random vectors and pseudorandom numbers for the ray bounces.
