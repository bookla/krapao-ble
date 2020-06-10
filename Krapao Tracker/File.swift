//
//  File.swift
//  Krapao Tracker
//
//  Created by Book Lailert on 27/11/18.
//  Copyright © 2018 Book Lailert. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage

        let size = self.size
        let aspectRatio =  size.width/size.height

        switch contentMode {
            case .scaleAspectFit:
                if aspectRatio > 1 {                            // Landscape image
                    width = dimension
                    height = dimension / aspectRatio
                } else {                                        // Portrait image
                    height = dimension
                    width = dimension * aspectRatio
                }

        default:
            fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
        }

        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = opaque
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
                newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }

        return newImage
    }
}

extension Int {
    func calculateDistance() -> NSNumber {
        var calibration = 0
        var minimumVal = 0
        var logVal = Float(0)
        calibration = UserDefaults().integer(forKey: "DistanceCalibration")
        minimumVal = UserDefaults().integer(forKey: "MinimumCalibration")
        logVal = UserDefaults().float(forKey: "LogCalibration")
        if calibration == 0 {
            calibration = 9
        }
        if minimumVal == 0 {
            minimumVal = 44
        }
        if logVal == Float(0) {
            logVal = Float(2)
        }
        let absoluteRssi:Double = Double(self)*Double(integerLiteral: (-1))
        var distance:Double = absoluteRssi - Double(minimumVal)
        let calibrateVal:Double = Double(calibration)/Double(100)
        distance = distance*calibrateVal
        distance = pow(distance, Double(logVal))
        return NSNumber(floatLiteral: Double(round(distance*10)/10))
    }
}

extension Collection where Element: Numeric {
    /// Returns the total sum of all elements in the array
    var total: Element { return reduce(0, +) }
}

extension Collection where Element: BinaryInteger {
    /// Returns the average of all elements in the array
    var average: Double {
        return isEmpty ? 0 : Double(Int(total)) / Double(count)
    }
}

extension Collection where Element: BinaryFloatingPoint {
    /// Returns the average of all elements in the array
    var average: Element {
        return isEmpty ? 0 : total / Element(count)
    }
}

