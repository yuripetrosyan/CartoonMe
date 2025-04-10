//
//  ImageProcessor.swift
//  CartoonMe
//
//  Created by Yuri Petrosyan on 10/04/2025.
//

// ImageProcessor.swift
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

class ImageProcessor {
    func cartoonify(image: UIImage, theme: String) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let filter: CIFilter
        switch theme {
        case "Studio Ghibli":
            filter = CIFilter.cartoonEffect()
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(1.0, forKey: "inputLineWidth")
            // Add more Ghibli-specific tweaks later (e.g., softness)
        case "Classic Cartoon":
            filter = CIFilter.cartoonEffect()
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(2.0, forKey: "inputLineWidth") // Thicker lines
        case "Anime Style":
            filter = CIFilter.colorControls() // Placeholder, tweak later
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(1.5, forKey: kCIInputSaturationKey)
        default:
            filter = CIFilter.cartoonEffect()
            filter.setValue(ciImage, forKey: kCIInputImageKey)
        }
        
        guard let outputImage = filter.outputImage,
              let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
}

extension CIFilter {
    static func cartoonEffect() -> CIFilter {
        CIFilter(name: "CIComicEffect") ?? CIFilter()
    }
}
