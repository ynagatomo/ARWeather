//
//  StageModelSpec.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/07/20.
//

// import Foundation
import UIKit

struct TerrainModelSpec {
    let filename: String
    let stageRadius: Float // [m]
    let cloudsPosition: SIMD3<Float>  // specify clouds' Y position
    let cloudNumberXZ: (x: Int, z: Int) // number of cloud on X/Z axis
    var squareStageRadius: Float {
        stageRadius * stageRadius
    }
}

struct StageModelSpec {
    static let baseFilename = "base"    // base usdz file name wo ext
    static let cloudFilename = "cloud"   // cloud usdz file name wo ext
    static let cloudSize = SIMD3<Float>(0.08, 0.02, 0.04) // (width, height, depth) [m]
    static let windSpeedMax: Double = 100 // [km/h]
    static let windSpeedStageCoefficient: Double = 100 // real wind speed -> stage speed

    static let rainSquareWidth: Float = 0.001 // [m]
    static let rainSquareHeight: Float = 0.01 // [m]
    static let snowSquareHeight: Float = 0.001 // [m]
    static let rainUnitHeight: Float = 0.03 // [m] rain unit contains rain meshes
    static let rainMaxNumber: Double = 80 // max [rains per unit]
    static let rainAmountMax: Double = 40 // max precipitation amount [mm]
    static let rainFallSpeed: Double = 0.07 // [m/s]
    static let rainWindSpeedMin: Double = 10 // [km/h]

    static let terrainModelSpecs = [
        TerrainModelSpec(filename: "field", // terrain usdz file name wo ext
                         stageRadius: 0.15,  // [m]
                         cloudsPosition: SIMD3<Float>(0, 0.1, 0), // clouds' Y position
                         cloudNumberXZ: (x: 5, z: 7)) // number of cloud on X/Z axis
    ]

    private static let skydomeColors = [
    UIColor(red: 0.463, green: 0.788, blue: 0.906, alpha: 1),   // 0: daylight, fine
    UIColor(red: 0.735, green: 0.787, blue: 0.815, alpha: 1),   // 1: daylight, rain|snow
    UIColor(red: 0.062, green: 0.18, blue: 0.404, alpha: 1),   // 2: night, fine
    UIColor(red: 0.018, green: 0.054, blue: 0.122, alpha: 1)    // 3: night, rain|snow
    ]

    static func skydomeColor(isDaylight: Bool, condition: HourForecast.Condition) -> UIColor {
        var index = 0
        if !isDaylight {
            index = 2
        }
        if !(condition == .fine) {
            index += 1
        }
        return skydomeColors[index]
    }

