//
//  StageModelSpec.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/07/20.
//

import UIKit

struct TerrainModelSpec {
    let name: String                    // name (English only)
    let filename: String                // USDZ file name without ext
    let stageRadius: Float              // [m]
    let cloudsPosition: SIMD3<Float>    // clouds' Y position [m]
    let cloudNumberXZ: (x: Int, z: Int) // number of cloud on X/Z axis
    var squareStageRadius: Float {
        stageRadius * stageRadius
    }
}

// swiftlint:disable type_body_length
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
        TerrainModelSpec(name: "Village",
                         filename: "village", // terrain usdz file name wo ext
                         stageRadius: 0.15,  // [m]
                         cloudsPosition: SIMD3<Float>(0, 0.1, 0), // clouds' Y position
                         cloudNumberXZ: (x: 5, z: 7)), // number of cloud on X/Z axis
        TerrainModelSpec(name: "Field",
                         filename: "field", // terrain usdz file name wo ext
                         stageRadius: 0.15,  // [m]
                         cloudsPosition: SIMD3<Float>(0, 0.1, 0), // clouds' Y position
                         cloudNumberXZ: (x: 5, z: 7)), // number of cloud on X/Z axis
        TerrainModelSpec(name: "Town",
                         filename: "town", // terrain usdz file name wo ext
                         stageRadius: 0.15,  // [m]
                         cloudsPosition: SIMD3<Float>(0, 0.1, 0), // clouds' Y position
                         cloudNumberXZ: (x: 5, z: 7)) // number of cloud on X/Z axis
    ]

    // MARK: Position and Scale

    // 1. rotate the stage-origin based on the device orientation
    // 2. add the stage-position
    // 3. place the stage at the position
    static let stageOrigin = SIMD3<Float>(0, 0, -0.3) // ... for (1)
    private static let stagePositionAndScales = [     // ... position for (2)
        // #0: village
        [   // (position, scale)
            (position: SIMD3<Float>(0, 0, 0), scale: SIMD3<Float>(0.4, 0.4, 0.4)), // #0: Small
            (position: SIMD3<Float>(0, -0.5, 0), scale: SIMD3<Float>(10, 10, 10)), // #1: Middle
            (position: SIMD3<Float>(0, -2, 0), scale: SIMD3<Float>(30, 30, 30))    // #2: Large
        ],
        // #1: field
        [   // (position, scale)
            (position: SIMD3<Float>(0, 0, 0), scale: SIMD3<Float>(0.4, 0.4, 0.4)), // #0: Small
            (position: SIMD3<Float>(0, -0.5, 0), scale: SIMD3<Float>(10, 10, 10)), // #1: Middle
            (position: SIMD3<Float>(0, -2, 0), scale: SIMD3<Float>(30, 30, 30))    // #2: Large
        ],
        // #2: town
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

    // MARK: Sky-dome color

    // common for all model-index
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

    // MARK: Cloud color

    // common for all model-index
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

    // MARK: Rain and Snow Colors

    // common for all model-index
    // [Note]
    //   The condition is fine but rain or snow amount is more than 1 mm happens.
    //   Therefore rain/snow colors in fine are necessary.
    private static let rainColors = [
        UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5), // 0: daylight, fine
        UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5), // 1: daylight, rain
        UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5), // 2: night, fine
        UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)  // 3: night, rain
    ]

    private static let snowColors = [
        UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1), // 0: daylight, fine
        UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1), // 1: daylight, rain|snow
        UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1), // 2: night, fine
        UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)  // 3: night, rain|snow
    ]

    // returns the color of rain or snow
    // common for all model-index
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

    // MARK: Terrain Colors

    private static let terrainColors = [
        [   // #0: village (isUnlit, color)
            [ // #0: daylight, fine
                (false, UIColor(red: 0.731, green: 0.688, blue: 0.681, alpha: 1)), // mathouseroof
                (false, UIColor(red: 0.965, green: 0.926, blue: 0.888, alpha: 1)), // mathousewall
                (true, UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)), // mathousewindow
                (false, UIColor(red: 0.727, green: 0.804, blue: 0.712, alpha: 1)), // matbasegreen
                (false, UIColor(red: 0.849, green: 0.845, blue: 0.722, alpha: 1)), // matbasebrown
                (false, UIColor(red: 0.902, green: 0.953, blue: 0.868, alpha: 1)), // mattree
                (false, UIColor(red: 0.760, green: 0.675, blue: 0.562, alpha: 1))  // mattrunk
            ],
            [ // #1: daylight, rain
                (false, UIColor(red: 0.432, green: 0.404, blue: 0.404, alpha: 1)), // mathouseroof
                (false, UIColor(red: 0.733, green: 0.695, blue: 0.659, alpha: 1)), // mathousewall
                (true, UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)), // mathousewindow
                (false, UIColor(red: 0.548, green: 0.623, blue: 0.554, alpha: 1)), // matbasegreen
                (false, UIColor(red: 0.570, green: 0.566, blue: 0.464, alpha: 1)), // matbasebrown
                (false, UIColor(red: 0.570, green: 0.605, blue: 0.490, alpha: 1)), // mattree
                (false, UIColor(red: 0.540, green: 0.470, blue: 0.373, alpha: 1))  // mattrunk
            ],
            [ // #2: daylight, snow
                (false, UIColor(red: 0.771, green: 0.782, blue: 0.803, alpha: 1)), // mathouseroof
                (false, UIColor(red: 0.778, green: 0.753, blue: 0.731, alpha: 1)), // mathousewall
                (true, UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)), // mathousewindow
                (false, UIColor(red: 0.764, green: 0.778, blue: 0.803, alpha: 1)), // matbasegreen
                (false, UIColor(red: 0.764, green: 0.778, blue: 0.803, alpha: 1)), // matbasebrown
                (false, UIColor(red: 0.753, green: 0.757, blue: 0.764, alpha: 1)), // mattree
                (false, UIColor(red: 0.760, green: 0.702, blue: 0.614, alpha: 1))  // mattrunk
            ],
            [ // #3: night, fine
                (false, UIColor(red: 0.416, green: 0.400, blue: 0.412, alpha: 1)), // mathouseroof
                (false, UIColor(red: 0.362, green: 0.337, blue: 0.316, alpha: 1)), // mathousewall
                (true, UIColor(red: 0.988, green: 0.960, blue: 0.823, alpha: 1)), // mathousewindow
                (false, UIColor(red: 0.282, green: 0.325, blue: 0.282, alpha: 1)), // matbasegreen
                (false, UIColor(red: 0.354, green: 0.354, blue: 0.290, alpha: 1)), // matbasebrown
                (false, UIColor(red: 0.255, green: 0.282, blue: 0.224, alpha: 1)), // mattree
                (false, UIColor(red: 0.333, green: 0.286, blue: 0.228, alpha: 1))  // mattrunk
            ],
            [ // #4: night, rain
                (false, UIColor(red: 0.312, green: 0.316, blue: 0.342, alpha: 1)), // mathouseroof
                (false, UIColor(red: 0.210, green: 0.196, blue: 0.182, alpha: 1)), // mathousewall
                (true, UIColor(red: 0.988, green: 0.960, blue: 0.823, alpha: 1)), // mathousewindow
                (false, UIColor(red: 0.187, green: 0.219, blue: 0.196, alpha: 1)), // matbasegreen
                (false, UIColor(red: 0.139, green: 0.143, blue: 0.139, alpha: 1)), // matbasebrown
                (false, UIColor(red: 0.143, green: 0.163, blue: 0.134, alpha: 1)), // mattree
                (false, UIColor(red: 0.022, green: 0.022, blue: 0.022, alpha: 1))  // mattrunk
            ],
            [ // #5 night, snow
                (false, UIColor(red: 0.511, green: 0.530, blue: 0.561, alpha: 1)), // mathouseroof
                (false, UIColor(red: 0.503, green: 0.484, blue: 0.495, alpha: 1)), // mathousewall
                (true, UIColor(red: 0.988, green: 0.960, blue: 0.823, alpha: 1)), // mathousewindow
                (false, UIColor(red: 0.507, green: 0.523, blue: 0.557, alpha: 1)), // matbasegreen
                (false, UIColor(red: 0.507, green: 0.523, blue: 0.557, alpha: 1)), // matbasebrown
                (false, UIColor(red: 0.507, green: 0.507, blue: 0.523, alpha: 1)), // mattree
                (false, UIColor(red: 0.316, green: 0.273, blue: 0.219, alpha: 1))  // mattrunk
            ]
        ],
        [   // #1: field (isUnlit, color)
            [   // #0 daylight, fine
                (false, UIColor(red: 0.542, green: 0.580, blue: 0.464, alpha: 1)),   // matgreen
                (false, UIColor(red: 0.647, green: 0.666, blue: 0.436, alpha: 1)),   // matgrass
                (false, UIColor(red: 0.767, green: 0.803, blue: 0.706, alpha: 1)),   // mattree
                (false, UIColor(red: 0.610, green: 0.546, blue: 0.448, alpha: 1))    // mattrunk
            ],
            [   // #1 daylight, rain
                (false, UIColor(red: 0.277, green: 0.303, blue: 0.233, alpha: 1)),   // matgreen
                (false, UIColor(red: 0.308, green: 0.325, blue: 0.196, alpha: 1)),   // matgrass
                (false, UIColor(red: 0.428, green: 0.472, blue: 0.371, alpha: 1)),   // mattree
                (false, UIColor(red: 0.404, green: 0.350, blue: 0.277, alpha: 1))    // mattrunk
            ],
            [   // #2 daylight, snow
                (false, UIColor(red: 0.757, green: 0.757, blue: 0.757, alpha: 1)),   // matgreen
                (false, UIColor(red: 0.713, green: 0.713, blue: 0.717, alpha: 1)),   // matgrass
                (false, UIColor(red: 0.799, green: 0.799, blue: 0.799, alpha: 1)),   // mattree
                (false, UIColor(red: 0.735, green: 0.677, blue: 0.580, alpha: 1))    // mattrunk
            ],
            [   // #3 night, fine
                (false, UIColor(red: 0.219, green: 0.242, blue: 0.196, alpha: 1)),   // matgreen
                (false, UIColor(red: 0.255, green: 0.273, blue: 0.177, alpha: 1)),   // matgrass
                (false, UIColor(red: 0.182, green: 0.201, blue: 0.153, alpha: 1)),   // mattree
                (false, UIColor(red: 0.358, green: 0.308, blue: 0.242, alpha: 1))    // mattrunk
            ],
            [   // #4 night, rain
                (false, UIColor(red: 0.168, green: 0.182, blue: 0.153, alpha: 1)),   // matgreen
                (false, UIColor(red: 0.191, green: 0.205, blue: 0.143, alpha: 1)),   // matgrass
                (false, UIColor(red: 0.113, green: 0.129, blue: 0.103, alpha: 1)),   // mattree
                (false, UIColor(red: 0.264, green: 0.228, blue: 0.177, alpha: 1))    // mattrunk
            ],
            [   // #5 night, snow
                (false, UIColor(red: 0.408, green: 0.391, blue: 0.395, alpha: 1)),   // matgreen
                (false, UIColor(red: 0.371, green: 0.371, blue: 0.375, alpha: 1)),   // matgrass
                (false, UIColor(red: 0.491, green: 0.484, blue: 0.448, alpha: 1)),   // mattree
                (false, UIColor(red: 0.260, green: 0.246, blue: 0.228, alpha: 1))    // mattrunk
            ]
        ],
        [ // #2: town (isUnlit, color)
            [ // #0 daylight, fine
                (false, UIColor(red: 0.810, green: 0.808, blue: 0.921, alpha: 1)), // matbuilding
                (true, UIColor(red: 0.819, green: 0.879, blue: 0.879, alpha: 1)), // matwindowlight
                (true, UIColor(red: 0.819, green: 0.879, blue: 0.879, alpha: 1)), // matwindowdark
                (false, UIColor(red: 0.787, green: 0.806, blue: 0.840, alpha: 1)), // matgroundlight
                (false, UIColor(red: 0.673, green: 0.692, blue: 0.729, alpha: 1)), // matgrounddark
                (false, UIColor(red: 0.834, green: 0.866, blue: 0.753, alpha: 1)), // mattree
                (false, UIColor(red: 0.834, green: 0.768, blue: 0.659, alpha: 1))  // mattrunk
            ],
            [ // #1 daylight, rain
                (false, UIColor(red: 0.651, green: 0.650, blue: 0.773, alpha: 1)), // matbuilding
                (true, UIColor(red: 0.819, green: 0.879, blue: 0.879, alpha: 1)), // matwindowlight
                (true, UIColor(red: 0.950, green: 0.950, blue: 0.950, alpha: 1)), // matwindowdark
                (false, UIColor(red: 0.619, green: 0.645, blue: 0.687, alpha: 1)), // matgroundlight
                (false, UIColor(red: 0.491, green: 0.513, blue: 0.552, alpha: 1)), // matgrounddark
                (false, UIColor(red: 0.681, green: 0.717, blue: 0.606, alpha: 1)), // mattree
                (false, UIColor(red: 0.503, green: 0.440, blue: 0.358, alpha: 1))  // mattrunk
            ],
            [ // #2 daylight, snow
                (false, UIColor(red: 0.864, green: 0.869, blue: 0.908, alpha: 1)), // matbuilding
                (true, UIColor(red: 0.819, green: 0.879, blue: 0.879, alpha: 1)), // matwindowlight
                (true, UIColor(red: 0.950, green: 0.950, blue: 0.950, alpha: 1)), // matwindowdark
                (false, UIColor(red: 0.861, green: 0.879, blue: 0.906, alpha: 1)), // matgroundlight
                (false, UIColor(red: 0.827, green: 0.844, blue: 0.870, alpha: 1)), // matgrounddark
                (false, UIColor(red: 0.841, green: 0.838, blue: 0.829, alpha: 1)), // mattree
                (false, UIColor(red: 0.778, green: 0.757, blue: 0.728, alpha: 1))  // mattrunk
            ],
            [ // #3 night, fine
                (false, UIColor(red: 0.597, green: 0.596, blue: 0.727, alpha: 1)), // matbuilding
                (true, UIColor(red: 0.985, green: 0.978, blue: 0.902, alpha: 1)), // matwindowlight
                (true, UIColor(red: 0, green: 0, blue: 0, alpha: 1)), // matwindowdark
                (false, UIColor(red: 0.433, green: 0.458, blue: 0.492, alpha: 1)), // matgroundlight
                (false, UIColor(red: 0.336, green: 0.351, blue: 0.387, alpha: 1)), // matgrounddark
                (false, UIColor(red: 0.412, green: 0.436, blue: 0.337, alpha: 1)), // mattree
                (false, UIColor(red: 0.416, green: 0.354, blue: 0.273, alpha: 1))  // mattrunk
            ],
            [ // #4 night, rain
                (false, UIColor(red: 0.378, green: 0.381, blue: 0.498, alpha: 1)), // matbuilding
                (true, UIColor(red: 0.985, green: 0.978, blue: 0.902, alpha: 1)), // matwindowlight
                (true, UIColor(red: 0, green: 0, blue: 0, alpha: 1)), // matwindowdark
                (false, UIColor(red: 0.303, green: 0.320, blue: 0.350, alpha: 1)), // matgroundlight
                (false, UIColor(red: 0.205, green: 0.219, blue: 0.242, alpha: 1)), // matgrounddark
                (false, UIColor(red: 0.329, green: 0.346, blue: 0.273, alpha: 1)), // mattree
                (false, UIColor(red: 0.303, green: 0.255, blue: 0.201, alpha: 1))  // mattrunk
            ],
            [ // #5 night, snow
                (false, UIColor(red: 0.614, green: 0.633, blue: 0.662, alpha: 1)), // matbuilding
                (true, UIColor(red: 0.985, green: 0.978, blue: 0.902, alpha: 1)), // matwindowlight
                (true, UIColor(red: 0, green: 0, blue: 0, alpha: 1)), // matwindowdark
                (false, UIColor(red: 0.503, green: 0.519, blue: 0.550, alpha: 1)), // matgroundlight
                (false, UIColor(red: 0.591, green: 0.606, blue: 0.640, alpha: 1)), // matgrounddark
                (false, UIColor(red: 0.629, green: 0.618, blue: 0.606, alpha: 1)), // mattree
                (false, UIColor(red: 0.538, green: 0.530, blue: 0.523, alpha: 1))  // mattrunk
            ]
        ]
    ]

    static func terrainColors(modelIndex: Int, isDaylight: Bool, condition: HourForecast.Condition)
    -> [(Bool, UIColor)] {  // [(isUnlit, color)]
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
}
