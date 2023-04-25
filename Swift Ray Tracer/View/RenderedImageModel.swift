//
//  RenderedImageModel.swift
//  Swift Ray Tracer
//
//  Created by Friedrich Stoltzfus on 4/25/23.
//

import SwiftUI
import Combine
import UIKit

class RenderedImageModel: ObservableObject {
    @Published var image: UIImage?
}