    private static let cloudColors = [
        UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 0.6), // 0: daylight, fine
        UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.9), // 1: daylight, rain|snow
        UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.8), // 2: night, fine
        UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 0.9)  // 3: night, rain|snow
    ]

    static func cloudColor(isDaylight: Bool, condition: HourForecast.Condition) -> UIColor {
        var index = 0
        if !isDaylight {
            index = 2
        }
        if !(condition == .fine) {
            index += 1
        }
        return cloudColors[index]
    }

    private static let rainColors = [
        UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5), // 0: daylight, fine
        UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5), // 1: daylight, rain|snow
        UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5), // 2: night, fine
        UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)  // 3: night, rain|snow
    ]

    private static let snowColors = [
        UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1), // 0: daylight, fine
        UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1), // 1: daylight, rain|snow
        UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1), // 2: night, fine
        UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)  // 3: night, rain|snow
    ]

    static func rainColor(isDaylight: Bool, condition: HourForecast.Condition) -> UIColor {
        var index = 0
        if !isDaylight {
            index = 2
        }
        if !(condition == .fine) {
            index += 1
        }
        return condition == .snow ? snowColors[index] : rainColors[index]
    }

    private static let terrainColors = [
        [   // #0 field
            [   // #0 daylight, fine
                UIColor(red: 0.542, green: 0.580, blue: 0.464, alpha: 1),   // matgreen
                UIColor(red: 0.647, green: 0.666, blue: 0.436, alpha: 1),   // matgrass
                UIColor(red: 0.767, green: 0.803, blue: 0.706, alpha: 1),   // mattree
                UIColor(red: 0.610, green: 0.546, blue: 0.448, alpha: 1)    // mattrunk
            ],
            [   // #1 daylight, rain
                UIColor(red: 0.277, green: 0.303, blue: 0.233, alpha: 1),   // matgreen
                UIColor(red: 0.308, green: 0.325, blue: 0.196, alpha: 1),   // matgrass
                UIColor(red: 0.428, green: 0.472, blue: 0.371, alpha: 1),   // mattree
                UIColor(red: 0.404, green: 0.350, blue: 0.277, alpha: 1)    // mattrunk
            ],
            [   // #2 daylight, snow
                UIColor(red: 0.757, green: 0.757, blue: 0.757, alpha: 1),   // matgreen
                UIColor(red: 0.713, green: 0.713, blue: 0.717, alpha: 1),   // matgrass
                UIColor(red: 0.799, green: 0.799, blue: 0.799, alpha: 1),   // mattree
                UIColor(red: 0.735, green: 0.677, blue: 0.580, alpha: 1)    // mattrunk
            ],
            [   // #3 night, fine
                UIColor(red: 0.219, green: 0.242, blue: 0.196, alpha: 1),   // matgreen
                UIColor(red: 0.255, green: 0.273, blue: 0.177, alpha: 1),   // matgrass
                UIColor(red: 0.182, green: 0.201, blue: 0.153, alpha: 1),   // mattree
                UIColor(red: 0.358, green: 0.308, blue: 0.242, alpha: 1)    // mattrunk
            ],
            [   // #4 night, rain
                UIColor(red: 0.168, green: 0.182, blue: 0.153, alpha: 1),   // matgreen
                UIColor(red: 0.191, green: 0.205, blue: 0.143, alpha: 1),   // matgrass
                UIColor(red: 0.113, green: 0.129, blue: 0.103, alpha: 1),   // mattree
                UIColor(red: 0.264, green: 0.228, blue: 0.177, alpha: 1)    // mattrunk
            ],
            [   // #5 night, snow
                UIColor(red: 0.408, green: 0.391, blue: 0.395, alpha: 1),   // matgreen
                UIColor(red: 0.371, green: 0.371, blue: 0.375, alpha: 1),   // matgrass
                UIColor(red: 0.491, green: 0.484, blue: 0.448, alpha: 1),   // mattree
                UIColor(red: 0.260, green: 0.246, blue: 0.228, alpha: 1)    // mattrunk
            ]
        ]
    ]

    static func terrainColors(modelIndex: Int, isDaylight: Bool, condition: HourForecast.Condition)
    -> [UIColor] {
        var index = 0
        if !isDaylight {
            index += 3
        }
        switch condition {
        case .fine: break
        case .rain: index += 1
        case .snow: index += 2
        }
        return terrainColors[modelIndex][index]
    }

    private static let stagePositionAndScales = [
        // #0: field
        [   // (position, scale)
            (position: SIMD3<Float>(0, 0, 0), scale: SIMD3<Float>(0.4, 0.4, 0.4)), // #0: Small
            (position: SIMD3<Float>(0, -0.5, 0), scale: SIMD3<Float>(10, 10, 10)), // #1: Middle
            (position: SIMD3<Float>(0, -2, 0), scale: SIMD3<Float>(30, 30, 30))    // #2: Large
        ]
    ]

    static func stagePositionAndScale(modelIndex: Int, scaleIndex: Int)
                                -> (position: SIMD3<Float>, scale: SIMD3<Float>) {
        return stagePositionAndScales[modelIndex][scaleIndex]
    }
}
