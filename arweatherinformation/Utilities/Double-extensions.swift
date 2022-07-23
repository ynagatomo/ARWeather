//
//  Double-extensions.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/07/22.
//

import Foundation

extension Double {
    static func radianFrom(degree: Double) -> Double {
        degree * Double.pi / 180.0
    }

    /// returns -360.0 ... 360.0 degree
    static func normalize(degree: Double) -> Double {
        var result = degree
        while result > 360 {
            result -= 360
        }
        while result < -360 {
            result += 360
        }
        assert( result >= -360 && result <= 360 )
        return result
    }

    /// returns -2PI ... 2PI degree
    static func normalize(radian: Double) -> Double {
        let pi2 = Double.pi * 2
        var result = radian
        while result > pi2 {
            result -= pi2
        }
        while result < -pi2 {
            result += pi2
        }
        assert( result >= -pi2 && result <= pi2 )
        return result
    }
}
